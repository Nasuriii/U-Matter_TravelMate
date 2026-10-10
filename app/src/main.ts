import { initExperience, mountExperience, experiencePages } from './experience';
import { confirmAction } from './action-confirm';
import './utilities.css';
import { tripsPage, initTrips } from './trips';
import { createClient, type User } from '@supabase/supabase-js';
import './style.css';
import { createExplorer } from './explorer';
import { loadLanding, loadBrowse } from './home-data';
import { initOwner } from './owner';
import { initAdmin } from './admin';
import { ownerPage } from './pages/owner';
import { adminPage } from './pages/admin';
import { stayPage } from './pages/stay';
import { eatPage } from './pages/eat';
import { attractionsPage } from './pages/attractions';
import { header, footer, dialogs } from './layout';
import { landingPage } from './pages/landing';
import { authPage } from './pages/auth';
import { explorePage } from './pages/explore';
import { accountPage } from './pages/account';
import { route, go } from './router';
import { installButtonLoading } from './ui';
import { homePage } from './pages/home';
import { purposeForPath, workspaceAfterSignup } from './signup-flow';

// Static markup only. User/database content is inserted through textContent/value.
document.querySelector<HTMLDivElement>('#app')!.innerHTML = header + `<main id="main-content" tabindex="-1">${landingPage}${homePage}${authPage}${explorePage}${stayPage}${eatPage}${attractionsPage}${ownerPage}${adminPage}${accountPage}${tripsPage}${experiencePages}</main>` + dialogs + footer;
mountExperience();
const menu = document.querySelector<HTMLButtonElement>('#mobile-menu')!;
const closeMenu = () => { document.body.classList.remove('nav-open'); menu.setAttribute('aria-expanded','false'); };
menu.addEventListener('click', () => { const open = document.body.classList.toggle('nav-open'); menu.setAttribute('aria-expanded',String(open)); });
window.addEventListener('hashchange', closeMenu);
document.addEventListener('keydown', e => { if(e.key === 'Escape') closeMenu(); });
document.querySelector('#main-navigation')!.addEventListener('click', e => { if ((e.target as HTMLElement).closest('a,button')) closeMenu(); });
window.addEventListener('hashchange',route); route();
const el = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;
const notice = (message: string, error = false) => { for (const id of ['notice', 'auth-notice']) { const n = el(id); n.textContent = message; n.classList.toggle('error', error); } };
const rawError = (e: unknown): string => e instanceof Error ? e.message : typeof e === 'object' && e && 'message' in e ? String(e.message) : String(e);
function explain(e: unknown) {
 const message = rawError(e);
 if (/Invalid schema|schema.*exposed|PGRST106/i.test(message)) return `${message} — Check public in the Data API exposed schemas, then reload.`;
 if (/permission denied|row-level security/i.test(message)) return `${message} — Check the supplied Auth/Storage SQL policies. Do not disable RLS.`;
 if (/Invalid login credentials/i.test(message)) return 'Incorrect email or password. If you signed up with Google, use Continue with Google.';
 if (/Email not confirmed/i.test(message)) return 'Please confirm your email first — check your inbox for the link.';
 if (/Failed to fetch|fetch failed/i.test(message)) return `${message} — Check your project URL, network and whether the project is active.`;
 return message;
}
const url = import.meta.env.VITE_SUPABASE_URL?.trim();
const key = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY?.trim();
function validConfig() {
 if (!url || !key || url.includes('YOUR_') || key.includes('YOUR_')) throw new Error('Setup needed: copy .env.example to .env.local, enter your project URL and publishable key, then restart npm run dev.');
 const parsed = new URL(url);
 if (parsed.protocol !== 'https:') throw new Error('Use the HTTPS project URL from your Supabase dashboard.');
 if (key.startsWith('sb_secret_')) throw new Error('Use a publishable key, never a secret key.');
 if (!key.startsWith('sb_publishable_')) {
  try { const payload=JSON.parse(atob(key.split('.')[1].replace(/-/g,'+').replace(/_/g,'/'))); if(payload.role !== 'anon') throw new Error(); }
  catch { throw new Error('Use the Supabase publishable key, or legacy anon key. Never use service_role or Google credentials.'); }
 }
}
installButtonLoading();
try { validConfig(); await start(); } catch(e) { notice(explain(e),true); el('catalog-notice').textContent=explain(e);document.body.dataset.auth='out';route();
 document.querySelectorAll<HTMLButtonElement>('#search-form button,#auth-form button,#login').forEach(b=>{b.disabled=true;b.title='Needs Supabase setup (.env.local)';}); }
