import { useEffect, useState } from 'react';
import { ArrowUpRight, ChevronDown, Compass, MapPin, Plus, Sparkles } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Card, CardContent } from '../components/ui/card';
import { recommendPlaces, interestLabels } from '../recommendations';
import { client, useIdentity, navigate, errorMessage, photosFor, type Destination, type Listing } from './state';
import { planDestination } from './catalog';
import { EmptyState, ErrorState, ListingCard, LoadingCards } from './shared';
import { destinationPhoto, type DestinationPhoto } from './destination-photos';
import { DestinationCover, PhotoCredit } from './destination-picture';
type ApprovedListing = Listing & {status: string};
type Picks = ReturnType<typeof recommendPlaces<Destination, ApprovedListing>>;
// Read every page so alphabetical ordering cannot hide a relevant destination.
async function catalog<T>(table: string, columns: string, key: string, value: string | number): Promise<T[]> {
  const rows: T[] = [];
  for (let offset = 0; ; offset += 500) {
    const r = await client.from(table).select(columns).eq(key, value).order('id').range(offset, offset + 499);
    if (r.error) throw r.error;
    rows.push(...r.data as T[]);
    if (r.data.length < 500) return rows;
  }
}
export function Recommendations({fallbackDestinations = []}: {fallbackDestinations?: Destination[]}) {
  const identity = useIdentity(); const [picks, setPicks] = useState<Picks | null>(null);
  const [covers, setCovers] = useState<Record<string, DestinationPhoto>>({});
  const [error, setError] = useState(''); const [version, setVersion] = useState(0);
  useEffect(() => {
    const refresh = () => setVersion(v => v + 1);
    window.addEventListener('travelmate:preferences', refresh);
    return () => window.removeEventListener('travelmate:preferences', refresh);
  }, []);
  useEffect(() => {
    let cancelled = false; setPicks(null); setCovers({}); setError('');
    void (async () => { try {
      const settings = await client.from('traveler_settings').select('interests').eq('profile_id', identity.id!).maybeSingle();
      if (settings.error) throw settings.error;
      const interests: string[] = settings.data?.interests ?? [];
      if (!interests.length) { if (!cancelled) setPicks({destinations: [], listings: [], interests: []}); return; }
      const [destinations, listings] = await Promise.all([
        catalog<Destination>('destinations', 'id,name,province,description', 'is_active', 1),
        catalog<ApprovedListing>('business_listings', 'id,name,is_sample,description,address,listing_type,destination_id,status', 'status', 'approved'),
      ]);
      if (cancelled) return;
      const result = recommendPlaces(destinations, listings, interests);
      const top = result.listings.slice(0, 3);
      const towns = result.destinations.slice(0, 3);
      const candidates = listings.filter(l => towns.some(d => d.place.id === l.destination_id));
      const photos = await photosFor([...new Map([...top.map(x => x.place), ...candidates].map(l => [l.id, l])).values()]);
      if (cancelled) return;
      const destinationCovers: Record<string, DestinationPhoto> = {};
      for (const {place} of towns) {
        const known = destinationPhoto(place.name, place.province);
        const listing = photos.find(l => l.destination_id === place.id && l.image);
        const picture = known ?? (listing?.image ? {src: listing.image, alt: listing.name, caption: listing.name + ' · ' + place.name} : undefined);
        if (picture) destinationCovers[place.id] = picture;
      }
      setCovers(destinationCovers);
      setPicks({...result, destinations: towns, listings: top.map(x => ({...x, place: {...x.place, ...photos.find(l => l.id === x.place.id)}}))});
    } catch (e) { if (!cancelled) setError(errorMessage(e)); } })();
    return () => {cancelled = true;};
  }, [identity.id, version]);
  const destinations = picks?.destinations.length ? picks.destinations : fallbackDestinations.slice(0, 3).map(place => ({place, interests: [] as string[]}));
  return <section className="tm-recommendations" aria-labelledby="tm-recommendations-title">
    <div className="tm-section-title"><div><p className="tm-eyebrow"><Sparkles size={14} aria-hidden="true"/>A LITTLE INSPIRATION</p><h2 id="tm-recommendations-title">Places to fall for.</h2></div><Button variant="ghost" onClick={() => navigate('/explore')}>All destinations<ArrowUpRight aria-hidden="true"/></Button></div>
    <div className="tm-home-recommendation-note"><p>{picks?.destinations.length ? 'A few destinations matched to your interests.' : picks?.interests.length ? 'Explore these destinations while we look for your next match.' : 'Start somewhere lovely. Add your interests for personal picks.'}</p><Button variant="ghost" size="sm" onClick={() => navigate('/preferences')}>{picks?.interests.length ? 'Edit interests' : 'Choose interests'}<ArrowUpRight aria-hidden="true"/></Button></div>
    {error ? <ErrorState message={error} retry={() => setVersion(v => v + 1)}/> : !picks ? <LoadingCards/> : !destinations.length ? <EmptyState title="More places are on their way">Explore all destinations or try again later.</EmptyState> : <>
      <div className="tm-card-grid tm-recommendation-grid">{destinations.map(({place, interests}) => <Card className="tm-recommended-destination" key={place.id}><DestinationCover key={covers[place.id]?.src ?? place.id} photo={covers[place.id] ?? destinationPhoto(place.name, place.province)}/><CardContent className="tm-recommended-content"><small><MapPin size={14} aria-hidden="true"/>{place.province.replace(/\s*\(geographic location\)/i,'')}</small><h3>{place.name}</h3><p className="tm-match-reason">{interests.length ? interests.map(i => interestLabels[i]).join(' · ') : 'Stays, local food & little detours.'}</p><div className="tm-recommendation-actions"><Button variant="outline" onClick={() => navigate('/destination/' + place.id)}>Explore places<ArrowUpRight aria-hidden="true"/></Button><Button variant="outline" size="icon" aria-label={'Plan a trip to '+place.name} title={'Plan a trip to '+place.name} onClick={() => planDestination(place.id)}><Plus aria-hidden="true"/></Button></div><PhotoCredit photo={covers[place.id]} compact/></CardContent></Card>)}</div>
      {!!picks.listings.length && <details className="tm-home-local-picks"><summary><Compass size={21} aria-hidden="true"/><span>Places you might like<small>{picks.listings.length} local stops matched to your interests</small></span><ChevronDown size={18} aria-hidden="true"/></summary><div className="tm-card-grid tm-recommended-listings">{picks.listings.map(({place, interests}) => <ListingCard key={place.id} listing={place} compact reason={'Matches: ' + interests.map(i => interestLabels[i]).join(', ')}/>)}</div></details>}
    </>}
  </section>;
}
