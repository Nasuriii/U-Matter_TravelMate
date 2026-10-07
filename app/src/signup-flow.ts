export type SignupPurpose = 'traveler' | 'business_owner';
export function purposeForPath(path: string): SignupPurpose | null {
 if (path === '/register/business') return 'business_owner';
 if (path === '/register/traveler' || path === '/register') return 'traveler';
 return null;
}
export function workspaceAfterSignup(role: string, onboarding: boolean) {
 return role === 'admin' ? '/home' : role === 'business_owner' ? '/owner' : onboarding ? '/preferences' : '/trips';
}
