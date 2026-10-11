import { ArrowLeft, ArrowRight, BedDouble, Building2, CalendarDays, Check, ClipboardCheck, Compass, Eye, MapPin, Route, Users, Utensils } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Field, FieldGroup, FieldLabel, FieldDescription, FieldError } from '../components/ui/field';

function InputError({ id }: { id: string }) {
  return <FieldError id={id + '-error'} hidden />;
}

function AuthNotebook({ business = false }: { business?: boolean }) {
  const steps = business ? [
    { icon: Building2, title: 'Showcase your place', text: 'Add your details, photos, and amenities.' },
    { icon: ClipboardCheck, title: 'Submit for review', text: 'Go live after administrator approval.' },
    { icon: Users, title: 'Welcome your guests', text: 'Manage your listings and reservations.' },
  ] : [
    { icon: MapPin, title: 'Find your place', text: 'Somewhere you’ve wanted to go.' },
    { icon: CalendarDays, title: 'Make a little plan', text: 'Your dates. Your pace. Your people.' },
    { icon: Compass, title: 'Leave room for discovery', text: 'Turn your favorite places into a trip.' },
  ];
  return <div className={'pub-travel-note ' + (business ? 'pub-owner-note' : 'pub-traveler-note')} aria-label={business ? 'How to get your business listed' : 'How your trip comes together'}>
    <div className="pub-note-heading"><span><Route size={19} aria-hidden="true" />{business ? 'YOUR BUSINESS PORTAL' : 'YOUR TRAVEL NOTEBOOK'}</span><span className="pub-andy">{business ? 'Welcome in!' : 'Let’s go!'}</span></div>
    <ol>{steps.map(({ icon: Icon, title, text }, index) => <li key={title}><span className="pub-note-icon"><Icon aria-hidden="true" /></span><div><strong>{title}</strong><span>{text}</span></div>{index < 2 ? <Check size={17} aria-hidden="true" /> : <ArrowRight size={17} aria-hidden="true" />}</li>)}</ol>
    <div className="pub-note-footer"><BedDouble aria-hidden="true" /><Utensils aria-hidden="true" /><Compass aria-hidden="true" /><span>{business ? 'Stays, tables & local experiences.' : 'Stays, food & little detours.'}</span></div>
  </div>;
}

