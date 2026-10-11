import { useEffect, useState } from 'react';
import { ArrowUpRight, BedDouble, ChevronLeft, ChevronRight, Compass, Search, Utensils, X } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Card, CardContent } from '../components/ui/card';
import { catalogLabel } from '../catalog-label';
import { listingPage, listingRange } from '../listing-pagination';
import type { Overview } from './home';

const types = { hotel: { label: 'Hotel', icon: BedDouble }, restaurant: { label: 'Restaurant', icon: Utensils }, attraction: { label: 'Attraction', icon: Compass } };
const statusLabel: Record<string, string> = { approved: 'Live', pending: 'Awaiting review', rejected: 'Needs changes', inactive: 'Inactive' };

export function BusinessDirectory({ businesses, admin, status, setStatus, open, manage }: {
  businesses: Overview['businesses']; admin: boolean; status: string; setStatus: (status: string) => void;
  open: (id: string) => void; manage: () => void;
}) {
  const [query, setQuery] = useState(''), [type, setType] = useState('all'), [page, setPage] = useState(1);
  useEffect(() => setPage(1), [query, type, status]);
  const filtered = businesses.filter(b => (status === 'all' || b.status === status) && (type === 'all' || b.listing_type === type) && catalogLabel(b.name).toLowerCase().includes(query.trim().toLowerCase()));
  const result = listingPage(filtered, page), activeFilters = !!query || type !== 'all' || status !== 'all';
  return <Card id="tm-business-directory" className="tm-business-directory"><CardContent className="p-6">
    <div className="tm-section-title"><div><p className="tm-eyebrow">{admin ? 'BUSINESS DIRECTORY' : 'YOUR BUSINESSES'}</p><h2>{admin ? 'Listings at a glance' : 'Listing performance'}</h2></div><Button variant="outline" onClick={manage}>Manage listings<ArrowUpRight /></Button></div>
    <div className="tm-business-filters">
      <label className="tm-business-search"><span>Search businesses</span><div><Search size={19}/><input type="search" maxLength={120} placeholder="Business name" value={query} onChange={e => setQuery(e.target.value)}/></div></label>
      <label><span>Type</span><select value={type} onChange={e => setType(e.target.value)}><option value="all">All types</option><option value="hotel">Hotels</option><option value="restaurant">Restaurants</option><option value="attraction">Attractions</option></select></label>
      <label><span>Status</span><select value={status} onChange={e => setStatus(e.target.value)}><option value="all">All statuses</option><option value="approved">Live</option><option value="pending">Awaiting review</option><option value="rejected">Needs changes</option><option value="inactive">Inactive</option></select></label>
      {activeFilters && <Button variant="ghost" onClick={() => { setQuery(''); setType('all'); setStatus('all'); setPage(1); }}><X size={17}/>Clear</Button>}
    </div>
    <div className="tm-business-results" role="status" aria-live="polite">{listingRange(result)}</div>
    {result.items.length ? <><div className="tm-business-columns" aria-hidden="true"><span>Business</span><span>Status</span><span>Views · 30 days</span><span>Bookings</span></div>
      <ul className="tm-business-list">{result.items.map(b => {
        const kind = types[b.listing_type as keyof typeof types] || types.attraction, Icon = kind.icon;
        return <li key={b.id}>
          <button type="button" className="tm-business-name" onClick={() => open(b.id)} aria-label={'View performance for ' + catalogLabel(b.name)}><span className={'o-listing-icon type-' + b.listing_type}><Icon size={21}/></span><span><strong>{catalogLabel(b.name)}</strong><small>{kind.label}</small></span><ArrowUpRight size={17}/></button>
          <span className={'tm-status tm-status-' + b.status}>{statusLabel[b.status] || b.status}</span>
          <div className="tm-business-value"><span>Views · 30 days</span><strong>{b.views.toLocaleString()}</strong></div>
          <div className="tm-business-value"><span>Bookings · all time</span><strong>{b.bookings.toLocaleString()}</strong></div>
        </li>;
      })}</ul></> : <div className="tm-business-empty"><Search size={25}/><strong>{businesses.length ? 'No matching businesses' : 'Your first listing belongs here'}</strong><p>{businesses.length ? 'Try another name or clear your filters.' : 'Add a business, then submit it for review.'}</p>{!businesses.length && !admin && <Button onClick={manage}>Add a listing<ArrowUpRight/></Button>}</div>}
    <nav className="tm-listing-pagination" aria-label="Business directory pages"><p>{result.total ? `${result.total} ${result.total === 1 ? 'listing' : 'listings'}${businesses.length === 200 ? ' · latest 200' : ''}` : '0 listings'}</p>{result.pages > 1 && <div className="tm-page-controls"><Button variant="outline" aria-label="Previous page of businesses" disabled={result.page === 1} onClick={() => setPage(result.page - 1)}><ChevronLeft size={17}/>Previous</Button><span>Page {result.page} of {result.pages}</span><Button variant="outline" aria-label="Next page of businesses" disabled={result.page === result.pages} onClick={() => setPage(result.page + 1)}>Next<ChevronRight size={17}/></Button></div>}</nav>
    <details className="tm-business-metric-help"><summary>What do these numbers mean?</summary><p>Views count listing opens by signed-in users in the last 30 days. Bookings count all reservations, including cancelled and expired ones. Select a business to see its performance.</p></details>
  </CardContent></Card>;
}