async function start() {
 const supabase = createClient(url!, key!, { auth: { flowType: 'pkce', detectSessionInUrl: true, persistSession: true, autoRefreshToken: true } });
 type Profile = {id:string; full_name:string; address:string|null; avatar_object_path:string|null};
 let user: User|null=null, profile:Profile|null=null, preview:string|null=null, busy=false, generation=0;
 const storage = supabase.storage.from('travelmate-avatars');
 const experience = initExperience(supabase);
 const api = supabase.schema('public');
 const explorer=createExplorer(supabase);
 const trips=initTrips(supabase);
 loadLanding(supabase);
 const owner=initOwner(supabase);
 const adminTools=initAdmin(supabase);
 let phoneId:string|null=null, roleNames:string[]=[];
 function controls() {
  for(const id of ['login','refresh','save','upload','auth-submit']) el<HTMLButtonElement>(id).disabled=busy || (['save','upload'].includes(id) && !profile) || (id==='upload' && !el<HTMLInputElement>('file').files?.length);
  el<HTMLFieldSetElement>('fields').disabled=busy || !profile;
  el<HTMLInputElement>('file').disabled=busy || !profile;
 }
 function clearAvatar() {
  if(preview) URL.revokeObjectURL(preview); preview=null;
  el<HTMLImageElement>('avatar').removeAttribute('src'); el('avatar').hidden=true; el('avatar-placeholder').hidden=false;
 }
 function clearProfile() {
  profile=null; clearAvatar(); el<HTMLInputElement>('name').value=''; el<HTMLTextAreaElement>('address').value='';
  el('profile-id').textContent='Not loaded';phoneId=null;roleNames=[];el<HTMLInputElement>('phone').value='';el('file-name').textContent='No file chosen';el('avatar-placeholder').textContent='TM'; el('object-path').textContent='';el<HTMLInputElement>('file').value='';
 }
 async function run(action:()=>Promise<void>) {
  if(busy)return; busy=true; controls();
  try { await action(); } catch(e) { notice(explain(e),true); }
  finally { busy=false;controls(); }
 }
 async function loadProfile() {
  if(!user)return;const uid=user.id,token=++generation;
  clearProfile();controls(); notice('Loading your profile…');
  const signup = await api.rpc('finish_my_signup', {p_account_type: sessionStorage.getItem('travelmate:entry-intent') === 'business_owner' ? 'business_owner' : 'traveler'});
  if(token!==generation || user?.id!==uid)return;
  if(signup.error)throw signup.error;
  const {data,error}=await api.from('my_profile').select('id,full_name,address,avatar_object_path').maybeSingle();
  if(token!==generation || user?.id!==uid)return;
  if(error)throw error;
  if(!data)throw new Error('No active profile found. Confirm Auth SQL is installed, your email is confirmed, and your account is active. Imported demo accounts are not automatically linked.');
  if(data.id!==uid)throw new Error('Unexpected profile identity. Stop and review the RLS setup.');
  profile=data as Profile;el<HTMLInputElement>('name').value=profile.full_name;el<HTMLTextAreaElement>('address').value=profile.address??'';
  el('profile-id').textContent=String(profile.id);el('avatar-placeholder').textContent=profile.full_name.split(/\s+/).filter(Boolean).slice(0,2).map(w=>w[0].toUpperCase()).join('')||'TM';el('object-path').textContent=profile.avatar_object_path??'No avatar uploaded yet.';
  if(profile.avatar_object_path){
   const download=await storage.download(profile.avatar_object_path);
   if(token!==generation || user?.id!==uid)return;
   if(download.error)throw new Error(`Profile loaded, but avatar download failed: ${download.error.message}`);
   preview=URL.createObjectURL(download.data);el<HTMLImageElement>('avatar').src=preview;el('avatar').hidden=false;el('avatar-placeholder').hidden=true;
  }
  const [ph,rr]=await Promise.all([api.from('profile_phones').select('id,phone_number').order('phone_number').limit(1),api.from('profile_roles').select('roles(name)')]);
  if(token!==generation || user?.id!==uid)return;
  if(!ph.error&&ph.data?.[0]){phoneId=ph.data[0].id;el<HTMLInputElement>('phone').value=ph.data[0].phone_number;}
  
  if(!rr.error)roleNames=(rr.data??[]).map((x:any)=>{const r=x.roles;return Array.isArray(r)?r[0]?.name:r?.name;}).filter(Boolean);
  if(rr.error)throw new Error('Your workspace role could not be verified. Refresh your account to try again.');
  if(token!==generation || user?.id!==uid)return;
  applyRole(user);
  const entry = sessionStorage.getItem('travelmate:entry-intent');
  if (signup.data?.onboarding_needed || entry) {
   sessionStorage.removeItem('travelmate:entry-intent');
   go(workspaceAfterSignup(signup.data?.role ?? 'traveler', !!signup.data?.onboarding_needed));
  }
  if(roleNames.includes('business_owner'))void owner.refresh();
  if(roleNames.includes('admin'))void adminTools.refresh();
  notice('Your profile is ready.');controls();
 }
 window.addEventListener('travelmate:profile-updated', event=>{const value=(event as CustomEvent).detail;if(!user||!profile||value.profile_id!==user.id)return;profile.full_name=value.full_name;(el('name') as HTMLInputElement).value=value.full_name;experience.setUser({id:user.id,role:roleNames.includes('admin')?'admin':roleNames.includes('business_owner')?'owner':'traveler',name:value.full_name,email:user.email||''});});
 function applyRole(u:User|null){
  const owner=roleNames.includes('business_owner'),admin=roleNames.includes('admin');
  el('account-type').textContent=!u?'':admin?'Administrator':owner?'Business Owner':'Traveler';
  document.querySelector('#workspace-role')!.textContent=!u?'':admin?'Administrator':owner?'Business owner':'Traveler';
  document.querySelector<HTMLElement>('#traveler-home')!.hidden=admin||owner;
  document.querySelector<HTMLElement>('#workspace-home')!.hidden=!admin&&!owner;
  document.querySelector('#workspace-title')!.textContent=admin?'A better journey starts with trust.':'Make your next guest feel welcome.';
  document.querySelector('#workspace-description')!.textContent=admin?'Review submissions and keep the catalog accurate.':'Keep your listings current and follow their approval status.';
  const workLink=document.querySelector<HTMLAnchorElement>('#workspace-action')!;workLink.href=admin?'#/admin':'#/owner';workLink.textContent=admin?'Open review queue →':'Manage my listings →';el('owner-note').hidden=!owner;
  el('travel-preferences-link').hidden=!u||owner||admin;
  if(u)document.body.dataset.owner=owner?'yes':'no';else delete document.body.dataset.owner;
  if(u)document.body.dataset.admin=admin?'yes':'no';else delete document.body.dataset.admin;
  experience.setUser({id:u?.id??null,role:!u?'guest':admin?'admin':owner?'owner':'traveler',name:profile?.full_name||String(u?.user_metadata?.full_name||u?.email?.split('@')[0]||''),email:u?.email||''});
  const traveler=!!u&&!admin&&!owner;
  explorer.setUser(traveler?u!.id:null);trips.setUser(traveler?u!.id:null);
  if(traveler)loadBrowse(supabase);
  route();
 }
 async function displayUser(next:User|null){
  experience.setUser({id:next?.id??null,role:next?'loading':'guest',name:'',email:next?.email||''});
  delete document.body.dataset.owner;delete document.body.dataset.admin;
  owner.setUser(next?.id ?? null);
  generation++;const changed=user?.id!==next?.id;user=next;
  if(changed || !next)clearProfile();
  explorer.setUser(null);trips.setUser(null);
  document.body.dataset.auth=next?'in':'out';if(!next)applyRole(null);route();el('account').hidden=!next;el('email').textContent=next?.email??'';el('uid').textContent=next?.id??'';el('hm-name').textContent=String(next?.user_metadata?.full_name||next?.email||'traveler').split(' ')[0].split('@')[0].toUpperCase();controls();
  if(next)await loadProfile();else notice('');
 }
 el('login').addEventListener('click',()=>void run(async()=>{
  const purpose = purposeForPath(location.hash.slice(1));
  if (purpose) sessionStorage.setItem('travelmate:entry-intent', purpose);
  else sessionStorage.removeItem('travelmate:entry-intent');
  notice('Opening Google sign-in…');
  const {error}=await supabase.auth.signInWithOAuth({provider:'google',options:{redirectTo:window.location.origin+'/',queryParams:{prompt:'select_account'}}});if(error)throw error;
 }));
 const val=(id:string)=>el<HTMLInputElement>(id).value;
 el('auth-form').addEventListener('submit',e=>{e.preventDefault();void run(async()=>{
  const purpose=purposeForPath(location.hash.slice(1));
  const mode=purpose?'register':location.hash.replace(/^#\/?/,''),email=val('auth-email').trim(),password=val('auth-password');
  if(mode!=='reset'&&!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))throw new Error('Enter a valid email address.');
  if(mode==='forgot'){
   notice('Sending reset link…');const {error}=await supabase.auth.resetPasswordForEmail(email,{redirectTo:window.location.origin+'/'});if(error)throw error;
   notice('If that email has an account, a reset link is on its way. Check your inbox.');return;
  }
  if(mode==='reset'||mode==='register'){
   if(password.length<8)throw new Error('Use a password of at least 8 characters.');
   if(password!==val('auth-confirm'))throw new Error('Passwords do not match.');
  }
  if(mode==='reset'){
   notice('Saving your new password…');const {error}=await supabase.auth.updateUser({password});if(error)throw error;
   notice('Password updated.');go('/home');return;
  }
  if(mode==='register'){
   const name=(val('reg-first').trim()+' '+val('reg-last').trim()).trim();
   if(!val('reg-first').trim())throw new Error('Enter your first name.');
   notice('Creating your account…');
   const {data,error}=await supabase.auth.signUp({email,password,options:{data:{full_name:name,signup_account_type:purpose??'traveler'},emailRedirectTo:window.location.origin+'/'}});
   if(error)throw error;
   if(data.user&&data.user.identities?.length===0)throw new Error('That email is already registered. Log in instead.');
   if(!data.session){go('/login');notice('Account created. Check your email and confirm your address, then log in. Your profile is created once your email is confirmed.');}
   return;
  }
  if(!password)throw new Error('Enter your password.');
  notice('Logging in…');const {error}=await supabase.auth.signInWithPassword({email,password});if(error)throw error;
 });});
 el('toggle-pw').addEventListener('click',()=>{const show=el<HTMLInputElement>('auth-password').type==='password';
  for(const id of ['auth-password','auth-confirm'])el<HTMLInputElement>(id).type=show?'text':'password';el('toggle-pw').textContent=show?'Hide':'Show';});
 el('top-logout').addEventListener('click',()=>window.dispatchEvent(new Event('travelmate:sign-out')));
 el('home-search-form').addEventListener('submit',e=>{e.preventDefault();el<HTMLInputElement>('search').value=val('home-search').trim();go('/explore');el<HTMLFormElement>('search-form').requestSubmit();});
 el<HTMLInputElement>('file').addEventListener('change',()=>{el('file-name').textContent=el<HTMLInputElement>('file').files?.[0]?.name??'No file chosen';controls();});
 window.addEventListener('travelmate:sign-out',()=>void run(async()=>{
  const {error}=await supabase.auth.signOut({scope:'local'});if(error)throw error;await displayUser(null);
 }));
 el('account-logout').addEventListener('click',()=>window.dispatchEvent(new Event('travelmate:sign-out')));
 el('refresh').addEventListener('click',()=>void run(loadProfile));
 el('profile-form').addEventListener('submit',event=>{event.preventDefault();void run(async()=>{
  if(!profile || !user)throw new Error('Sign in and load a profile first.');
  const name=el<HTMLInputElement>('name').value.trim();if(!name)throw new Error('Enter your name.');
  const phone=el<HTMLInputElement>('phone').value.trim();if(phone&&!/^\+?[\d\s()-]{7,25}$/.test(phone))throw new Error('Enter a valid contact number, e.g. +63 900 000 0000.');
  const profileUser=user.id;
  if(!await confirmAction('Save your profile changes?',`${name}\n${el<HTMLTextAreaElement>('address').value.trim()||'No address'}\n${phone||'No phone number'}`,'Save profile'))return;
  if(user?.id!==profileUser||!profile)return;
  const {error}=await api.rpc('update_my_profile',{p_full_name:name,p_address:el<HTMLTextAreaElement>('address').value.trim()||null,p_avatar_object_path:profile.avatar_object_path});
  if(error)throw error;
  const pe=phone&&phoneId?await api.from('profile_phones').update({phone_number:phone}).eq('id',phoneId):phone?await api.from('profile_phones').insert({profile_id:user.id,phone_number:phone}):phoneId?await api.from('profile_phones').delete().eq('id',phoneId):null;
  if(pe?.error)throw new Error('Profile saved, but the contact number was not: '+pe.error.message);
  await loadProfile();notice('Profile saved.');
 });});
 el('upload').addEventListener('click',()=>void run(async()=>{
  if(!profile || !user)throw new Error('Sign in and load a profile first.');
  const file=el<HTMLInputElement>('file').files?.[0];if(!file)throw new Error('Choose an image first.');
  const extensions:Record<string,string>={'image/jpeg':'jpg','image/png':'png','image/webp':'webp'};
  if(!extensions[file.type])throw new Error('Choose a JPEG, PNG or WebP image.');
  if(file.size===0 || file.size>2*1024*1024)throw new Error('Choose a nonempty image no larger than 2 MB.');
  const avatarUser=user.id;
  if(!await confirmAction('Update your profile photo?',`Upload ${file.name} as your new profile photo?`,'Upload photo'))return;
  if(user?.id!==avatarUser||!profile)return;
  const uid=user.id;
  const path=`${uid}/${crypto.randomUUID()}.${extensions[file.type]}`;
  notice('Uploading your private avatar…');
  const {error}=await storage.upload(path,file,{contentType:file.type,upsert:false});if(error)throw error;
  // Storage and profile changes are separate transactions. On RPC failure retain
  // the uploaded file: a network error can hide a committed profile update.
  const saved=await api.rpc('update_my_profile',{p_full_name:profile.full_name,p_address:profile.address,p_avatar_object_path:path});
  if(saved.error)throw new Error(`Image uploaded at ${path}, but saving its profile link was not confirmed: ${saved.error.message}. Reload your profile before retrying; the uploaded file was retained.`);
  let cleanup='';
  // Old avatars are retained to avoid breaking references from concurrent edits.
  el<HTMLInputElement>('file').value='';await loadProfile();notice('Avatar uploaded and linked to your profile.'+cleanup);
 }));
 // Do not make awaited Supabase calls inside the Auth event callback.
 let recovery=false;
 supabase.auth.onAuthStateChange((event,session)=>{
  if(event==='PASSWORD_RECOVERY'){recovery=true;location.hash='#/reset';}
  if(event==='SIGNED_IN'){if(session?.user?.id&&session.user.id===user?.id&&profile)return;setTimeout(()=>void run(async()=>{const result=await supabase.auth.getUser();if(result.error)throw result.error;await displayUser(result.data.user);}),0);}
  if(event==='SIGNED_OUT'){owner.setUser(null);generation++;user=null;clearProfile();explorer.setUser(null);trips.setUser(null);el('account').hidden=true;document.body.dataset.auth='out';applyRole(null);location.hash='#/';route();controls();notice('Signed out.');}
 });
 const params=new URLSearchParams(location.search),hash=new URLSearchParams(location.hash.slice(1));
 const oauthError=params.get('error_description')||hash.get('error_description');
 const {data,error}=await supabase.auth.getSession();
 if(error)throw error;
 // The SDK handles the PKCE callback once. Remove callback parameters afterwards.
 if(params.has('code')||params.has('error')||hash.has('error'))history.replaceState({},'',location.pathname+(recovery?'#/reset':'#/home'));route();
 if(location.pathname.startsWith('/payment-'))location.hash='#/bookings';
 await run(()=>displayUser(data.session?.user??null));
 if(oauthError)notice(`Google sign-in did not finish: ${oauthError}`,true);
}

import './overhaul.css';

import './ui-overhaul.css';
import './experience.css';

import './interactive.css';
import './travel-design.css';
import './appearance.css';
import './refinement.css';
import './trip-place.css';
