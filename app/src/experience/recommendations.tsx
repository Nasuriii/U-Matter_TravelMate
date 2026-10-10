import { useEffect, useState } from 'react';
import { ArrowUpRight, Sparkles } from 'lucide-react';
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
export function Recommendations() {
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
  return <section className="tm-recommendations" aria-labelledby="tm-recommendations-title">
    <div className="tm-section-title"><div><p className="tm-eyebrow"><Sparkles size={14}/>YOUR KIND OF GETAWAY</p><h2 id="tm-recommendations-title">Recommended for you</h2></div><Button variant="ghost" onClick={() => navigate('/preferences')}>Change preferences<ArrowUpRight/></Button></div>
    {error ? <ErrorState message={error} retry={() => setVersion(v => v + 1)}/> : !picks ? <LoadingCards/> : !picks.interests.length ?
      <EmptyState title="What does your kind of trip look like?" action={<Button variant="outline" onClick={() => navigate('/preferences')}>Choose your interests<ArrowUpRight/></Button>}>Choose beaches, mountains, food, or whatever you love to get personal suggestions. You can also explore destinations below.</EmptyState> : <>
      <div className="tm-recommendation-interests">{picks.interests.map(i => <span className="tm-pill" key={i}>{interestLabels[i]}</span>)}</div>
      <p className="tm-recommendation-intro tm-muted">Matched to your interests using destination and approved business details.</p>
      {!picks.destinations.length && <EmptyState title="Your next match is still on its way">We haven’t found catalog matches for these interests yet. Explore destinations below or change your preferences.</EmptyState>}
      <div className="tm-card-grid tm-recommendation-grid">{picks.destinations.map(({place, interests}) => <Card className="tm-recommended-destination" key={place.id}><DestinationCover key={covers[place.id]?.src ?? place.id} photo={covers[place.id]}/><CardContent className="tm-recommended-content"><small>{place.province}</small><h3>{place.name}</h3><p className="tm-match-reason">Matches your interests: {interests.map(i => interestLabels[i]).join(', ')}.</p><div className="tm-recommendation-actions"><Button variant="outline" onClick={() => navigate('/destination/' + place.id)}>Explore places<ArrowUpRight/></Button><Button onClick={() => planDestination(place.id)}>Plan a trip here<ArrowUpRight/></Button></div><PhotoCredit photo={covers[place.id]} compact/></CardContent></Card>)}</div>
      {!!picks.listings.length && <><div className="tm-recommended-places-heading"><h3>Places you might like</h3><p className="tm-muted">A few local stops to make the trip your own.</p></div><div className="tm-card-grid tm-recommended-listings">{picks.listings.map(({place, interests}) => <ListingCard key={place.id} listing={place} compact reason={'Matches: ' + interests.map(i => interestLabels[i]).join(', ')}/>)}</div></>}
    </>}
  </section>;
}
