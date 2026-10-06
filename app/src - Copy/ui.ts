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

/** Adds the missing space after a full stop, question mark etc. so joined sentences never read "HelloHow are you". */
export const tidy = (t: string) => String(t ?? '').replace(/([a-z0-9)”"'][.!?:])(?=[A-Z“"(])/g, '$1 ').replace(/[ \t]{2,}/g, ' ').trim();

/** Small pop-up message in the corner: visible wherever the user has scrolled to. */
export function toast(message: string, error = false) {
  let c = document.getElementById('toasts');
  if (!c) { c = document.createElement('div'); c.id = 'toasts'; c.setAttribute('aria-live', 'polite'); document.body.append(c); }
  const t = document.createElement('div'); t.className = 'toast' + (error ? ' bad' : ''); t.setAttribute('role', error ? 'alert' : 'status');
  const i = document.createElement('span'); i.className = 'toast-ico'; i.textContent = error ? '!' : '✓';
  const m = document.createElement('span'); m.className = 'toast-msg'; m.textContent = tidy(message);
  const x = document.createElement('button'); x.type = 'button'; x.className = 'toast-x'; x.setAttribute('aria-label', 'Dismiss'); x.setAttribute('data-noload', ''); x.textContent = '×';
  t.append(i, m, x); c.append(t);
  const kill = () => t.remove(); x.addEventListener('click', kill); setTimeout(kill, error ? 9000 : 5000);
  while (c.children.length > 3) c.firstElementChild!.remove();
}

export const IMAGE_TYPES: Record<string, string> = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' };
export function checkImage(file: File): string {
  if (!IMAGE_TYPES[file.type]) return 'Use a JPEG, PNG or WebP image.';
  if (file.size > 5 * 1024 * 1024) return 'That photo is larger than 5 MB.';
  return '';
}

/** Styled drag-and-drop photo chooser (replaces the browser's plain "Choose File" box). */
export function filePicker() {
  const root = document.createElement('div'); root.className = 'dz';
  const id = 'dz' + Math.random().toString(36).slice(2, 9);
  root.innerHTML = `<input id="${id}" class="sr-only" type="file" accept="image/jpeg,image/png,image/webp">
<label class="dz-drop" for="${id}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><path d="M12 16V4M7 9l5-5 5 5M4 16v3a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-3"/></svg><span><strong>Choose a photo</strong> or drag it here<small>JPEG, PNG or WebP · up to 5 MB</small></span></label>
<div class="dz-preview" hidden><img alt=""><div class="dz-info"><span class="dz-name"></span><button type="button" class="quiet dz-remove" data-noload>Remove</button></div></div>
<p class="dz-error" role="alert" hidden></p>`;
  const input = root.querySelector('input') as HTMLInputElement, drop = root.querySelector('.dz-drop') as HTMLElement;
  const prev = root.querySelector('.dz-preview') as HTMLElement, img = prev.querySelector('img') as HTMLImageElement;
  const nameEl = root.querySelector('.dz-name') as HTMLElement, err = root.querySelector('.dz-error') as HTMLElement;
  let chosen: File | null = null, removed = false, hasCurrent = false, blobUrl = '';
  const showError = (m: string) => { err.textContent = m; err.hidden = !m; };
  const showPreview = (src: string, label: string) => { img.src = src; nameEl.textContent = label; prev.hidden = false; drop.hidden = true; };
  const reset = () => { chosen = null; input.value = ''; if (blobUrl) { URL.revokeObjectURL(blobUrl); blobUrl = ''; } prev.hidden = true; drop.hidden = false; showError(''); };
  const take = (file: File | undefined) => {
    if (!file) return; const bad = checkImage(file);
    if (bad) { reset(); showError(bad); return; }
    showError(''); chosen = file; removed = false; blobUrl = URL.createObjectURL(file); showPreview(blobUrl, `${file.name} (${Math.max(1, Math.round(file.size / 1024))} KB)`);
  };
  input.addEventListener('change', () => take(input.files?.[0]));
  for (const ev of ['dragenter', 'dragover']) drop.addEventListener(ev, e => { e.preventDefault(); drop.classList.add('drag'); });
  for (const ev of ['dragleave', 'drop']) drop.addEventListener(ev, () => drop.classList.remove('drag'));
  drop.addEventListener('drop', e => { e.preventDefault(); const f = (e as DragEvent).dataTransfer?.files?.[0]; if (f) take(f); });
  (root.querySelector('.dz-remove') as HTMLElement).addEventListener('click', () => { const was = !chosen && hasCurrent; reset(); if (was) removed = true; });
  return {
    el: root, file: () => chosen, removed: () => removed, clear: () => { reset(); removed = false; },
    setCurrent(url: string | null) { if (!url || chosen) return; hasCurrent = true; showPreview(url, 'Current photo'); },
  };
}

/** Collapsible section: title + arrow; the content only shows when opened. */
export function accordion(title: string, body: HTMLElement, opts: { open?: boolean; count?: string } = {}) {
  const d = document.createElement('details'); d.className = 'acc'; d.open = !!opts.open;
  const s = document.createElement('summary');
  s.innerHTML = '<span class="acc-title"></span><span class="acc-meta"></span><svg class="acc-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M6 9l6 6 6-6"/></svg>';
  (s.querySelector('.acc-title') as HTMLElement).textContent = title;
  const c = document.createElement('div'); c.className = 'acc-body'; c.append(body); d.append(s, c);
  if (opts.count) {
    const meta = s.querySelector('.acc-meta') as HTMLElement, sel = opts.count;
    new MutationObserver(() => { const n = body.querySelectorAll(sel).length; meta.textContent = n ? String(n) : ''; }).observe(body, { childList: true, subtree: true });
  }
  return d;
}
