import { useSyncExternalStore } from 'react';
import type { SupabaseClient } from '@supabase/supabase-js';
export type WorkspaceRole = 'guest' | 'loading' | 'traveler' | 'owner' | 'admin';
export type Identity = { id: string | null; role: WorkspaceRole; name: string; email: string };
let identity: Identity = { id: null, role: 'guest', name: '', email: '' };
const listeners = new Set<() => void>();
export function setIdentity(next: Identity) { identity = next; listeners.forEach(fn => fn()); window.dispatchEvent(new Event('travelmate:identity')); }
export function useIdentity() { return useSyncExternalStore(fn => { listeners.add(fn); return () => { listeners.delete(fn); }; }, () => identity); }
export function currentIdentity() { return identity; }
export let client: SupabaseClient;
export function configureClient(next: SupabaseClient) { client = next; }
export function navigate(path: string) { location.hash = '#' + path; }
export function errorMessage(e: unknown) { return e instanceof Error ? e.message : typeof e === 'object' && e && 'message' in e ? String(e.message) : 'Something went wrong. Please try again.'; }
export const money = (value: number | string | null) => value == null ? 'Not set' : new Intl.NumberFormat('en-PH', { style: 'currency', currency: 'PHP', maximumFractionDigits: 2 }).format(Number(value));
export type Destination = { id: string; name: string; province: string; description: string | null };
export type Listing = { id: string; name: string; listing_type: 'hotel' | 'restaurant' | 'attraction'; description: string | null; address: string | null; destination_id: string; image?: string };
export async function photosFor(listings: Listing[]) {
  if (!listings.length) return listings;
  const { data, error } = await client.from('photos').select('listing_id,bucket_id,object_path').in('listing_id', listings.map(x => x.id)).eq('status', 'approved').is('menu_item_id', null).order('sort_order');
  if (error) return listings;
  const photos = new Map<string, { bucket_id: string; object_path: string }>();
  for (const photo of data ?? []) if (!photos.has(photo.listing_id)) photos.set(photo.listing_id, photo);
  return Promise.all(listings.map(async listing => { const photo = photos.get(listing.id); if (!photo) return listing; const result = await client.storage.from(photo.bucket_id || 'travelmate-listings').createSignedUrl(photo.object_path, 3600); return { ...listing, image: result.data?.signedUrl }; }));
}
export async function track(kind: 'page_view' | 'listing_view' | 'api_timing', target: string, duration?: number) {
  if (!identity.id || identity.role === 'loading') return;
  // An analytics failure must never prevent navigation, browsing, or booking.
  try { await client.rpc('record_ui_event', { p_kind: kind, p_target: target, p_duration_ms: duration == null ? null : Math.round(duration) }); } catch { /* navigation continues */ }
}
