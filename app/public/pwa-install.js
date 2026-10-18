/* Shared by the application and installation guide. No account data is cached. */
(() => {
  let promptEvent = null;
  let working = false;
  let installed = matchMedia('(display-mode: standalone)').matches || navigator.standalone === true;
  const button = document.getElementById('install');
  const status = document.getElementById('install-status');
  const steps = document.getElementById('manual-install');
  const android = /Android/i.test(navigator.userAgent);
  const ios = /iPhone|iPad|iPod/i.test(navigator.userAgent);
  const embedded = /; wv\)|\bwv\b|FBAN|FBAV|Instagram|Line\//i.test(navigator.userAgent);
  const message = text => { if (status) status.textContent = text; };

  function render() {
    if (!button) return;
    button.disabled = installed || working;
    button.dataset.state = installed ? 'installed' : working ? 'working' : promptEvent ? 'ready' : 'help';
    button.textContent = installed ? 'TravelMate is installed' : working ? 'Opening installation…' : 'Install TravelMate';
  }
  function help() {
    if (steps) { steps.open = true; steps.querySelector('summary')?.focus(); }
    if (embedded) message('This app’s built-in browser cannot install TravelMate. Tap Open in Chrome below, then install there.');
    else if (ios) message('On iPhone or iPad, open this link in Safari. Tap Share, then Add to Home Screen.');
    else if (android) message('If no prompt appears, use your browser’s ⋮ menu → Add to Home screen → Install. If that option is missing, tap Open in Chrome below.');
    else message('To install on Android, scan the QR code and open the link in Chrome. You can also use your desktop browser’s Install option if it is available.');
  }
  async function requestInstall() {
    if (installed || working) return;
    if (!promptEvent) { help(); return; }
    const event = promptEvent;
    promptEvent = null; working = true; render();
    try {
      await event.prompt();
      const choice = await event.userChoice;
      if (!installed) message(choice.outcome === 'accepted'
        ? 'Installation requested. Look for TravelMate on your home screen.'
        : 'Installation was dismissed. You can try again from your browser’s menu.');
    } catch { if (!installed) help(); }
    finally { working = false; render(); }
  }
  window.addEventListener('beforeinstallprompt', event => {
    event.preventDefault(); promptEvent = event; render();
    message('Ready to install. Tap Install TravelMate to continue.');
  });
  window.addEventListener('appinstalled', () => {
    installed = true; promptEvent = null; render();
    message('TravelMate is installed. Open it from your home screen.');
  });
  button?.addEventListener('click', () => { void requestInstall(); });
  // Use an already available prompt from the app's sidebar/footer links.
  document.addEventListener('click', event => {
    const anchor = event.target.closest?.('a[href]');
    if (!anchor || !promptEvent || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
    const url = new URL(anchor.href, location.href);
    if (url.origin === location.origin && /^\/install(?:\.html)?\/?$/.test(url.pathname)) {
      event.preventDefault(); void requestInstall();
    }
  });

  const chrome = document.getElementById('open-chrome');
  const website = document.getElementById('phone-link');
  const target = website?.href;
  if (chrome && target && android) {
    const url = new URL(target);
    chrome.href = 'intent://' + url.host + url.pathname + '#Intent;scheme=https;package=com.android.chrome;S.browser_fallback_url=' + encodeURIComponent(target) + ';end';
    chrome.hidden = false;
  }
  document.getElementById('copy-link')?.addEventListener('click', async () => {
    if (!target) return;
    try { await navigator.clipboard.writeText(target); message('Phone installation link copied.'); }
    catch {
      const field = document.getElementById('copy-link-value');
      if (field) { field.hidden = false; field.value = target; field.focus(); field.select(); }
      message('Select and copy the website link below.');
    }
  });
  if (steps && embedded) steps.hidden = false;
  if (installed) message('TravelMate is already open as an installed app.');
  render();

  if ('serviceWorker' in navigator && window.isSecureContext) {
    void navigator.serviceWorker.register('/sw.js', { scope: '/', updateViaCache: 'none' }).catch(() => {
      if (button && !installed) message('Automatic installation is unavailable in this browser. Tap Install TravelMate for the manual steps.');
    });
  }
})();
