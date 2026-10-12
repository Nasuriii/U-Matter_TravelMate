import {useEffect, useId, useRef, useState, type CSSProperties} from 'react';
import {createPortal} from 'react-dom';
import {ArrowRight, ArrowUpRight, BedDouble, Compass, LoaderCircle, MapPin, Search, Utensils, X} from 'lucide-react';
import {Button} from '../components/ui/button';
import {normalizePlaceQuery, placeContainsFilter, selectSearchPreviews, type SearchPlace} from '../place-search-results';
import {client, errorMessage, navigate, photosFor, type Destination, type Listing} from './state';
import {destinationPhoto} from './destination-photos';

const kinds = {destination: {label: 'Destination', icon: MapPin}, restaurant: {label: 'Restaurant', icon: Utensils}, attraction: {label: 'Attraction', icon: Compass}, hotel: {label: 'Stay', icon: BedDouble}};
type SearchState = {query: string; places: SearchPlace[]; loading: boolean; error: string};
type Position = {style: CSSProperties; above: boolean; compact: boolean};
function PreviewCard({place, id, selected, hover, close}: {place: SearchPlace; id: string; selected: boolean; hover: () => void; close: () => void}) {
  const [failed, setFailed] = useState(false);
  const {label, icon: Icon} = kinds[place.kind];
  return <a id={id} href={'#' + place.path} role="option" aria-selected={selected} tabIndex={-1} className="tm-search-preview-card" onPointerEnter={hover} onClick={close}>
    <span className="tm-search-preview-photo"><Icon size={30} aria-hidden="true"/>{place.image && !failed && <img src={place.image} alt="" onError={() => setFailed(true)}/>}<span className="tm-search-preview-kind"><Icon size={12} aria-hidden="true"/>{label}</span><ArrowUpRight className="tm-search-preview-open" size={18} aria-hidden="true"/></span>
    <span className="tm-search-preview-caption"><span className="tm-search-preview-type">{label}</span><strong>{place.name}</strong><small>{place.area}</small></span>
  </a>;
}

