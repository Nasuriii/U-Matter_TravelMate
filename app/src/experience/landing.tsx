import { useEffect, useState } from 'react';
import { ArrowRight, ArrowUpRight, MapPin, Compass, BedDouble, Utensils, Check, CalendarDays, Building2, ClipboardCheck, Search, Route, Heart } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Card } from '../components/ui/card';
import { useClient, navigate, errorMessage, type Destination } from './state';
import { ErrorState } from './shared';
import { destinationPhoto } from './destination-photos';
import { DestinationCover, PhotoCredit } from './destination-picture';

export const beachPhoto = 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/San_Juan_Beach%2C_La_Union%2C_Jan_2024_%282%29.jpg/1280px-San_Juan_Beach%2C_La_Union%2C_Jan_2024_%282%29.jpg';
export function startPlanning() { sessionStorage.setItem('travelmate:entry-intent', 'traveler'); navigate('/register/traveler'); }
export function joinBusiness() { sessionStorage.setItem('travelmate:entry-intent', 'business_owner'); navigate('/register/business'); }
export function landingSection(id: string) {
  const scroll = () => requestAnimationFrame(() => document.getElementById(id)?.scrollIntoView({ behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth', block: 'start' }));
  if ((location.hash.slice(1) || '/') === '/') scroll();
  else { window.addEventListener('hashchange', scroll, { once: true }); navigate('/'); }
}

type Place = Destination & { count: number };
const steps = [
  { number: '01', icon: MapPin, title: 'Pick a place', text: 'Discover stays, local food, and things to do.' },
  { number: '02', icon: CalendarDays, title: 'Choose your dates', text: 'Start a draft you can come back to anytime.' },
  { number: '03', icon: Route, title: 'Make it yours', text: 'Bring your favorite stops into a day-by-day plan.' },
];
const browseLinks = [
  { path: '/stay', icon: BedDouble, label: 'Places to stay', tone: 'sage' },
  { path: '/eat', icon: Utensils, label: 'Places to eat', tone: 'peach' },
  { path: '/attractions', icon: Compass, label: 'Things to do', tone: 'lavender' },
];

export function Landing() {
  const { client, error: configurationError } = useClient();
  const [places, setPlaces] = useState<Place[]>([]);
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [version, setVersion] = useState(0);
  useEffect(() => {
    let cancelled = false; setLoading(true); setError('');
    if (!client) { setLoading(!configurationError); setError(configurationError); return; }
    void (async () => {
      try {
        const [destinations, listings] = await Promise.all([
          client.from('destinations').select('id,name,province,description').eq('is_active', 1).order('name'),
          client.from('business_listings').select('destination_id').eq('status', 'approved'),
        ]);
        if (destinations.error) throw destinations.error; if (listings.error) throw listings.error;
        const counts = new Map<string, number>();
        for (const row of listings.data ?? []) counts.set(row.destination_id, (counts.get(row.destination_id) || 0) + 1);
        if (!cancelled) setPlaces((destinations.data ?? []).map(d => ({ ...d, count: counts.get(d.id) || 0 })).sort((a, b) => b.count - a.count || a.name.localeCompare(b.name)));
      } catch (e) { if (!cancelled) setError(errorMessage(e)); }
      finally { if (!cancelled) setLoading(false); }
    })();
    return () => { cancelled = true; };
  }, [client, configurationError, version]);
  const filtered = places.filter(d => `${d.name} ${d.province}`.toLowerCase().includes(query.trim().toLowerCase()));
  const searchTerm = query.trim();
  function showResults() {
    landingSection('lp-destinations');
    document.getElementById('pub-destinations-title')?.focus({ preventScroll: true });
  }
  function clearSearch() {
    setQuery('');
    document.getElementById('pub-destinations-title')?.focus({ preventScroll: true });
  }

  return <div className="tm-landing pub-landing">
    <section className="pub-container pub-hero" aria-labelledby="pub-title">
      <div className="pub-hero-copy">
        <p className="pub-kicker">LA UNION & BAGUIO</p>
        <h1 id="pub-title">Less planning.<br /><span className="pub-heading-accent">More exploring.</span></h1>
        <p className="pub-lead">Find local favorites and bring them together in a trip that feels like you.</p>
        <div className="pub-actions"><Button size="lg" onClick={startPlanning}>Plan my trip<ArrowUpRight aria-hidden="true" /></Button></div>
        <p className="pub-reassurance"><Check size={17} aria-hidden="true" />Browse freely. Sign up when you’re ready to plan.</p>
        <form className="pub-hero-search" role="search" aria-label="Destination search" onSubmit={e => { e.preventDefault(); showResults(); }}>
          <label htmlFor="pub-destination-search">Search destinations</label>
          <div className="flex items-center gap-2"><Search size={20} aria-hidden="true" /><Input id="pub-destination-search" type="search" maxLength={100} value={query} onChange={e => setQuery(e.target.value)} placeholder="Search a town or province" /><Button type="submit" aria-label="Find destinations" size="icon"><ArrowRight aria-hidden="true" /></Button></div>
        </form>
        <nav className="pub-browse-links" aria-label="Browse local places">{browseLinks.map(({ path, icon: Icon, label, tone }) => <a href={'#' + path} key={path}><span className={'pub-icon-tile ' + tone}><Icon aria-hidden="true" /></span><span>{label}</span><ArrowUpRight className="pub-browse-arrow" size={15} aria-hidden="true" /></a>)}</nav>
      </div>
      <div className="pub-hero-visual">
        <div className="pub-hero-photo"><img src={beachPhoto} alt="Waves rolling onto San Juan Beach in La Union" fetchPriority="high" onError={e => { e.currentTarget.hidden = true; }} /><span className="pub-photo-location"><MapPin size={16} aria-hidden="true" />San Juan, La Union</span></div>
        <Card className="pub-day-note">
          <Compass size={24} aria-hidden="true" />
          <h2>A little room<br />for <span className="pub-heading-accent">discovery.</span></h2>
          <p>Your destination. Your pace.</p>
        </Card>
      </div>
    </section>
    <section id="lp-destinations" className="pub-container pub-section" aria-labelledby="pub-destinations-title">
      <div className="pub-section-heading pub-destination-heading"><div><h2 id="pub-destinations-title" tabIndex={-1}>{searchTerm ? `Results for “${searchTerm}”` : 'Explore destinations'}</h2><p role="status" aria-live="polite">{!loading && !error ? searchTerm ? `${filtered.length} ${filtered.length === 1 ? 'destination' : 'destinations'} found` : 'A few local favorites to get you started.' : 'Find your next stop in La Union and Baguio.'}</p></div>{searchTerm && <Button variant="outline" onClick={clearSearch}>Clear search</Button>}</div>
      {error && <ErrorState message={error} retry={() => setVersion(v => v + 1)} />}
      {loading && <div className="pub-loading" role="status">Finding your next stop…</div>}
      {!loading && !error && <div className="pub-destination-grid">{filtered.slice(0, searchTerm ? 30 : 4).map(d => <div key={d.id}><button className="pub-destination-card" data-place-preview="destination" data-place-id={d.id} data-place-name={d.name} data-place-area={d.province} data-place-image={destinationPhoto(d.name, d.province)?.src} onClick={() => navigate('/destination/' + d.id)} aria-label={'Explore ' + d.name}><DestinationCover photo={destinationPhoto(d.name, d.province)} /><div className="pub-destination-copy"><p><MapPin size={14} aria-hidden="true" />{d.province.replace(' (geographic location)', '')}</p><div><h3>{d.name}</h3><span className="pub-card-arrow"><ArrowUpRight size={20} aria-hidden="true" /></span></div><span>{d.count ? `${d.count} local ${d.count === 1 ? 'place' : 'places'}` : 'Discover this destination'}</span></div></button><PhotoCredit photo={destinationPhoto(d.name, d.province)} /></div>)}</div>}
      {!loading && !error && !filtered.length && <Card className="pub-empty"><Search aria-hidden="true" /><h3>No destinations found</h3><p>Try a different town or province, or return to the featured places.</p><Button variant="outline" onClick={clearSearch}>Show featured destinations</Button></Card>}
    </section>
    <section id="lp-how" className="pub-how" aria-labelledby="pub-how-title"><div className="pub-container pub-section">
      <div className="pub-section-heading"><div><h2 id="pub-how-title">From a place to a plan.</h2></div></div>
      <div className="grid gap-6 md:grid-cols-3 pub-steps">{steps.map(({ number, icon: Icon, title, text }) => <div key={number}><div className="pub-step-top"><Icon size={25} aria-hidden="true" /><span className="pub-andy">{number}</span></div><h3>{title}</h3><p>{text}</p></div>)}</div>
      <div className="pub-how-bottom"><p><CalendarDays size={17} aria-hidden="true" />Your itinerary is a plan. Reservations are confirmed separately.</p></div>
    </div></section>
    <section id="lp-business" className="pub-container pub-section" aria-labelledby="pub-business-title"><div className="pub-business">
      <div><p className="pub-kicker">FOR THE PEOPLE BEHIND THE PLACES</p><h2 id="pub-business-title">Be part of their<br /><span className="pub-heading-accent">next adventure.</span></h2><p>Run a hotel, restaurant, or attraction? Help travelers discover what makes your place special.</p><Button size="lg" onClick={joinBusiness}>List my business<ArrowUpRight aria-hidden="true" /></Button><p className="pub-business-note">Submit your listing. Go live after administrator approval.</p></div>
      <div className="pub-business-features">{[{ icon: Building2, title: 'Put your place on the map', text: 'Share your photos, amenities, and business details.' }, { icon: ClipboardCheck, title: 'Keep guests in view', text: 'Manage hotel and restaurant reservations in your portal.' }, { icon: Heart, title: 'Make a lasting impression', text: 'Give travelers a place to discover and save your business.' }].map(({ icon: Icon, title, text }) => <div key={title}><span className="pub-icon-tile"><Icon aria-hidden="true" /></span><div><h3>{title}</h3><p>{text}</p></div></div>)}</div>
    </div></section>
    <div className="lp-photo-credit">San Juan Beach photo by <a href="https://commons.wikimedia.org/wiki/File:San_Juan_Beach,_La_Union,_Jan_2024_(2).jpg" target="_blank" rel="noreferrer">Ralff Nestor Nacor</a> · <a href="https://creativecommons.org/licenses/by-sa/4.0/" target="_blank" rel="noreferrer">CC BY-SA 4.0</a> · displayed cropped.</div>
  </div>;
}
