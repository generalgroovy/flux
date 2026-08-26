using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace Flux.Bootstrap
{
    internal static class Program
    {
        private const string ProductName = "FLUX";
        private const string PayloadResource = "Flux.Payload.zip";
        private const string PayloadVersion = "__PAYLOAD_VERSION__";
        private const string PayloadSha256 = "__PAYLOAD_SHA256__";
        private const long MaximumExpandedBytes = 1024L * 1024L * 1024L;
        private const int MaximumEntries = 10000;

        [STAThread]
        private static int Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            BootstrapOptions options;
            try
            {
                options = BootstrapOptions.Parse(args);
            }
            catch (Exception error)
            {
                MessageBox.Show(error.Message, ProductName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return 2;
            }

            string root = options.InstallRoot ?? Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), ProductName);
            root = Path.GetFullPath(root);

            bool createdNew;
            using (Mutex mutex = new Mutex(true, "Local\\FLUX-Bootstrap-" + StableName(root), out createdNew))
            {
                if (!createdNew)
                {
                    MessageBox.Show("FLUX setup is already running.", ProductName,
                        MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return 3;
                }

                InstallerWindow window = new InstallerWindow();
                try
                {
                    window.Show();
                    window.SetStatus("Checking the included build…");
                    string gamePath = InstallOrRepair(root, options, window);

                    window.SetStatus(options.NoShortcuts ? "Installing the launcher…" : "Creating shortcuts…");
                    InstallLauncherAndShortcuts(root, !options.NoShortcuts);

                    if (!options.InstallOnly)
                    {
                        window.SetStatus("Starting FLUX…");
                        LaunchGame(gamePath, options.GameArguments);
                    }

                    window.Close();
                    return 0;
                }
                catch (Exception error)
                {
                    window.Close();
                    MessageBox.Show(
                        "FLUX was not changed because setup could not finish safely.\n\n" + error.Message,
                        "FLUX setup", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return 1;
                }
            }
        }

        private static string InstallOrRepair(string root, BootstrapOptions options, InstallerWindow window)
        {
            Directory.CreateDirectory(root);
            string versionsRoot = Path.Combine(root, "versions");
            Directory.CreateDirectory(versionsRoot);
            string finalDirectory = SafeChild(versionsRoot, PayloadVersion);
            string gamePath = Path.Combine(finalDirectory, "flux2.exe");

            if (!options.Repair && Directory.Exists(finalDirectory) && VerifyInstall(finalDirectory))
            {
                WriteState(root, PayloadVersion);
                return gamePath;
            }

            string stagingDirectory = SafeChild(versionsRoot, ".staging-" + Guid.NewGuid().ToString("N"));
            string payloadFile = Path.Combine(root, ".payload-" + Guid.NewGuid().ToString("N") + ".zip");
            try
            {
                window.SetStatus("Verifying the included build…");
                CopyEmbeddedPayload(payloadFile);
                string payloadHash = Sha256(payloadFile);
                if (!String.Equals(payloadHash, PayloadSha256, StringComparison.OrdinalIgnoreCase))
                    throw new InvalidDataException("The included game payload failed its SHA-256 check.");

                window.SetStatus("Installing the game safely…");
                Directory.CreateDirectory(stagingDirectory);
                ExtractSafely(payloadFile, stagingDirectory);
                if (!VerifyInstall(stagingDirectory))
                    throw new InvalidDataException("The extracted game files failed verification.");

                if (Directory.Exists(finalDirectory))
                {
                    string quarantine = SafeChild(versionsRoot,
                        ".replaced-" + PayloadVersion + "-" + DateTime.UtcNow.ToString("yyyyMMddHHmmss", CultureInfo.InvariantCulture));
                    Directory.Move(finalDirectory, quarantine);
                    try
                    {
                        Directory.Move(stagingDirectory, finalDirectory);
                        DeleteDirectorySafely(quarantine, versionsRoot);
                    }
                    catch
                    {
                        if (!Directory.Exists(finalDirectory) && Directory.Exists(quarantine))
                            Directory.Move(quarantine, finalDirectory);
                        throw;
                    }
                }
                else
                {
                    Directory.Move(stagingDirectory, finalDirectory);
                }

                WriteState(root, PayloadVersion);
                PruneOldVersions(versionsRoot, PayloadVersion, ReadPreviousVersion(root));
                return gamePath;
            }
            finally
            {
                if (File.Exists(payloadFile)) File.Delete(payloadFile);
                if (Directory.Exists(stagingDirectory)) DeleteDirectorySafely(stagingDirectory, versionsRoot);
            }
        }

        private static void CopyEmbeddedPayload(string destination)
        {
            using (Stream source = Assembly.GetExecutingAssembly().GetManifestResourceStream(PayloadResource))
            {
                if (source == null) throw new InvalidDataException("The installer does not contain a FLUX payload.");
                using (FileStream target = new FileStream(destination, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                    source.CopyTo(target);
            }
        }

        private static void ExtractSafely(string archivePath, string destination)
        {
            string root = Path.GetFullPath(destination).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            long expandedBytes = 0;
            int entries = 0;
            using (ZipArchive archive = ZipFile.OpenRead(archivePath))
            {
                foreach (ZipArchiveEntry entry in archive.Entries)
                {
                    entries++;
                    expandedBytes += entry.Length;
                    if (entries > MaximumEntries || expandedBytes > MaximumExpandedBytes)
                        throw new InvalidDataException("The game payload exceeds its safe extraction limits.");

                    string relative = entry.FullName.Replace('/', Path.DirectorySeparatorChar);
                    string output = Path.GetFullPath(Path.Combine(root, relative));
                    if (!output.StartsWith(root, StringComparison.OrdinalIgnoreCase))
                        throw new InvalidDataException("The game payload contains an unsafe path.");

                    if (String.IsNullOrEmpty(entry.Name))
                    {
                        Directory.CreateDirectory(output);
                        continue;
                    }

                    string parent = Path.GetDirectoryName(output);
                    if (!String.IsNullOrEmpty(parent)) Directory.CreateDirectory(parent);
                    using (Stream input = entry.Open())
                    using (FileStream outputStream = new FileStream(output, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                        input.CopyTo(outputStream);
                }
            }
        }

        private static bool VerifyInstall(string directory)
        {
            string game = Path.Combine(directory, "flux2.exe");
            string pack = Path.Combine(directory, "flux2.pck");
            string manifest = Path.Combine(directory, "SHA256SUMS.txt");
            if (!File.Exists(game) || !File.Exists(pack) || !File.Exists(manifest)) return false;

            string root = Path.GetFullPath(directory).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            foreach (string rawLine in File.ReadAllLines(manifest))
            {
                string line = rawLine.Trim();
                if (line.Length == 0) continue;
                if (line.Length < 67) return false;
                string expected = line.Substring(0, 64);
                string relative = line.Substring(64).TrimStart(' ', '*');
                if (relative.Length == 0) return false;
                string file = Path.GetFullPath(Path.Combine(root, relative.Replace('/', Path.DirectorySeparatorChar)));
                if (!file.StartsWith(root, StringComparison.OrdinalIgnoreCase) || !File.Exists(file)) return false;
                if (!String.Equals(Sha256(file), expected, StringComparison.OrdinalIgnoreCase)) return false;
            }
            return true;
        }

        private static string Sha256(string path)
        {
            using (SHA256 hash = SHA256.Create())
            using (FileStream stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read))
            {
                byte[] digest = hash.ComputeHash(stream);
                StringBuilder text = new StringBuilder(digest.Length * 2);
                foreach (byte value in digest) text.Append(value.ToString("x2", CultureInfo.InvariantCulture));
                return text.ToString();
            }
        }

        private static void WriteState(string root, string currentVersion)
        {
            string state = Path.Combine(root, "current.txt");
            string previous = ReadCurrentVersion(root);
            if (String.Equals(previous, currentVersion, StringComparison.OrdinalIgnoreCase))
                previous = ReadPreviousVersion(root);

            string temporary = Path.Combine(root, ".current-" + Guid.NewGuid().ToString("N") + ".tmp");
            File.WriteAllLines(temporary, new[] { currentVersion, previous ?? String.Empty }, new UTF8Encoding(false));
            if (File.Exists(state))
            {
                string backup = Path.Combine(root, "current.backup.txt");
                File.Replace(temporary, state, backup, true);
            }
            else File.Move(temporary, state);
        }

        private static string ReadCurrentVersion(string root)
        {
            string state = Path.Combine(root, "current.txt");
            if (!File.Exists(state)) return null;
            string[] lines = File.ReadAllLines(state);
            return lines.Length > 0 ? SafeVersion(lines[0]) : null;
        }

        private static string ReadPreviousVersion(string root)
        {
            string state = Path.Combine(root, "current.txt");
            if (!File.Exists(state)) return null;
            string[] lines = File.ReadAllLines(state);
            return lines.Length > 1 ? SafeVersion(lines[1]) : null;
        }

        private static string SafeVersion(string value)
        {
            if (String.IsNullOrWhiteSpace(value)) return null;
            foreach (char character in value)
                if (!(Char.IsLetterOrDigit(character) || character == '.' || character == '-' || character == '_')) return null;
            return value;
        }

        private static void PruneOldVersions(string versionsRoot, string current, string previous)
        {
            foreach (DirectoryInfo directory in new DirectoryInfo(versionsRoot).GetDirectories())
            {
                if (directory.Name.StartsWith(".", StringComparison.Ordinal)) continue;
                if (String.Equals(directory.Name, current, StringComparison.OrdinalIgnoreCase)) continue;
                if (!String.IsNullOrEmpty(previous) && String.Equals(directory.Name, previous, StringComparison.OrdinalIgnoreCase)) continue;
                try { DeleteDirectorySafely(directory.FullName, versionsRoot); }
                catch { /* An old running version may still be locked; retry on a future start. */ }
            }
        }

        private static void InstallLauncherAndShortcuts(string root, bool createShortcuts)
        {
            string launcher = Path.Combine(root, "FLUX Launcher.exe");
            string currentExecutable = Process.GetCurrentProcess().MainModule.FileName;
            if (!String.Equals(Path.GetFullPath(currentExecutable), Path.GetFullPath(launcher), StringComparison.OrdinalIgnoreCase))
            {
                string temporary = Path.Combine(root, ".launcher-" + Guid.NewGuid().ToString("N") + ".exe");
                File.Copy(currentExecutable, temporary, false);
                if (File.Exists(launcher))
                {
                    string backup = Path.Combine(root, "FLUX Launcher.previous.exe");
                    if (File.Exists(backup)) File.Delete(backup);
                    File.Replace(temporary, launcher, backup, true);
                }
                else File.Move(temporary, launcher);
            }

            if (!createShortcuts) return;

            string programs = Environment.GetFolderPath(Environment.SpecialFolder.Programs);
            string startMenu = Path.Combine(programs, ProductName);
            Directory.CreateDirectory(startMenu);
            CreateShortcut(Path.Combine(startMenu, "FLUX.lnk"), launcher, root);

            string desktop = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            if (!String.IsNullOrEmpty(desktop)) CreateShortcut(Path.Combine(desktop, "FLUX.lnk"), launcher, root);
        }

        private static void CreateShortcut(string shortcutPath, string targetPath, string workingDirectory)
        {
            Type shellType = Type.GetTypeFromProgID("WScript.Shell");
            if (shellType == null) return;
            object shell = Activator.CreateInstance(shellType);
            object shortcut = shellType.InvokeMember("CreateShortcut", BindingFlags.InvokeMethod, null, shell,
                new object[] { shortcutPath }, CultureInfo.InvariantCulture);
            Type shortcutType = shortcut.GetType();
            shortcutType.InvokeMember("TargetPath", BindingFlags.SetProperty, null, shortcut,
                new object[] { targetPath }, CultureInfo.InvariantCulture);
            shortcutType.InvokeMember("WorkingDirectory", BindingFlags.SetProperty, null, shortcut,
                new object[] { workingDirectory }, CultureInfo.InvariantCulture);
            shortcutType.InvokeMember("Description", BindingFlags.SetProperty, null, shortcut,
                new object[] { "Play or update FLUX" }, CultureInfo.InvariantCulture);
            shortcutType.InvokeMember("Save", BindingFlags.InvokeMethod, null, shortcut, null, CultureInfo.InvariantCulture);
        }

        private static void LaunchGame(string gamePath, string[] gameArguments)
        {
            if (!File.Exists(gamePath)) throw new FileNotFoundException("The installed FLUX game is missing.", gamePath);
            ProcessStartInfo start = new ProcessStartInfo();
            start.FileName = gamePath;
            start.WorkingDirectory = Path.GetDirectoryName(gamePath);
            start.UseShellExecute = true;
            start.Arguments = JoinArguments(gameArguments);
            Process.Start(start);
        }

        private static string JoinArguments(string[] arguments)
        {
            if (arguments == null || arguments.Length == 0) return String.Empty;
            List<string> quoted = new List<string>();
            foreach (string argument in arguments)
                quoted.Add("\"" + argument.Replace("\\", "\\\\").Replace("\"", "\\\"") + "\"");
            return String.Join(" ", quoted.ToArray());
        }

        private static string SafeChild(string parent, string child)
        {
            string root = Path.GetFullPath(parent).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            string result = Path.GetFullPath(Path.Combine(root, child));
            if (!result.StartsWith(root, StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Refusing to use a path outside the FLUX install root.");
            return result;
        }

        private static void DeleteDirectorySafely(string path, string parent)
        {
            string safe = SafeChild(parent, Path.GetFileName(Path.GetFullPath(path).TrimEnd(Path.DirectorySeparatorChar)));
            if (!String.Equals(safe.TrimEnd(Path.DirectorySeparatorChar), Path.GetFullPath(path).TrimEnd(Path.DirectorySeparatorChar),
                    StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Refusing to remove an unexpected directory.");
            Directory.Delete(safe, true);
        }

        private static string StableName(string value)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(value.ToUpperInvariant());
            using (SHA256 hash = SHA256.Create())
                return Convert.ToBase64String(hash.ComputeHash(bytes)).Replace('/', '_').Replace('+', '-').TrimEnd('=');
        }

        private sealed class BootstrapOptions
        {
            public bool InstallOnly;
            public bool NoShortcuts;
            public bool Repair;
            public string InstallRoot;
            public string[] GameArguments = new string[0];

            public static BootstrapOptions Parse(string[] args)
            {
                BootstrapOptions options = new BootstrapOptions();
                List<string> gameArgs = new List<string>();
                bool passthrough = false;
                foreach (string argument in args)
                {
                    if (passthrough) { gameArgs.Add(argument); continue; }
                    if (argument == "--") { passthrough = true; continue; }
                    if (String.Equals(argument, "--install-only", StringComparison.OrdinalIgnoreCase)) options.InstallOnly = true;
                    else if (String.Equals(argument, "--no-shortcuts", StringComparison.OrdinalIgnoreCase)) options.NoShortcuts = true;
                    else if (String.Equals(argument, "--repair", StringComparison.OrdinalIgnoreCase)) options.Repair = true;
                    else if (argument.StartsWith("--install-root=", StringComparison.OrdinalIgnoreCase))
                        options.InstallRoot = argument.Substring("--install-root=".Length).Trim('"');
                    else throw new ArgumentException("Unknown setup option: " + argument);
                }
                options.GameArguments = gameArgs.ToArray();
                return options;
            }
        }

        private sealed class InstallerWindow : Form
        {
            private readonly Label status;

            public InstallerWindow()
            {
                Text = "FLUX";
                ClientSize = new Size(420, 132);
                FormBorderStyle = FormBorderStyle.FixedDialog;
                MaximizeBox = false;
                MinimizeBox = false;
                StartPosition = FormStartPosition.CenterScreen;
                ControlBox = false;
                BackColor = Color.FromArgb(22, 27, 36);
                ForeColor = Color.FromArgb(235, 222, 180);
                UseWaitCursor = true;

                Label title = new Label();
                title.Text = "FLUX";
                title.Font = new Font("Segoe UI", 22F, FontStyle.Bold);
                title.AutoSize = true;
                title.Location = new Point(24, 18);
                title.ForeColor = Color.FromArgb(105, 213, 224);
                Controls.Add(title);

                status = new Label();
                status.Text = "Preparing…";
                status.Font = new Font("Segoe UI", 10F, FontStyle.Regular);
                status.AutoSize = false;
                status.Location = new Point(27, 76);
                status.Size = new Size(365, 32);
                Controls.Add(status);
            }

            public void SetStatus(string text)
            {
                status.Text = text;
                status.Refresh();
                Refresh();
                Application.DoEvents();
            }
        }
    }
}