export function PlaceSearch({onSearch}: {onSearch: (query: string) => void}) {
  const [query, setQuery] = useState(''), [open, setOpen] = useState(false), [active, setActive] = useState(-1), [retry, setRetry] = useState(0);
  const [state, setState] = useState<SearchState>({query: '', places: [], loading: false, error: ''});
  const [position, setPosition] = useState<Position | null>(null);
  const form = useRef<HTMLFormElement>(null), input = useRef<HTMLInputElement>(null), panel = useRef<HTMLDivElement>(null);
  const keyboardSelection = useRef(false);
  const destinations = useRef<Destination[] | null>(null), cache = useRef(new Map<string, SearchPlace[]>());
  const listId = useId(), term = normalizePlaceQuery(query), eligible = term.length >= 2;
  const current = state.query === term ? state : {query: term, places: [], loading: true, error: ''};
  const visible = open && eligible && position !== null;
  const close = () => {setOpen(false);setActive(-1);};
  const openPlace = (place: SearchPlace) => {close();navigate(place.path);};

  useEffect(() => {
    if (!open || !eligible) return;
    const controller = new AbortController();
    const key = term.toLocaleLowerCase(), cached = cache.current.get(key);
    setActive(-1);
    if (cached) {setState({query: term, places: cached, loading: false, error: ''});return;}
    setState({query: term, places: [], loading: true, error: ''});
    const timer = window.setTimeout(() => void (async () => {
      try {
        if (!destinations.current) {
          const towns: Destination[] = [];
          for (let offset = 0; ; offset += 500) {
            const response = await client.from('destinations').select('id,name,province,description').eq('is_active', 1).order('id').range(offset, offset + 499).abortSignal(controller.signal);
            if (response.error) throw response.error;
            towns.push(...response.data ?? []);
            if ((response.data?.length ?? 0) < 500) break;
          }
          if (controller.signal.aborted) return;
          destinations.current = towns;
        }
        const towns = destinations.current;
        const matched = towns.filter(town => (town.name + ' ' + town.province).toLocaleLowerCase().includes(key));
        const pattern = placeContainsFilter(term);
        const filters = ['name.ilike.' + pattern, 'address.ilike.' + pattern];
        if (matched.length) filters.push('destination_id.in.(' + matched.map(town => town.id).join(',') + ')');
        const responses = towns.length ? await Promise.all((['restaurant', 'attraction', 'hotel'] as const).map(kind => client.from('business_listings').select('id,name,is_sample,listing_type,address,description,destination_id').eq('status', 'approved').eq('listing_type', kind).in('destination_id', towns.map(town => town.id)).or(filters.join(',')).order('name').limit(12).abortSignal(controller.signal))) : [];
        for (const response of responses) if (response.error) throw response.error;
        if (controller.signal.aborted) return;
        const listings: Listing[] = responses.flatMap(response => response.data ?? []);
        const places: SearchPlace[] = [...matched.map(town => ({id: town.id, name: town.name, kind: 'destination' as const, area: town.province.replace(/\s*\(geographic location\)/i, ''), image: destinationPhoto(town.name, town.province)?.src, path: '/destination/' + town.id})), ...listings.map(listing => ({id: listing.id, name: listing.name, kind: listing.listing_type, area: towns.find(town => town.id === listing.destination_id)?.name ?? listing.address ?? '', path: '/listing/' + listing.id}))];
        const selected = selectSearchPreviews(term, places);
        const photos = await photosFor(listings.filter(listing => selected.some(place => place.kind !== 'destination' && place.id === listing.id)));
        if (controller.signal.aborted) return;
        const preview = selected.map(place => {const listing = photos.find(photo => photo.id === place.id);return listing ? {...place, name: listing.name, image: listing.image} : place;});
        if (cache.current.size >= 12) cache.current.delete(cache.current.keys().next().value!);
        cache.current.set(key, preview);
        setState({query: term, places: preview, loading: false, error: ''});
      } catch (error) {if (!controller.signal.aborted) setState({query: term, places: [], loading: false, error: errorMessage(error)});}
    })(), 200);
    return () => {window.clearTimeout(timer);controller.abort();};
  }, [term, open, eligible, retry]);

  useEffect(() => {
    if (!open || !eligible) return;
    const placePanel = () => {
      const anchor = form.current?.getBoundingClientRect();
      if (!anchor) return;
      const viewport = window.visualViewport;
      const width = viewport?.width ?? window.innerWidth, height = viewport?.height ?? window.innerHeight;
      const top = viewport?.offsetTop ?? 0, left = viewport?.offsetLeft ?? 0;
      if (anchor.bottom <= top + 72 || anchor.top >= top + height) {close();return;}
      const panelWidth = Math.min(680, width - 24);
      const aboveSpace = anchor.top - top - 86, belowSpace = top + height - anchor.bottom - 20;
      const above = belowSpace < 260 && aboveSpace > belowSpace;
      const maxHeight = Math.max(100, Math.min(480, above ? aboveSpace : belowSpace));
      setPosition({above, compact: maxHeight < 300, style: {width: panelWidth, left: Math.max(left + 12, Math.min(anchor.left, left + width - panelWidth - 12)), maxHeight, ...(above ? {bottom: window.innerHeight - anchor.top + 8} : {top: anchor.bottom + 8})}});
    };
    const outside = (event: Event) => {if (event.target instanceof Node && !form.current?.contains(event.target) && !panel.current?.contains(event.target)) close();};
    const escape = (event: KeyboardEvent) => {if (event.key === 'Escape') {input.current?.focus({preventScroll: true});close();}};
    placePanel();
    window.addEventListener('resize', placePanel);
    window.addEventListener('scroll', placePanel, true);
    window.visualViewport?.addEventListener('resize', placePanel);
    window.visualViewport?.addEventListener('scroll', placePanel);
    document.addEventListener('pointerdown', outside);
    document.addEventListener('focusin', outside);
    document.addEventListener('keydown', escape);
    return () => {window.removeEventListener('resize', placePanel);window.removeEventListener('scroll', placePanel, true);window.visualViewport?.removeEventListener('resize', placePanel);window.visualViewport?.removeEventListener('scroll', placePanel);document.removeEventListener('pointerdown', outside);document.removeEventListener('focusin', outside);document.removeEventListener('keydown', escape);};
  }, [open, eligible]);

  useEffect(() => {
    if (!keyboardSelection.current || active < 0 || !visible) return;
    keyboardSelection.current = false;
    const results = panel.current?.querySelector<HTMLElement>('.tm-search-preview-results');
    const selected = document.getElementById(listId + '-' + active);
    if (!results || !selected) return;
    const bounds = results.getBoundingClientRect(), card = selected.getBoundingClientRect();
    // Scroll only the results, so selecting a suggestion never moves the page.
    if (card.top < bounds.top) results.scrollTop += card.top - bounds.top - 4;
    else if (card.bottom > bounds.bottom) results.scrollTop += card.bottom - bounds.bottom + 4;
  }, [active, visible, listId]);
  const browse = () => {close();onSearch(term);};
  return <><form ref={form} className="tm-destination-search tm-home-search" role="search" onSubmit={event => {event.preventDefault();if (visible && current.places.length && !current.loading) openPlace(current.places[active >= 0 ? active : 0]);else browse();}}>
    <Search size={21} aria-hidden="true"/><input ref={input} id="tm-home-search" type="search" role="combobox" aria-label="Search places" aria-autocomplete="list" aria-haspopup="listbox" aria-expanded={visible} aria-controls={visible ? listId : undefined} aria-activedescendant={visible && active >= 0 ? listId + '-' + active : undefined} autoComplete="off" maxLength={100} value={query} placeholder="Search places" onClick={() => {if (eligible) setOpen(true);}} onFocus={() => {if (eligible) setOpen(true);}} onChange={event => {setQuery(event.target.value);setActive(-1);setOpen(normalizePlaceQuery(event.target.value).length >= 2);}} onKeyDown={event => {if (event.key === 'Escape') {event.preventDefault();close();}else if (['ArrowDown', 'ArrowUp'].includes(event.key) && eligible) {event.preventDefault();setOpen(true);if (current.places.length) {keyboardSelection.current = true;setActive(index => (index + (event.key === 'ArrowDown' ? 1 : index < 0 ? 0 : -1) + current.places.length) % current.places.length);}}}}/><Button type="submit" size="icon" variant="ghost" aria-label="Search places"><ArrowRight aria-hidden="true"/></Button>
  </form>{visible && createPortal(<div ref={panel} className="tm-react tm-search-preview" style={position.style} data-side={position.above ? 'above' : 'below'} data-compact={position.compact}>
    <div className="tm-search-preview-header"><div><Search size={17} aria-hidden="true"/><strong>Places for “{term}”</strong></div><button type="button" aria-label="Close search preview" onClick={close}><X size={19} aria-hidden="true"/></button></div>
    <div className="tm-search-preview-status" role="status" aria-live="polite">{current.loading ? 'Finding places…' : current.error ? 'Search couldn’t be loaded.' : current.places.length ? current.places.length + ' suggestions. Use the arrow keys to select a place.' : 'No matching places.'}</div>
    <div id={listId} role="listbox" aria-label="Suggested places" aria-busy={current.loading} className="tm-search-preview-results">{current.loading ? <div className="tm-search-preview-message"><LoaderCircle size={24} className="tm-search-preview-spinner" aria-hidden="true"/><p>Finding your next stop…</p></div> : current.error ? <div className="tm-search-preview-message"><p>We couldn’t load suggestions. Please try again.</p><Button variant="outline" onClick={() => setRetry(value => value + 1)}>Try again</Button></div> : !current.places.length ? <div className="tm-search-preview-message"><Compass size={28} aria-hidden="true"/><p>No places found for “{term}”.</p><small>Try a town, restaurant, or attraction name.</small></div> : <div className="tm-search-preview-grid">{current.places.map((place, index) => <PreviewCard key={place.path + (place.image ?? '')} place={place} id={listId + '-' + index} selected={active === index} hover={() => setActive(index)} close={close}/>)}</div>}</div>
    <div className="tm-search-preview-footer"><span>↑ ↓ to choose · Enter to open</span><button type="button" onClick={browse}>Browse destinations<ArrowUpRight size={15} aria-hidden="true"/></button></div>
  </div>, document.body)}</>;
}
