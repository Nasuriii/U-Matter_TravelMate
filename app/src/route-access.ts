// Pure role routing shared with verification. Database RLS remains authoritative.
export type Workspace = 'guest' | 'loading' | 'traveler' | 'owner' | 'admin';
export type Access = 'in' | 'out' | 'any' | 'discovery' | 'traveler' | 'owner' | 'admin' | 'staff';
export function redirectForAccess(role: Workspace, access: Access): string | null {
  if (role === 'loading') return null;
  if (access === 'discovery') return role === 'guest' || role === 'traveler' ? null : '/home';
  if (role === 'guest') return access === 'out' || access === 'any' ? null : '/login';
  if (access === 'out') return '/home';
  if (access === 'traveler' && role !== 'traveler') return '/home';
  if (access === 'owner' && role !== 'owner') return '/home';
  if (access === 'admin' && role !== 'admin') return '/home';
  if (access === 'staff' && role !== 'owner' && role !== 'admin') return '/home';
  return null;
}
