import { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import type { SupabaseClient } from '@supabase/supabase-js';
import { configureClient, setIdentity, useIdentity, track, type Identity } from './state';
import { Navigation } from './navigation';
import { Landing } from './landing';
import { Preferences } from './preferences';
import { Home, WorkspaceHome } from './home';
import { DestinationPage, ListingPage } from './catalog';
import { BookingPage, ReservationsPage } from './bookings';
export const experiencePages = ['destination', 'listing', 'book', 'bookings', 'reservations', 'reports', 'preferences'].map(page => `<section data-page="${page}" hidden><div id="react-${page}" class="tm-react"></div></section>`).join('');
function RoutePage({ page }: { page: string }) {
  const identity = useIdentity(); const [hash, setHash] = useState(location.hash.slice(1));
  useEffect(() => { const change = () => setHash(location.hash.slice(1)); window.addEventListener('hashchange', change); return () => window.removeEventListener('hashchange', change); }, []);
  const [path, query] = hash.split('?'); const id = path?.split('/')[2];
  if (identity.role === 'loading' || path?.split('/')[1] !== page) return null;
  if (identity.role === 'guest' && page === 'destination' && id) return <DestinationPage key={id} id={id} />;
  if (identity.role === 'guest' && page === 'listing' && id) return <ListingPage key={id} id={id} />;
  if (!identity.id) return null;
  if (page === 'reports' && (identity.role === 'admin' || identity.role === 'owner')) return <WorkspaceHome key={identity.id} report />;
  if (page === 'reservations' && identity.role === 'owner') return <ReservationsPage key={identity.id} owner />;
  if (identity.role !== 'traveler') return null;
  if (page === 'preferences') return <Preferences key={identity.id} />;
  if (page === 'destination' && id) return <DestinationPage key={id + identity.id} id={id} />;
  if (page === 'listing' && id) return <ListingPage key={id + identity.id} id={id} />;
  if (page === 'book' && id) return <BookingPage key={id + (query || '') + identity.id} id={id} room={new URLSearchParams(query).get('room')} />;
  if (page === 'bookings') return <ReservationsPage key={identity.id} />;
  return null;
}
let mounted = false;
export function mountExperience() {
  if (mounted) return; mounted = true;
  const landing = document.getElementById('react-landing'); if (landing) createRoot(landing).render(<Landing />);
  const nav = document.createElement('div'); nav.id = 'react-navigation'; nav.className = 'tm-react'; document.body.prepend(nav); createRoot(nav).render(<Navigation />);
  const home = document.createElement('div'); home.id = 'react-home'; home.className = 'tm-react'; document.querySelector('[data-page="home"]')!.prepend(home); createRoot(home).render(<Home />);
  for (const page of ['destination', 'listing', 'book', 'bookings', 'reservations', 'reports', 'preferences']) createRoot(document.getElementById('react-' + page)!).render(<RoutePage page={page} />);
}
export function initExperience(client: SupabaseClient) {
  configureClient(client); let lastPage = '';
  const recordPage = () => { const target = location.hash.slice(1).split('?')[0] || '/'; if (target !== lastPage) { lastPage = target; void track('page_view', target); } };
  window.addEventListener('hashchange', recordPage);
  return { setUser(identity: Identity) { const previousId = document.body.dataset.identity; document.body.dataset.identity = identity.id ?? ''; document.body.dataset.workspace = identity.role; setIdentity(identity); if (previousId !== identity.id) lastPage = ''; if (identity.id && identity.role !== 'loading') recordPage(); } };
}