/** Keep every control mounted: the existing router selects modes without replacing form values. */
export function AuthExperience() {
  return <div className="pub-auth-layout">
    <aside className="auth-photo pub-auth-story">
      <a href="#/" className="pub-auth-brand"><Compass aria-hidden="true" /><span>Travel<strong>Mate</strong></span></a>
      <div className="auth-copy">
        <p className="pub-kicker">YOUR NEXT CHAPTER</p>
        <h2 data-for="login">A good trip deserves a comeback.</h2>
        <h2 data-for="register">Your kind of journey</h2>
        <h2 data-for="forgot">Let’s get you back on track.</h2>
        <h2 data-for="reset">A fresh start.</h2>
        <p data-for="login">Your saved places and trip plans are right where you left them.</p>
        <p data-for="register">Beaches, mountains, food stops, and scenic detours. Make room for what you love.</p>
        <p data-for="forgot">We’ll help you get back to the places you’ve been looking forward to.</p>
        <p data-for="reset">Choose a new password and get back to planning.</p>
      </div>
      <AuthNotebook />
      <AuthNotebook business />
      <small>U-Matter · Local places. Thoughtful plans.</small>
    </aside>
    <div className="auth-panel pub-auth-panel">
      <div className="auth-box">
        <a className="back" href="#/"><ArrowLeft size={17} aria-hidden="true" />Back to exploring</a>
        <p className="pub-kicker" data-for="register"><span className="pub-traveler-only">A LITTLE ADVENTURE STARTS HERE</span><span className="pub-owner-only">A NEW CHAPTER FOR YOUR BUSINESS</span></p>
        <h1 data-for="login">Welcome back</h1>
        <h1 data-for="register">Create your traveler account</h1>
        <h1 data-for="forgot">Reset your password</h1>
        <h1 data-for="reset">Choose a new password</h1>
        <p className="sub" data-for="login">Log in to pick up where you left off.</p>
        <p className="sub" data-for="register">Save your favorites and plan a trip that feels like you.</p>
        <p className="sub" data-for="forgot">Enter your email and we’ll send you a reset link.</p>
        <p className="sub" data-for="reset">Use at least 8 characters and confirm it below.</p>
        <div className="pub-auth-social" data-for="login register">
          <Button id="login" variant="outline" type="button" className="w-full"><span className="pub-google-mark" aria-hidden="true">G</span>Continue with Google</Button>
          <p className="divider"><span>or use your email</span></p>
        </div>
        <form id="auth-form" noValidate>
          <FieldGroup>
            <div className="pub-auth-names gap-4 sm:grid-cols-2" data-for="register">
              <Field><FieldLabel htmlFor="reg-first">First name</FieldLabel><Input id="reg-first" maxLength={75} autoComplete="given-name" placeholder="Juan" aria-describedby="reg-first-error" /><InputError id="reg-first" /></Field>
              <Field><FieldLabel htmlFor="reg-last">Last name <span className="pub-optional">(optional)</span></FieldLabel><Input id="reg-last" maxLength={75} autoComplete="family-name" placeholder="Dela Cruz" aria-describedby="reg-last-error" /><InputError id="reg-last" /></Field>
            </div>
            <Field data-for="login register forgot"><FieldLabel htmlFor="auth-email">Email address</FieldLabel><Input id="auth-email" type="email" maxLength={150} autoComplete="email" placeholder="you@example.com" aria-describedby="auth-email-error" /><InputError id="auth-email" /></Field>
            <Field data-for="login register reset">
              <div className="flex items-center justify-between gap-3"><FieldLabel htmlFor="auth-password">Password</FieldLabel><a href="#/forgot" data-for="login" className="pub-forgot">Forgot password?</a></div>
              <div className="pw-wrap"><Input id="auth-password" type="password" autoComplete="current-password" placeholder="Your password" aria-describedby="auth-password-hint auth-password-error" /><Button id="toggle-pw" type="button" variant="ghost" aria-label="Show passwords" aria-pressed="false" aria-controls="auth-password auth-confirm"><Eye size={18} aria-hidden="true" /><span data-password-label>Show</span></Button></div>
              <FieldDescription id="auth-password-hint" data-for="register reset"><span data-password-length>Use at least 8 characters.</span></FieldDescription><InputError id="auth-password" />
            </Field>
            <Field data-for="register reset"><FieldLabel htmlFor="auth-confirm">Confirm password</FieldLabel><Input id="auth-confirm" type="password" autoComplete="off" data-1p-ignore="true" data-lpignore="true" placeholder="Enter your password again" aria-describedby="auth-confirm-hint auth-confirm-error" /><FieldDescription id="auth-confirm-hint" hidden /><InputError id="auth-confirm" /></Field>
          </FieldGroup>
          <Button id="auth-submit" type="submit" size="lg" className="w-full"><span data-for="login">Log in</span><span data-for="register">Create traveler account</span><span data-for="forgot">Send reset link</span><span data-for="reset">Save new password</span><ArrowRight aria-hidden="true" /></Button>
        </form>
        <p id="auth-notice" className="auth-notice" role="status" aria-live="polite" aria-atomic="true" />
        <p className="switch" data-for="login">New here? <a href="#/register/traveler">Create an account</a></p>
        <p className="switch" data-for="register">Already planning with us? <a href="#/login">Log in</a></p>
        <p className="switch" data-for="forgot reset"><a href="#/login">Back to log in</a></p>
        <p className="pub-auth-bottom" data-for="register"><Check size={16} aria-hidden="true" /><span className="pub-traveler-only">Your itinerary is a plan. Book when you’re ready.</span><span className="pub-owner-only">Add your first listing after creating your account.</span></p>
      </div>
    </div>
  </div>;
}
