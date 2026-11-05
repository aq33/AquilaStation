/**
 * AQUILA: mierzy odświeżanie monitora (rytm requestAnimationFrame) i wysyła je serwerowi.
 * Przy FPS „Zalecane” serwer ustawia klientowi FPS równe odświeżaniu, bo np. 100 FPS
 * na monitorze 144 Hz pokazuje klatki nierówno (raz przez jedno, raz przez dwa odświeżenia).
 */

const SAMPLE_FRAMES = 120;

export const reportRefreshRate = () => {
  const deltas: number[] = [];
  let last: number | undefined;
  const step = (now: number) => {
    if (last !== undefined) {
      deltas.push(now - last);
    }
    last = now;
    if (deltas.length < SAMPLE_FRAMES) {
      requestAnimationFrame(step);
      return;
    }
    deltas.sort((a, b) => a - b);
    const median = deltas[Math.floor(deltas.length / 2)];
    if (median > 0) {
      Byond.sendMessage('display/refresh_rate', {
        hz: Math.round(1000 / median),
      });
    }
  };
  requestAnimationFrame(step);
};
