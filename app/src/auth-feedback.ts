import { validateAuth, type AuthMode } from './auth-validation';

const fields = ['reg-first', 'reg-last', 'auth-email', 'auth-password', 'auth-confirm'] as const;
const input = (id: string) => document.getElementById(id) as HTMLInputElement;
function clearError(id: string) {
  input(id).removeAttribute('aria-invalid');
  const error = document.getElementById(id + '-error')!;
  error.hidden = true; error.textContent = '';
}
export function validateAuthForm(mode: AuthMode) {
  fields.forEach(clearError);
  const issues = validateAuth(mode, { first: input('reg-first').value, email: input('auth-email').value, password: input('auth-password').value, confirm: input('auth-confirm').value });
  for (const issue of issues) {
    input(issue.field).setAttribute('aria-invalid', 'true');
    const error = document.getElementById(issue.field + '-error')!;
    error.textContent = issue.message; error.hidden = false;
  }
  if (issues.length) input(issues[0].field).focus();
  return issues;
}
export function installAuthFeedback() {
  const updateHints = () => {
    const password = input('auth-password').value, confirm = input('auth-confirm').value;
    const length = document.querySelector<HTMLElement>('[data-password-length]')!;
    length.textContent = password.length >= 8 ? '✓ At least 8 characters' : 'Use at least 8 characters.';
    length.dataset.complete = String(password.length >= 8);
    const match = document.getElementById('auth-confirm-hint')!;
    match.hidden = !confirm;
    match.textContent = confirm ? password === confirm ? '✓ Passwords match' : 'Passwords don’t match yet.' : '';
    match.dataset.complete = String(!!confirm && password === confirm);
  };
  for (const id of fields) input(id).addEventListener('input', () => {
    clearError(id);
    if (id === 'auth-password') clearError('auth-confirm');
    updateHints();
    const notice = document.getElementById('auth-notice')!;
    if (notice.classList.contains('error') && !document.querySelector('#auth-form [aria-invalid=true]')) { notice.textContent = ''; notice.classList.remove('error'); }
  });
  const toggle = document.getElementById('toggle-pw')!;
  toggle.addEventListener('click', () => {
    const show = input('auth-password').type === 'password';
    for (const id of ['auth-password', 'auth-confirm']) input(id).type = show ? 'text' : 'password';
    toggle.querySelector('[data-password-label]')!.textContent = show ? 'Hide' : 'Show';
    toggle.setAttribute('aria-pressed', String(show));
    toggle.setAttribute('aria-label', show ? 'Hide passwords' : 'Show passwords');
  });
  window.addEventListener('hashchange', () => {
    fields.forEach(clearError);
    const notice = document.getElementById('auth-notice')!;
    if (notice.classList.contains('error')) { notice.textContent = ''; notice.classList.remove('error'); }
    for (const id of ['auth-password', 'auth-confirm']) input(id).type = 'password';
    toggle.querySelector('[data-password-label]')!.textContent = 'Show';
    toggle.setAttribute('aria-pressed', 'false'); toggle.setAttribute('aria-label', 'Show passwords');
  });
}
