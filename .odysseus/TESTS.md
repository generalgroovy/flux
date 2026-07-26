# FLUX verification contract

Run targeted tests during implementation, followed by:

```bash
npm test
bash -n scripts/*.sh
git diff --check
```

For launcher/server changes also run `bash scripts/test-changes.sh` or an
equivalent live `/__flux_health` smoke. PowerShell behavior must be recorded as
unverified when no Windows/PowerShell environment was actually used.
