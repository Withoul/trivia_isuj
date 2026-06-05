/**
 * Soccer Audio Engine - Trivia Mundialista
 * Synthesized sounds using Web Audio API (no external files needed).
 * 
 * Available sounds:
 *   playGoal()         - Stadium horn + triple whistle (correct answer)
 *   playFoul()         - Single long whistle (incorrect answer)
 *   playTickTock()     - Metallic click (countdown each second)
 *   playSparkle()      - Ascending shimmer (click "¡A JUGAR!")
 *   playCountdownEnd() - Triple ascending beep (countdown reaches 0)
 *   playTimeWarning()  - Rapid double beep (last 3 seconds of question timer)
 */

let audioCtx = null;

function getCtx() {
  if (!audioCtx) {
    audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  }
  if (audioCtx.state === 'suspended') {
    audioCtx.resume();
  }
  return audioCtx;
}

// ==================== CORRECT ANSWER — GOAL! ====================
export function playGoal() {
  const ctx = getCtx();
  const now = ctx.currentTime;

  // Stadium horn (low frequency burst)
  const horn = ctx.createOscillator();
  const hornGain = ctx.createGain();
  horn.type = 'sawtooth';
  horn.frequency.setValueAtTime(220, now);
  horn.frequency.linearRampToValueAtTime(280, now + 0.15);
  hornGain.gain.setValueAtTime(0.25, now);
  hornGain.gain.linearRampToValueAtTime(0.15, now + 0.3);
  hornGain.gain.linearRampToValueAtTime(0, now + 0.6);
  horn.connect(hornGain).connect(ctx.destination);
  horn.start(now);
  horn.stop(now + 0.6);

  // Triple short whistle
  for (let i = 0; i < 3; i++) {
    const t = now + 0.1 + i * 0.18;
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(2800 + i * 200, t);
    gain.gain.setValueAtTime(0.2, t);
    gain.gain.linearRampToValueAtTime(0, t + 0.12);
    osc.connect(gain).connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.12);
  }

  // Celebration chime
  const chime = ctx.createOscillator();
  const chimeGain = ctx.createGain();
  chime.type = 'sine';
  chime.frequency.setValueAtTime(1200, now + 0.5);
  chime.frequency.linearRampToValueAtTime(1800, now + 0.7);
  chimeGain.gain.setValueAtTime(0.15, now + 0.5);
  chimeGain.gain.linearRampToValueAtTime(0, now + 0.9);
  chime.connect(chimeGain).connect(ctx.destination);
  chime.start(now + 0.5);
  chime.stop(now + 0.9);
}

// ==================== INCORRECT ANSWER — FOUL ====================
export function playFoul() {
  const ctx = getCtx();
  const now = ctx.currentTime;

  // Long descending whistle
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.type = 'sine';
  osc.frequency.setValueAtTime(2500, now);
  osc.frequency.linearRampToValueAtTime(1800, now + 0.5);
  gain.gain.setValueAtTime(0.2, now);
  gain.gain.linearRampToValueAtTime(0.15, now + 0.3);
  gain.gain.linearRampToValueAtTime(0, now + 0.5);
  osc.connect(gain).connect(ctx.destination);
  osc.start(now);
  osc.stop(now + 0.5);

  // Buzz/error tone
  const buzz = ctx.createOscillator();
  const buzzGain = ctx.createGain();
  buzz.type = 'square';
  buzz.frequency.setValueAtTime(150, now + 0.15);
  buzzGain.gain.setValueAtTime(0.08, now + 0.15);
  buzzGain.gain.linearRampToValueAtTime(0, now + 0.55);
  buzz.connect(buzzGain).connect(ctx.destination);
  buzz.start(now + 0.15);
  buzz.stop(now + 0.55);
}

// ==================== COUNTDOWN TICK ====================
export function playTickTock() {
  const ctx = getCtx();
  const now = ctx.currentTime;

  // Sharp metallic click
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.type = 'sine';
  osc.frequency.setValueAtTime(3500, now);
  osc.frequency.exponentialRampToValueAtTime(1500, now + 0.03);
  gain.gain.setValueAtTime(0.12, now);
  gain.gain.exponentialRampToValueAtTime(0.001, now + 0.06);
  osc.connect(gain).connect(ctx.destination);
  osc.start(now);
  osc.stop(now + 0.06);

  // Sub-tick (softer lower tone)
  const sub = ctx.createOscillator();
  const subGain = ctx.createGain();
  sub.type = 'sine';
  sub.frequency.setValueAtTime(800, now + 0.01);
  subGain.gain.setValueAtTime(0.06, now + 0.01);
  subGain.gain.exponentialRampToValueAtTime(0.001, now + 0.05);
  sub.connect(subGain).connect(ctx.destination);
  sub.start(now + 0.01);
  sub.stop(now + 0.05);
}

// ==================== SPARKLE (START GAME) ====================
export function playSparkle() {
  const ctx = getCtx();
  const now = ctx.currentTime;

  // Ascending shimmer sweep
  for (let i = 0; i < 6; i++) {
    const t = now + i * 0.06;
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(3000 + i * 800, t);
    gain.gain.setValueAtTime(0.08 - i * 0.01, t);
    gain.gain.exponentialRampToValueAtTime(0.001, t + 0.1);
    osc.connect(gain).connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.1);
  }

  // Final bright tone
  const final_osc = ctx.createOscillator();
  const finalGain = ctx.createGain();
  final_osc.type = 'sine';
  final_osc.frequency.setValueAtTime(6000, now + 0.4);
  finalGain.gain.setValueAtTime(0.1, now + 0.4);
  finalGain.gain.linearRampToValueAtTime(0, now + 0.7);
  final_osc.connect(finalGain).connect(ctx.destination);
  final_osc.start(now + 0.4);
  final_osc.stop(now + 0.7);
}

// ==================== COUNTDOWN END (Triple ascending beep) ====================
export function playCountdownEnd() {
  const ctx = getCtx();
  const now = ctx.currentTime;

  const freqs = [800, 1200, 1600];
  freqs.forEach((freq, i) => {
    const t = now + i * 0.15;
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(freq, t);
    gain.gain.setValueAtTime(0.18, t);
    gain.gain.linearRampToValueAtTime(0, t + 0.12);
    osc.connect(gain).connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.12);
  });
}

// ==================== TIME WARNING (last 3 seconds) ====================
export function playTimeWarning() {
  const ctx = getCtx();
  const now = ctx.currentTime;

  for (let i = 0; i < 2; i++) {
    const t = now + i * 0.1;
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(2000, t);
    gain.gain.setValueAtTime(0.1, t);
    gain.gain.exponentialRampToValueAtTime(0.001, t + 0.07);
    osc.connect(gain).connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.07);
  }
}

// Legacy export for backward compatibility
export const soccerAudio = {
  playGoal,
  playFoul,
  playTickTock,
  playSparkle,
  playCountdownEnd,
  playTimeWarning,
};
