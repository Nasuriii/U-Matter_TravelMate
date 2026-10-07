import Stripe from 'npm:stripe@22.0.0';
import { createClient } from 'npm:@supabase/supabase-js@2.116.0';

const allowedOrigins = new Set(['http://localhost:5173', 'http://127.0.0.1:5173']);
const configuredOrigin = Deno.env.get('TRAVELMATE_APP_URL');
if (configuredOrigin) allowedOrigins.add(new URL(configuredOrigin).origin);
const secretKey = Deno.env.get('stripe_secret_key');
const keys = JSON.parse(Deno.env.get('SUPABASE_SECRET_KEYS') || '{}');
const admin = createClient(Deno.env.get('SUPABASE_URL')!, keys.default || Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, { auth: { persistSession: false } });

Deno.serve(async req => {
  const origin = req.headers.get('origin') || '';
  const cors = { 'Access-Control-Allow-Origin': allowedOrigins.has(origin) ? origin : '', 'Access-Control-Allow-Headers': 'authorization,x-client-info,apikey,content-type', 'Access-Control-Allow-Methods': 'POST,OPTIONS', 'Vary': 'Origin' };
  const respond = (body: unknown, status = 200) => Response.json(body, { status, headers: cors });
  if (req.method === 'OPTIONS') return allowedOrigins.has(origin) ? new Response(null, { status: 204, headers: cors }) : respond({ error: 'Origin not allowed' }, 403);
  if (req.method !== 'POST') return respond({ error: 'POST required' }, 405);
  if (origin && !allowedOrigins.has(origin)) return respond({ error: 'Origin not allowed' }, 403);
  try {
    const token = req.headers.get('authorization')?.replace(/^Bearer\s+/i, '');
    if (!token) return respond({ error: 'Please sign in again.' }, 401);
    const { data: auth, error: authError } = await admin.auth.getUser(token);
    if (authError || !auth.user) return respond({ error: 'Please sign in again.' }, 401);
    const { bookingId, returnOrigin } = await req.json();
    if (typeof bookingId !== 'string' || !/^[0-9a-f-]{36}$/i.test(bookingId)) return respond({ error: 'Invalid booking reference.' }, 400);
    const returnUrl = returnOrigin || origin || 'http://localhost:5173';
    if (!allowedOrigins.has(returnUrl)) return respond({ error: 'Return origin is not configured.' }, 400);
    const profile = await admin.from('profiles').select('id').eq('id', auth.user.id).eq('account_status', 'active').maybeSingle();
    if (profile.error || !profile.data) return respond({ error: 'An active account is required.' }, 403);
    // A service key bypasses RLS. The explicit profile filter is mandatory.
    const { data: booking, error } = await admin.from('bookings').select('id,profile_id,booking_type,guest_email,total_amount,status,payment_status,stripe_session_id,hold_expires_at').eq('id', bookingId).eq('profile_id', auth.user.id).maybeSingle();
    if (error || !booking) return respond({ error: 'Reservation not found.' }, 404);
    if (booking.payment_status === 'paid' || booking.status !== 'pending') return respond({ error: 'This reservation does not need checkout.' }, 409);
    const expires = Math.floor(Date.parse(booking.hold_expires_at) / 1000);
    if (!Number.isFinite(expires) || expires <= Date.now() / 1000) return respond({ error: 'This reservation hold expired. Choose your dates and reserve again.' }, 409);
    const amount = Math.round(Number(booking.total_amount) * 100);
    if (!Number.isSafeInteger(amount) || amount <= 0) return respond({ error: 'This reservation does not require a payment.' }, 400);
    if (!secretKey) return respond({ error: 'Payment checkout is not configured. Your hold remains available under Bookings & tickets.' }, 503);
    const stripe = new Stripe(secretKey);
    if (booking.stripe_session_id) {
      const existing = await stripe.checkout.sessions.retrieve(booking.stripe_session_id);
      if (existing.status === 'open' && existing.url) return respond({ url: existing.url, sessionId: existing.id });
      return respond({ error: 'Checkout is complete or expired. Refresh your bookings to see the current status.' }, 409);
    }
    // Stripe needs at least 30 minutes for a new session. Holds last 35 minutes.
    if (expires < Math.ceil(Date.now() / 1000) + 1800) return respond({ error: 'There is not enough time left to start checkout. Let this hold expire, then reserve again.' }, 409);
    const session = await stripe.checkout.sessions.create({ mode: 'payment', payment_method_types: ['card'], expires_at: expires,
      line_items: [{ price_data: { currency: 'php', product_data: { name: booking.booking_type === 'hotel' ? 'TravelMate hotel reservation' : 'TravelMate table reservation', description: 'Booking ' + booking.id }, unit_amount: amount }, quantity: 1 }],
      customer_email: booking.guest_email, metadata: { booking_id: booking.id },
      success_url: returnUrl + '/payment-success?session_id={CHECKOUT_SESSION_ID}#/bookings', cancel_url: returnUrl + '/payment-cancelled#/bookings'
    }, { idempotencyKey: 'travelmate_checkout_' + booking.id });
    const saved = await admin.from('bookings').update({ stripe_session_id: session.id }).eq('id', booking.id).eq('profile_id', auth.user.id).eq('status', 'pending').eq('payment_status', 'unpaid').is('stripe_session_id', null).select('id');
    if (saved.error || !saved.data?.length) {
      const current = await admin.from('bookings').select('stripe_session_id,status').eq('id', booking.id).single();
      if (current.data?.stripe_session_id !== session.id || current.data.status !== 'pending') { await stripe.checkout.sessions.expire(session.id).catch(() => {}); return respond({ error: 'Your reservation changed. Refresh bookings before retrying checkout.' }, 409); }
    }
    return respond({ url: session.url, sessionId: session.id });
  } catch { return respond({ error: 'Unable to open checkout. Your saved reservation can be retried from Bookings & tickets.' }, 500); }
});
