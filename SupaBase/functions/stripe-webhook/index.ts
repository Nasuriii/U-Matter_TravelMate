import Stripe from 'npm:stripe@22.0.0';
import { createClient } from 'npm:@supabase/supabase-js@2.116.0';
const keys = JSON.parse(Deno.env.get('SUPABASE_SECRET_KEYS') || '{}');
const admin = createClient(Deno.env.get('SUPABASE_URL')!, keys.default || Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, { auth: { persistSession: false } });
Deno.serve(async req => {
  if (req.method !== 'POST') return new Response('POST required', { status: 405 });
  const signature = req.headers.get('stripe-signature'); const key = Deno.env.get('stripe_secret_key'); const webhookKey = Deno.env.get('stripe_webhook_secret');
  if (!signature) return new Response('Missing Stripe signature', { status: 400 });
  if (!key || !webhookKey) return new Response('Webhook is not configured', { status: 503 });
  const stripe = new Stripe(key); let event: Stripe.Event;
  try { event = await stripe.webhooks.constructEventAsync(await req.text(), signature, webhookKey, undefined, Stripe.createSubtleCryptoProvider()); }
  catch { return new Response('Invalid Stripe signature', { status: 400 }); }
  const session = event.data.object as Stripe.Checkout.Session;
  if (event.type === 'checkout.session.completed' && session.payment_status === 'paid') {
    if (!session.metadata?.booking_id || session.currency !== 'php' || session.amount_total == null) return new Response('Invalid booking payment', { status: 400 });
    const result = await admin.rpc('settle_booking_payment', { p_booking: session.metadata.booking_id, p_session: session.id, p_amount_cents: session.amount_total, p_intent: typeof session.payment_intent === 'string' ? session.payment_intent : session.payment_intent?.id ?? null });
    if (result.error) return new Response('Unable to settle booking payment', { status: 500 });
  } else if (event.type === 'checkout.session.expired' && session.metadata?.booking_id) {
    const result = await admin.from('bookings').update({ status: 'expired' }).eq('id', session.metadata.booking_id).eq('stripe_session_id', session.id).eq('status', 'pending').neq('payment_status', 'paid');
    if (result.error) return new Response('Unable to expire reservation', { status: 500 });
  }
  return Response.json({ received: true });
});
