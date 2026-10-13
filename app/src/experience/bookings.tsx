import {DateTimeRangeFields,DateRangeFields} from '../trip-pickers';
import {BookingRestriction} from './account-appeals';
import {toast} from '../ui';
import {FoldedTicket,ticketDate} from './folded-ticket';
import {PreviewReservations} from './preview-reservations';
import {RoomChoices,GuestCount} from './booking-controls';
import {ReservationSlots} from './reservation-slots';
import {FilterSelect} from './filter-select';
import {PageNavigation} from './page-navigation';
import { useEffect, useRef, useState } from 'react';
import { ArrowLeft, ArrowUpRight, BedDouble, CalendarDays, Check, Clock3, Download, RefreshCw, Ticket, Users, Plus, Star, CheckCircle2, Trash2, CircleX, ChevronDown } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Card, CardContent } from '../components/ui/card';
import { confirmAction } from '../action-confirm';
import { client, useIdentity, currentIdentity, navigate, errorMessage, money, isSuspended } from './state';
import { listingDetail } from './catalog';
import { EmptyState, ErrorState, LoadingCards, PageHeading } from './shared';
type Booking = { id: string; booking_type: string; guest_name: string; guest_email: string; guest_phone: string | null; guest_count: number; total_amount: number; status: string; payment_status: string | null; is_test?:boolean; can_delete?:boolean; can_cancel?:boolean; starts_at: string | null; ends_at: string | null; listing_id: string; listing_name: string; room_type: string | null; room_number: string | null; hold_expires_at: string | null; created_at: string };
const readableDate=(value:string)=>value?new Date(value+'T12:00:00').toLocaleDateString('en-PH',{month:'short',day:'numeric',year:'numeric'}):'Choose a date';
const today = () => { const date = new Date(); return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`; };
async function checkout(bookingId: string) {
  if(isSuspended())throw new Error('Bookings and payments are paused while your account is suspended.');
  const { data, error } = await client.functions.invoke('create-checkout', { body: { bookingId, returnOrigin: location.origin } });
  if (error) { let message = error.message; if ('context' in error && error.context instanceof Response) { const body = await error.context.json().catch(() => null); if (body?.error) message = body.error; } throw new Error(message); }
  if (data?.error) throw new Error(data.error);
  const url = new URL(data?.url); if (url.protocol !== 'https:' || url.hostname !== 'checkout.stripe.com') throw new Error('The payment provider returned an unexpected checkout URL.');
  location.assign(url.href);
}
export function BookingPage({ id, room: selectedRoom }: { id: string; room: string | null }) {
  const identity = useIdentity(); const [detail, setDetail] = useState<Awaited<ReturnType<typeof listingDetail>> | null>(null); const [error, setError] = useState(''); const [version, setVersion] = useState(0); const [busy, setBusy] = useState(false); const [bookingId, setBookingId] = useState<string | null>(null);
  const [preview,setPreview]=useState(false),[previewId,setPreviewId]=useState<string|null>(null);
  const [form, setForm] = useState({ room: selectedRoom || '', slot: '', start: '', end: '', guests: '1', name: identity.name, email: identity.email, phone: '' }); const requestKey = useRef(crypto.randomUUID());
  useEffect(() => { let cancelled = false; setDetail(null); setError(''); void listingDetail(id).then(data => { if (cancelled) return; if (data.listing.listing_type === 'attraction') throw new Error('Online attraction tickets are not configured. Add this visit to your itinerary instead.'); setDetail(data); }).catch(e => { if (!cancelled) setError(errorMessage(e)); }); return () => { cancelled = true; }; }, [id, identity.id, version]);
  const update = (key: keyof typeof form, value: string) => { setForm(old => ({ ...old, [key]: value })); requestKey.current = crypto.randomUUID(); setError(''); };
  const hotel = detail?.listing.listing_type === 'hotel'; const room = detail?.rooms.find(r => r.id === form.room); const nights = form.start && form.end ? Math.max(0, Math.round((Date.parse(form.end) - Date.parse(form.start)) / 86400000)) : 0; const amount = hotel ? Number(room?.base_nightly_rate ?? 0) * nights : Number(detail?.reservationFee ?? 0);
  async function submit(event: React.FormEvent) {
    event.preventDefault(); if (!detail || busy || isSuspended()) return; const userId = identity.id; const snapshot = { ...form }; const key = requestKey.current;
    if (hotel && (!room || room.operational_status !== 'available' || form.start < today() || nights < 1 || nights > 90 || Number(form.guests) > room.max_guests)) { setError('Choose valid dates and an available room with space for your guests.'); return; }
    if (!hotel && !detail.slots.some(s => s.id === form.slot && s.capacity >= Number(form.guests))) { setError('Choose an upcoming time slot with enough seats.'); return; }
    setBusy(true);
    try {
      const summary=[{label:'Place',value:detail.listing.name},...(hotel?[{label:'Room',value:room!.room_type+' · Room '+room!.room_number},{label:'Check-in',value:readableDate(snapshot.start)},{label:'Check-out',value:readableDate(snapshot.end)},{label:'Duration',value:nights+' '+(nights===1?'night':'nights')}]:[{label:'Date & time',value:new Date(detail.slots.find(s=>s.id===snapshot.slot)!.starts_at).toLocaleString('en-PH',{month:'short',day:'numeric',year:'numeric',hour:'numeric',minute:'2-digit'})}]),{label:'Guests',value:snapshot.guests+' · '+snapshot.name},{label:hotel?'Estimated stay total':'Reservation fee',value:money(amount)}];
      if (!await confirmAction('Review your reservation',detail.listing.preview?'Save a confirmed test reservation with a ticket. No payment will be taken.':amount>0?'A 35-minute room or table hold will be created. Complete secure checkout to confirm your booking.':'No reservation payment is required.',amount>0&&!detail.listing.preview?'Reserve & continue':'Confirm reservation','Keep editing',summary)) return;
      if (currentIdentity().id !== userId || currentIdentity().role !== 'traveler'||isSuspended()) return;
      const { data, error: problem } = await client.rpc('reserve_my_booking', { p_listing: id, p_room: hotel ? snapshot.room : null, p_slot: hotel ? null : snapshot.slot, p_check_in: hotel ? snapshot.start : null, p_check_out: hotel ? snapshot.end : null, p_guests: Number(snapshot.guests), p_name: snapshot.name.trim(), p_email: snapshot.email.trim(), p_phone: snapshot.phone.trim() || null, p_key: key }); if (problem) throw problem;
      if (currentIdentity().id !== userId) return; setBookingId(String(data));toast(detail.listing.preview?'Reservation saved in Bookings & tickets.':amount>0?'Reservation hold saved. Continue to payment.':'Reservation saved successfully.');
      if(detail.listing.preview){setPreviewId(String(data));setPreview(true);}else if (amount > 0) await checkout(String(data)); else navigate('/bookings');
    } catch (e) { if (currentIdentity().id === userId) setError(errorMessage(e)); } finally { setBusy(false); }
  }
  if(isSuspended(identity))return <div className="tm-page"><Button variant="ghost" onClick={()=>navigate('/listing/'+id)}><ArrowLeft/>Back to listing</Button><PageHeading eyebrow="YOUR ACCOUNT" title="New bookings are paused" description="You can continue exploring while your account is suspended."/><BookingRestriction/></div>;
  return <div className="tm-page"><Button variant="ghost" onClick={() => navigate('/listing/' + id)}><ArrowLeft />Back to listing</Button><PageHeading eyebrow="A GOOD TRIP STARTS WITH THE DETAILS" title="Review your reservation" description="Review your dates, guest details, and reservation before continuing." />{preview&&<div className="tm-reservation-ready" role="status"><span className="tm-ready-icon"><CheckCircle2 size={30}/></span><div><span className="tm-ready-label">SAVED TO YOUR BOOKINGS</span><h2>Reservation confirmed</h2><p>{detail?.listing.name} · {form.guests} guest(s) · {money(amount)}</p><p>{hotel?`${readableDate(form.start)} → ${readableDate(form.end)} · ${nights} nights`:new Date(detail?.slots.find(s=>s.id===form.slot)?.starts_at||'').toLocaleString('en-PH')}</p><p className="tm-ready-disclaimer">Reference · {previewId?.slice(0,8).toUpperCase()} · no charge</p></div><div className="tm-ready-actions"><Button onClick={()=>navigate('/bookings')}><Ticket/>View my reservations</Button><Button variant="outline" onClick={()=>{setPreview(false);setBookingId(null);requestKey.current=crypto.randomUUID();}}>Plan another reservation</Button></div></div>}{!detail ? error ? <ErrorState message={error} retry={() => setVersion(x => x + 1)} /> : <LoadingCards /> : <div className="tm-booking-layout"><Card><CardContent className="p-6"><div className="tm-booking-steps"><span><Check size={14} />Choose a place</span><span className="active">2 · Reservation</span><span>3 · {detail.listing.preview?'Ticket':'Checkout'}</span></div><form onSubmit={submit}><fieldset disabled={busy || !!bookingId || preview} className="tm-booking-fields">{hotel ? <><RoomChoices rooms={detail.rooms} value={form.room} change={id=>update('room',id)}/><DateRangeFields start={form.start} end={form.end} disabled={busy||!!bookingId||preview} onChange={(start,end)=>{setForm(old=>({...old,start,end}));requestKey.current=crypto.randomUUID();setError('');}}/></> : <ReservationSlots slots={detail.slots} value={form.slot} guests={Number(form.guests)} change={id=>update('slot',id)}/>}<GuestCount value={form.guests} max={hotel?room?.max_guests??100:detail.slots.find(slot=>slot.id===form.slot)?.capacity??100} change={value=>update('guests',value)}/><h2>Guest information</h2><label htmlFor="tm-guest-name">Full name<input id="tm-guest-name" required minLength={2} maxLength={150} autoComplete="name" value={form.name} onChange={e => update('name', e.target.value)} /></label><label htmlFor="tm-guest-email">Email address<input id="tm-guest-email" type="email" required maxLength={150} autoComplete="email" value={form.email} onChange={e => update('email', e.target.value)} /></label><label htmlFor="tm-guest-phone">Phone number <span className="tm-muted">(optional)</span><input id="tm-guest-phone" type="tel" maxLength={30} autoComplete="tel" value={form.phone} onChange={e => update('phone', e.target.value)} /></label><Button className="w-full" type="submit" disabled={busy}>Review reservation<ArrowRightIcon /></Button></fieldset></form>{error && <div className="tm-error mt-4" role="alert"><p>{error}</p>{bookingId && <p>Your reservation hold was saved. Retry checkout below or find it under Bookings & tickets.</p>}</div>}{bookingId && <div className="mt-4 flex flex-wrap gap-3"><Button disabled={busy} onClick={async () => { setBusy(true); try { await checkout(bookingId); } catch (e) { setError(errorMessage(e)); } finally { setBusy(false); } }}>Retry secure checkout<ArrowUpRight /></Button><Button variant="outline" onClick={() => navigate('/bookings')}>My bookings</Button></div>}</CardContent></Card><Card className="tm-booking-summary"><CardContent className="p-6"><span className="tm-pill"><Ticket size={14} />YOUR RESERVATION</span><h2>{detail.listing.name}</h2>{detail.listing.preview&&<p className="tm-preview-note">Test inventory · booking saved, no charge.</p>}<p className="tm-muted">{detail.listing.address}</p><div className="tm-health-row"><span>{hotel ? 'Room' : 'Reservation'}</span><strong>{hotel ? room?.room_type || 'Choose a room' : 'Table reservation'}</strong></div>{hotel && <div className="tm-health-row"><span>Nights</span><strong>{nights || '—'}</strong></div>}<div className="tm-health-row"><span>Guests</span><strong>{form.guests}</strong></div><div className="tm-booking-total"><span>{hotel ? 'Estimated total' : 'Reservation fee'}</span><strong>{money(amount)}</strong></div><p className="tm-data-note">{detail.listing.preview?'Test inventory rates. No payment is taken.':hotel?'The database checks room availability and calculates your final total.':'Food and drinks are separate. The database checks remaining seats before reserving.'} {detail.listing.preview?'':'A paid booking is confirmed only after the payment provider verifies payment.'}</p></CardContent></Card></div>}</div>;
}
function ArrowRightIcon() { return <ArrowUpRight />; }
function ticketDownload(booking: Booking) {
  const text = [booking.is_test?'TRAVELMATE · TEST RESERVATION TICKET':'TRAVELMATE · BOOKING RECORD', booking.listing_name || 'Reservation', 'Type: ' + (booking.booking_type==='hotel'?'Hotel stay':'Restaurant table reservation'), 'Reference: ' + booking.id, 'Status: ' + booking.status, 'Payment: ' + (booking.is_test?'Test reservation · no charge':Number(booking.total_amount) === 0 ? 'No payment required' : booking.payment_status || 'unpaid'), 'Guest: ' + booking.guest_name, 'Guests: ' + booking.guest_count, 'Arrival: ' + (booking.starts_at || 'Not set'), 'Departure: ' + (booking.ends_at || 'Not applicable'), 'Amount: ' + money(booking.total_amount), booking.room_type ? 'Room: ' + booking.room_type + ' · ' + booking.room_number : '', '', 'This record is not a payment receipt. Status is accurate at download time.'].join('\r\n');
  const url = URL.createObjectURL(new Blob([text], { type: 'text/plain;charset=utf-8' })); const a = document.createElement('a'); a.href = url; a.download = 'TravelMate-' + booking.id.slice(0, 8) + '.txt'; a.click(); toast('Booking record download started.'); setTimeout(() => URL.revokeObjectURL(url), 1000);
}
export function ReservationsPage({ owner = false }: { owner?: boolean }) {
  const identity = useIdentity(); const [data, setData] = useState<Booking[]>([]); const [error, setError] = useState(''); const [loading, setLoading] = useState(true); const [version, setVersion] = useState(0); const [filter, setFilter] = useState('all'); const [busy, setBusy] = useState<string | null>(null);
  const [page,setPage]=useState(0),pageSize=4;
  useEffect(()=>setPage(0),[identity.id,owner]);
  useEffect(() => { let cancelled = false; setLoading(true); setError(''); setData([]); void client.rpc('workspace_reservations').then(({ data: rows, error: problem }) => { if (cancelled) return; if (problem) setError(errorMessage(problem)); else setData(rows as Booking[]); setLoading(false); }); return () => { cancelled = true; }; }, [identity.id, identity.accountStatus, owner, version]);
  const paymentPolls = useRef(0);
  useEffect(() => { if (owner || loading || location.pathname !== '/payment-success' || paymentPolls.current >= 12 || !data.some(b => b.status === 'pending' && b.payment_status !== 'paid')) return; const timeout = window.setTimeout(() => { paymentPolls.current++; setVersion(x => x + 1); }, 5000); return () => clearTimeout(timeout); }, [data, loading, owner]);
  const effectiveStatus = (b: Booking) => b.status === 'pending' && b.payment_status !== 'paid' && b.hold_expires_at && Date.parse(b.hold_expires_at) <= Date.now() ? 'expired' : b.status;
  const filtered=data.filter(booking=>filter==='all'||effectiveStatus(booking)===filter);
  const currentPage=Math.min(page,Math.max(0,Math.ceil(filtered.length/pageSize)-1));
  const rows=filtered.slice(currentPage*pageSize,(currentPage+1)*pageSize);
  useEffect(()=>{if(!loading)setPage(current=>Math.min(current,Math.max(0,Math.ceil(filtered.length/pageSize)-1)));},[filtered.length,loading]);
  async function deleteExpired(b: Booking) {
    if (busy || owner || identity.role !== 'traveler' || !b.can_delete) return;
    const uid = identity.id; setBusy(b.id); setError('');
    try {
      const accepted = await confirmAction(b.status === 'cancelled' ? 'Delete this cancelled ticket?' : 'Delete this expired ticket?',
        'This removes the booking and its ticket from your history. The business keeps its reservation record.',
        'Delete booking', 'Keep ticket', [{label:'Place',value:b.listing_name || 'Your reservation'},{label:'Reference',value:b.id.slice(0,8).toUpperCase()}]);
      if (!accepted || currentIdentity().id !== uid || currentIdentity().role !== 'traveler') return;
      const result = await client.rpc('delete_my_expired_booking', {p_booking:b.id});
      if (result.error) throw result.error;
      if (currentIdentity().id !== uid) return;
      setData(rows => rows.filter(row => row.id !== b.id));
      toast('Booking and ticket deleted from your history.');
    } catch (e) {
      if (currentIdentity().id === uid) { const message = errorMessage(e); setError(message); toast(message, true); }
    } finally { setBusy(null); }
  }
  async function complete(b: Booking) { if(busy||isSuspended())return;const uid=identity.id;setBusy(b.id);setError('');try { if(!await confirmAction('Mark this visit completed?',`${b.listing_name}\nConfirm that the guest has finished their stay or reservation. ${b.is_test?'This closes the test reservation without a payment or verified review.':'This unlocks their verified review.'}`, 'Mark completed','Cancel')||currentIdentity().id!==uid)return;const result=await client.rpc('complete_owner_booking',{p_booking:b.id});if(result.error)throw result.error;if(currentIdentity().id===uid){toast('Visit marked completed.');setVersion(x=>x+1);}}catch(e){if(currentIdentity().id===uid)setError(errorMessage(e));}finally{setBusy(null);} }
  async function cancel(b: Booking) {
    if (busy || !b.can_cancel) return;
    const uid=identity.id; setBusy(b.id); setError('');
    try {
      if (!await confirmAction('Cancel this reservation?',
        'Your room or seats will be released. The cancelled ticket stays in your history.',
        'Cancel reservation','Keep reservation',[{label:'Place',value:b.listing_name},{label:'Dates',value:ticketDate(b.starts_at,b.booking_type!=='hotel')}]) || currentIdentity().id !== uid) return;
      const result=await client.rpc('cancel_my_booking',{p_booking:b.id}); if(result.error)throw result.error;
      if(currentIdentity().id!==uid)return;
      toast('Reservation cancelled successfully.'); setVersion(value=>value+1);
    } catch(e) { if(currentIdentity().id===uid){const message=errorMessage(e);setError(message);toast(message,true);} }
    finally {setBusy(null);}
  }
  async function pay(b: Booking) {
    if(busy||isSuspended(identity))return;const uid=identity.id;setBusy(b.id);
    try {
      if(!await confirmAction('Continue to secure checkout?',b.listing_name+'\n'+money(b.total_amount),'Continue to checkout','Go back')||currentIdentity().id!==uid)return;
      await checkout(b.id);
    } catch(e){if(currentIdentity().id===uid)setError(errorMessage(e));} finally{setBusy(null);}
  }
  // Refresh eligibility when an open hold expires, even if the page stays open.
  useEffect(()=>{
    if(owner||loading)return;
    const expiries=data.filter(b=>b.status==='pending'&&b.payment_status!=='paid'&&b.hold_expires_at).map(b=>Date.parse(b.hold_expires_at!)).filter(time=>time>Date.now());
    if(!expiries.length)return;
    const timer=window.setTimeout(()=>setVersion(value=>value+1),Math.min(2147483647,Math.max(100,Math.min(...expiries)-Date.now()+100)));
    return()=>clearTimeout(timer);
  },[data,loading,owner]);
  return <div className="tm-page tm-reservations-page"><PageHeading eyebrow={owner ? 'YOUR GUESTS, AT A GLANCE' : 'THE DETAILS ARE TAKEN CARE OF'} title={owner ? 'Guest reservations' : 'Bookings & tickets'} description={owner ? 'Reservations for your hotel and restaurant listings, four tickets at a time.' : 'Your stays, table reservations, and booking records, together in one place.'} action={<Button variant="outline" disabled={loading} onClick={() => setVersion(x => x + 1)}><RefreshCw />Refresh</Button>} />{!owner && location.pathname.startsWith('/payment-') && <div className="tm-performance-strip"><Ticket /><p>{location.pathname === '/payment-success' ? 'Checkout returned successfully. We’re checking the database; payment is confirmed only when its status says Paid.' : 'Checkout was cancelled. Your hold remains until it expires, and you can retry payment while it is active.'}</p></div>}
   <div className="tm-reservation-toolbar">
    <FilterSelect label="Show reservations" value={filter} onChange={value=>{setFilter(value);setPage(0);}} options={['all','pending','confirmed','completed','cancelled','expired'].map(value=>({value,label:value==='all'?'All statuses':value.charAt(0).toUpperCase()+value.slice(1),count:value==='all'?data.length:data.filter(booking=>effectiveStatus(booking)===value).length}))}/>
    {!loading&&<PageNavigation page={currentPage} total={filtered.length} pageSize={pageSize} onChange={setPage} label="Reservation pages" noun="reservations" disabled={busy!==null}/>}
   </div>
   {data.length===200&&<p className="tm-data-scope">Showing your latest 200 records.</p>}
   {error && <ErrorState message={error} retry={() => setVersion(x => x + 1)} />}{loading ? <LoadingCards /> : <div className="tm-ticket-grid" aria-label="Reservations on this page">{rows.map(b => {
    const status=effectiveStatus(b),hotel=b.booking_type==='hotel';
    const dates=ticketDate(b.starts_at,!hotel)+(hotel&&b.ends_at?' – '+ticketDate(b.ends_at):'');
    const payment=b.is_test?'No charge':b.payment_status==='paid'?'Paid':Number(b.total_amount)===0?'No payment needed':status==='expired'?'Expired · unpaid':'Unpaid';
    const quickActions=[];
    if(!owner&&!isSuspended(identity)&&identity.role==='traveler'&&b.can_delete)quickActions.push(<Button key="delete" className="tm-ticket-action-danger" variant="outline" disabled={busy!==null} onClick={()=>void deleteExpired(b)}><Trash2/>Delete ticket</Button>);
    if(!owner&&!isSuspended(identity)&&b.can_cancel)quickActions.push(<Button key="cancel" className="tm-ticket-action-danger" variant="outline" disabled={busy!==null} onClick={()=>void cancel(b)}><CircleX/>Cancel reservation</Button>);
    if(!owner&&!isSuspended(identity)&&!b.is_test&&status==='pending'&&b.payment_status!=='paid')quickActions.push(<Button key="pay" disabled={busy!==null} onClick={()=>void pay(b)}>Pay securely<ArrowUpRight/></Button>);
    if(owner&&b.status==='confirmed')quickActions.push(<Button key="complete" disabled={busy!==null} onClick={()=>void complete(b)}><CheckCircle2/>Mark completed</Button>);
    return <FoldedTicket type={hotel?'hotel':'restaurant'} key={b.id} reference={b.id.slice(0,8).toUpperCase()} name={b.listing_name||'Your reservation'} kind={hotel?'Stay ticket':'Table reservation'} status={status} dates={dates} amount={money(b.total_amount)} payment={payment} actions={quickActions.length?quickActions:null}>
      <dl className="tm-ticket-fields">
        <div><dt><Ticket size={16}/>Reference</dt><dd>{b.id.slice(0,8).toUpperCase()}</dd></div>
        <div><dt><Users size={16}/>Guests</dt><dd>{b.guest_count} {b.guest_count===1?'guest':'guests'} · {b.guest_name}</dd></div>
        {b.room_type&&<div><dt><BedDouble size={16}/>Your room</dt><dd>{b.room_type} · Room {b.room_number}</dd></div>}
        {owner&&<div><dt>Guest contact</dt><dd>{b.guest_email}{b.guest_phone?' · '+b.guest_phone:''}</dd></div>}
      </dl>
      {status==='pending'&&<p className="tm-ticket-help"><Clock3 size={15}/>Hold ends {ticketDate(b.hold_expires_at,true)}.</p>}
      {!owner&&!b.can_cancel&&['confirmed','pending'].includes(status)&&!b.is_test&&<p className="tm-ticket-help">For changes or cancellation, contact the property through its listing.</p>}
      <div className="tm-ticket-secondary-actions">
        {!owner&&<Button variant="outline" onClick={()=>navigate('/listing/'+b.listing_id)}>View listing<ArrowUpRight/></Button>}
        <Button variant="outline" onClick={()=>ticketDownload(b)}><Download/>Download ticket</Button>
        {!owner&&!isSuspended(identity)&&!b.is_test&&status==='completed'&&<Button variant="outline" onClick={()=>navigate('/listing/'+b.listing_id+'?review=1')}><Star/>Write a review</Button>}
      </div>
    </FoldedTicket>;
  })}{!filtered.length && <EmptyState title={filter!=='all'?'No '+filter+' reservations':owner ? 'No reservations to show' : 'No stay or table bookings yet'} action={!owner && <Button onClick={() => navigate('/explore')}>Explore destinations<ArrowUpRight /></Button>}>{filter!=='all'?'Choose another status to see more reservations.':owner ? 'Bookings for your listings will appear here as travelers reserve.' : 'Open a destination, find a stay or restaurant, and review your reservation.'}</EmptyState>}</div>}{!owner&&identity.role==='traveler'&&<PreviewReservations version={version}/>} {owner && <OwnerSlots />}</div>;
}
function OwnerSlots() {
  const [slotPage,setSlotPage]=useState(0);
  const identity = useIdentity(); const [restaurants, setRestaurants] = useState<{ id: string; name: string }[]>([]); const [slots, setSlots] = useState<{ id: string; starts_at: string; ends_at: string; capacity: number; is_open: number }[]>([]); const [form, setForm] = useState({ listing: '', start: '', end: '', capacity: '20' }); const [message, setMessage] = useState(''); const [busy, setBusy] = useState(false); const [version, setVersion] = useState(0); const [error, setError] = useState('');
  useEffect(() => { let cancelled = false; setRestaurants([]); void (async () => { try { const o = await client.from('business_owners').select('id').eq('profile_id', identity.id!).single(); if (o.error) throw o.error; const r = await client.from('business_listings').select('id,name').eq('owner_id', o.data.id).eq('listing_type', 'restaurant').order('name'); if (r.error) throw r.error; if (!cancelled) setRestaurants(r.data ?? []); } catch (e) { if (!cancelled) setError(errorMessage(e)); } })(); return () => { cancelled = true; }; }, [identity.id]);
  useEffect(() => { let cancelled = false; setSlots([]); if (form.listing) void client.from('restaurant_slots').select('id,starts_at,ends_at,capacity,is_open').eq('restaurant_id', form.listing).gt('starts_at', new Date().toISOString()).order('starts_at').limit(100).then(r => { if (!cancelled) { if (r.error) setError(errorMessage(r.error)); else setSlots(r.data ?? []); } }); return () => { cancelled = true; }; }, [form.listing, version]);
  useEffect(()=>setSlotPage(0),[form.listing,identity.id]);
  const slotCurrent=Math.min(slotPage,Math.max(0,Math.ceil(slots.length/4)-1));
  if (!restaurants.length) return error ? <div role="alert" className="tm-error">{error}</div> : null;
  return <details className="tm-owner-slot-disclosure"><summary><CalendarDays size={22}/><span>Restaurant availability<small>Add table reservation slots when you need them.</small></span><ChevronDown size={20}/></summary><Card><CardContent className="p-6"><p className="tm-eyebrow">RESTAURANT AVAILABILITY</p><h2>Make room for your next guests.</h2><p className="tm-description">Add an upcoming reservation slot. Travelers can reserve seats after the listing is approved.</p><form className="tm-slot-form" onSubmit={async e => { e.preventDefault(); if (busy) return; setBusy(true); setError(''); setMessage(''); const uid = identity.id; try { const start = new Date(form.start); const end = new Date(form.end); if (start <= new Date() || end <= start) throw new Error('Choose a future start time and a later end time.'); if (!await confirmAction('Add reservation availability?', `${restaurants.find(r => r.id === form.listing)?.name}\n${start.toLocaleString('en-PH')} → ${end.toLocaleString('en-PH')}\n${form.capacity} seats`, 'Add time slot') || currentIdentity().id !== uid) return; const r = await client.rpc('owner_add_reservation_slot', { p_listing: form.listing, p_start: start.toISOString(), p_end: end.toISOString(), p_capacity: Number(form.capacity) }); if (r.error) throw r.error; setMessage('Reservation slot added.');toast('Reservation slot added successfully.'); setVersion(x => x + 1); } catch (e) { setError(errorMessage(e)); } finally { setBusy(false); } }}><fieldset disabled={busy}><label>Restaurant<select required value={form.listing} onChange={e => setForm({ ...form, listing: e.target.value })}><option value="">Choose your restaurant</option>{restaurants.map(r => <option key={r.id} value={r.id}>{r.name}</option>)}</select></label><DateTimeRangeFields start={form.start} end={form.end} disabled={busy} onChange={(start,end)=>setForm(old=>({...old,start,end}))}/><label>Seat capacity<input required type="number" min="1" max="500" value={form.capacity} onChange={e => setForm({ ...form, capacity: e.target.value })} /></label><Button type="submit"><Plus />Add time slot</Button></fieldset></form>{error && <p className="tm-error" role="alert">{error}</p>}{message && <p role="status" className="tm-paid">{message}</p>}{slots.slice(slotCurrent*4,(slotCurrent+1)*4).map(slot => <div className="tm-menu-row" key={slot.id}><span>{new Date(slot.starts_at).toLocaleString('en-PH')} → {new Date(slot.ends_at).toLocaleTimeString('en-PH')}</span><strong>{slot.capacity} seats · {slot.is_open ? 'Open' : 'Closed'}</strong></div>)}{slots.length>4&&<PageNavigation page={slotCurrent} total={slots.length} pageSize={4} onChange={setSlotPage} label="Availability pages" noun="time slots"/>}</CardContent></Card></details>;
}
