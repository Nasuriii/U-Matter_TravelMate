/** Accessible native modal. Cancel, Escape and navigation never submit an action. */
export function confirmAction(title: string, message: string, label: string): Promise<boolean> {
  return new Promise(resolve => {
    const previous = document.activeElement as HTMLElement | null;
    const dialog = document.createElement('dialog'); dialog.className = 'tm-action-confirm';
    const heading = document.createElement('h2'); heading.id = 'tm-confirm-title'; heading.textContent = title;
    const text = document.createElement('p'); text.textContent = message;
    dialog.setAttribute('aria-labelledby', heading.id);
    const cancel = document.createElement('button'); cancel.type = 'button'; cancel.className = 'quiet'; cancel.textContent = 'Cancel'; cancel.autofocus = true;
    const accept = document.createElement('button'); accept.type = 'button'; accept.className = 'primary'; accept.textContent = label;
    const actions = document.createElement('div'); actions.className = 'tm-confirm-actions'; actions.append(cancel, accept);
    dialog.append(heading, text, actions); document.body.append(dialog);
    let done = false;
    const finish = (value: boolean) => {
      if (done) return; done = true;
      window.removeEventListener('hashchange', abort);
      dialog.close(); dialog.remove(); if (previous?.isConnected) previous.focus(); resolve(value);
    };
    const abort = () => finish(false);
    cancel.onclick = abort; accept.onclick = () => finish(true);
    dialog.addEventListener('cancel', e => { e.preventDefault(); abort(); });
    window.addEventListener('hashchange', abort);
    dialog.showModal(); cancel.focus();
  });
}
