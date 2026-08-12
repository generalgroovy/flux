export function drawTeamShape(context, team, teamColor, radius) {
  context.strokeStyle = teamColor;
  context.lineWidth = 2;
  if (team === "alpha") {
    context.beginPath();
    context.moveTo(-radius * 0.72, -radius * 0.28);
    context.lineTo(-radius * 1.02, 0);
    context.lineTo(-radius * 0.72, radius * 0.28);
    context.stroke();
  } else if (team === "beta") {
    for (const offset of [-0.16, 0.16]) {
      context.beginPath();
      context.moveTo(-radius * 0.96, radius * offset - radius * 0.18);
      context.lineTo(-radius * 0.72, radius * offset + radius * 0.18);
      context.stroke();
    }
  }
}

export function drawHealthWear(context, ink, radius, healthRatio) {
  if (healthRatio > 0.5) return;
  context.strokeStyle = ink;
  context.lineWidth = 1.5;
  context.beginPath();
  context.moveTo(-radius * 0.4, -radius * 0.36);
  context.lineTo(-radius * 0.12, -radius * 0.1);
  context.stroke();
  if (healthRatio > 0.25) return;
  context.beginPath();
  context.moveTo(-radius * 0.42, radius * 0.38);
  context.lineTo(-radius * 0.08, radius * 0.12);
  context.stroke();
}

export function openArc(context, x, y, radius, start, end) {
  context.beginPath();
  context.arc(x, y, radius, start, end);
  context.stroke();
}

export function tracePolygon(context, points) {
  context.beginPath();
  for (const [index, [x, y]] of points.entries()) {
    if (index === 0) context.moveTo(x, y);
    else context.lineTo(x, y);
  }
  context.closePath();
}

export function drawDiamond(context, x, y, width, height) {
  context.beginPath();
  context.moveTo(x + width, y);
  context.lineTo(x, y + height);
  context.lineTo(x - width, y);
  context.lineTo(x, y - height);
  context.closePath();
}

export function drawSplitRing(context, x, y, radius, gap = 0.28) {
  context.beginPath();
  context.arc(x, y, radius, gap, Math.PI - gap);
  context.stroke();
  context.beginPath();
  context.arc(x, y, radius, Math.PI + gap, Math.PI * 2 - gap);
  context.stroke();
}

export function positive(value) {
  return Number.isFinite(value) && value > 0;
}

export function finite(value) {
  return Number.isFinite(value) ? value : 0;
}

export function insideOpeningWindow(remaining, cooldown, window) {
  return (
    Number.isFinite(remaining) &&
    Number.isFinite(cooldown) &&
    cooldown > 0 &&
    remaining > Math.max(0, cooldown - window)
  );
}
