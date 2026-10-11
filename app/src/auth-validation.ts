export type AuthMode = 'login' | 'register' | 'forgot' | 'reset';
export type AuthValues = { first: string; email: string; password: string; confirm: string };
export type AuthIssue = { field: 'reg-first' | 'auth-email' | 'auth-password' | 'auth-confirm'; message: string };

export function validateAuth(mode: AuthMode, values: AuthValues): AuthIssue[] {
  const issues: AuthIssue[] = [];
  if (mode === 'register' && !values.first.trim()) issues.push({ field: 'reg-first', message: 'Enter your first name.' });
  if (mode !== 'reset' && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(values.email.trim())) issues.push({ field: 'auth-email', message: 'Enter a valid email address.' });
  if (mode === 'login' && !values.password) issues.push({ field: 'auth-password', message: 'Enter your password.' });
  if (mode === 'register' || mode === 'reset') {
    if (values.password.length < 8) issues.push({ field: 'auth-password', message: 'Use at least 8 characters.' });
    if (!values.confirm) issues.push({ field: 'auth-confirm', message: 'Confirm your password.' });
    else if (values.password !== values.confirm) issues.push({ field: 'auth-confirm', message: 'Your passwords don’t match yet.' });
  }
  return issues;
}
