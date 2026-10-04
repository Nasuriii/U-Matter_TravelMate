/**
 * Shows a spinner on whichever button started a network request, so every action gives feedback
 * without each handler needing its own loading code. Buttons that make no request never flash.
 * Add data-noload to a button to opt out.
 */
export function installButtonLoading() {
  let inflight = 0, candidate: HTMLElement | null = null, stamp = 0, timer = 0, failsafe = 0;
  const active = new Set<HTMLElement>();
  const clear = () => { active.forEach(b => { b.classList.remove('is-loading'); b.removeAttribute('aria-busy'); }); active.clear(); };
  const origFetch = window.fetch.bind(window);
  window.fetch = (...args: Parameters<typeof fetch>) => {
    inflight++;
    if (candidate && Date.now() - stamp < 700) {
      candidate.classList.add('is-loading'); candidate.setAttribute('aria-busy', 'true'); active.add(candidate); candidate = null;
      clearTimeout(failsafe); failsafe = window.setTimeout(clear, 10000);
    }
    return origFetch(...args).finally(() => {
      inflight--; clearTimeout(timer);
      timer = window.setTimeout(() => { if (!inflight) clear(); }, 160);
    });
  };
  const pick = (e: Event) => {
    const t = e.target as HTMLElement | null;
    const b = (e as SubmitEvent).submitter ?? t?.closest?.('button, a.btn');
    if (b instanceof HTMLElement && !b.hasAttribute('data-noload')) { candidate = b; stamp = Date.now(); }
  };
  document.addEventListener('click', pick, true);
  document.addEventListener('submit', pick, true);
}
