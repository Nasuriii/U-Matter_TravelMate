import { createClient, type User } from '@supabase/supabase-js';
import './style.css';
import { createExplorer } from './explorer';

// Static markup only. User/database content is inserted through textContent/value.
document.querySelector<HTMLDivElement>('#app')!.innerHTML = `
<aside class="rail"><a href="#explore" class="monogram" aria-label="TravelMate home">Tm</a><nav aria-label="Main navigation"><a href="#explore">◎<span>Explore</span></a><a href="#saved">♡<span>Saved</span></a><a href="#profile">◉<span>Profile</span></a></nav></aside>
<header><a href="#explore" class="brand">TRAVEL<span>MATE</span><small>The Philippine Field Guide</small></a><a class="account-link" href="#profile">Your account ↗</a></header>
<main>
<section id="explore-page"><div class="hero"><div><p class="eyebrow">PHILIPPINE EDITION · FIELD GUIDE & TRIP PLANNER</p><h1>Plan the trip.<br><span>Skip the<br>guesswork.</span></h1><p>Discover somewhere new.<br>Keep the places you want to come back to.</p><a class="primary button" href="#catalog">Explore destinations ↓</a></div><div class="hero-art" role="img" aria-label="Illustration of mountains and the sea"><span>YOUR NEXT CHAPTER<br>STARTS HERE.</span><small>TravelMate · Philippine Field Guide</small></div></div>
<div class="catalog" id="catalog"><p class="eyebrow">FIND YOUR NEXT STOP</p><h2 id="catalog-title">Explore destinations</h2><form id="search-form" class="search-row"><label>Destination or province<input id="search" type="search" placeholder="Where do you want to go?"></label><label>Province<select id="province"><option value="">All provinces</option></select></label><button type="submit">Search</button><button id="reload-catalog" type="button" class="quiet">Refresh</button></form><p id="catalog-notice" role="status" aria-live="polite"></p><div id="destination-grid" class="grid"></div></div></section>
<section id="profile-page" class="profile-page" hidden><div class="intro"><p class="eyebrow">YOUR TRAVELMATE ACCOUNT</p><h1>A little setup.<br>A world to explore.</h1><p>Your profile, your places, your next journey.</p></div>
<div class="card"><div id="notice" role="status" aria-live="polite">Checking configuration…</div>
<div id="guest" hidden><h2>Welcome to TravelMate</h2><p>Sign in to save destinations and make your profile yours.</p><button id="login" class="primary">Continue with Google</button></div>
<div id="account" hidden><div class="account-top"><div><p class="eyebrow">SIGNED IN</p><p id="email"></p></div><button id="logout" class="quiet">Sign out</button></div>
<span id="uid" hidden></span><span id="profile-id" hidden></span>
<button id="refresh" class="quiet">Reload profile</button>
<form id="profile-form"><fieldset id="fields" disabled><label for="name">Full name</label><input id="name" required maxlength="150" autocomplete="name"><label for="address">Address (optional)</label><textarea id="address" maxlength="255" rows="3" autocomplete="street-address"></textarea><button id="save" class="primary" type="submit">Save profile</button></fieldset></form>
<div class="avatar-area"><div class="portrait"><img id="avatar" alt="Your avatar" hidden><span id="avatar-placeholder">TM</span></div><div><h3>Your avatar</h3><p>JPEG, PNG or WebP · up to 2 MB</p><label for="file">Choose an image</label><input id="file" type="file" accept="image/jpeg,image/png,image/webp" disabled><button id="upload" disabled>Upload selected image</button><p id="object-path" hidden></p></div></div>
</div></div></section></main>
<dialog id="destination-dialog"><button id="close-detail" class="quiet">Close ×</button><p id="detail-province" class="eyebrow"></p><h2 id="detail-name"></h2><p id="detail-description"></p></dialog>
<footer>TravelMate · Make room for somewhere new.</footer>`;
function route() {
 const page=location.hash;
 const profile=page==='#profile';
 document.getElementById('profile-page')!.hidden=!profile;
 document.getElementById('explore-page')!.hidden=profile;
 document.querySelectorAll('nav a').forEach(a=>a.setAttribute('aria-current',a.getAttribute('href')===(profile?'#profile':page==='#saved'?'#saved':'#explore')?'page':'false'));
}
window.addEventListener('hashchange',route); route();
const el = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;
const notice = (message: string, error = false) => { el('notice').textContent = message; el('notice').classList.toggle('error', error); };
const rawError = (e: unknown): string => e instanceof Error ? e.message : typeof e === 'object' && e && 'message' in e ? String(e.message) : String(e);
function explain(e: unknown) {
 const message = rawError(e);
 if (/Invalid schema|schema.*exposed|PGRST106/i.test(message)) return `${message} — Check public in the Data API exposed schemas, then reload.`;
 if (/permission denied|row-level security/i.test(message)) return `${message} — Check the supplied Auth/Storage SQL policies. Do not disable RLS.`;
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
try { validConfig(); await start(); } catch(e) { notice(explain(e),true); el('catalog-notice').textContent=explain(e); }
async function start() {
 const supabase = createClient(url!, key!, { auth: { flowType: 'pkce', detectSessionInUrl: true, persistSession: true, autoRefreshToken: true } });
 type Profile = {id:string; full_name:string; address:string|null; avatar_object_path:string|null};
 let user: User|null=null, profile:Profile|null=null, preview:string|null=null, busy=false, generation=0;
 const storage = supabase.storage.from('travelmate-avatars');
 const api = supabase.schema('public');
 const explorer=createExplorer(supabase);
 function controls() {
  for(const id of ['login','logout','refresh','save','upload']) el<HTMLButtonElement>(id).disabled=busy || (['save','upload'].includes(id) && !profile);
  el<HTMLFieldSetElement>('fields').disabled=busy || !profile;
  el<HTMLInputElement>('file').disabled=busy || !profile;
 }
 function clearAvatar() {
  if(preview) URL.revokeObjectURL(preview); preview=null;
  el<HTMLImageElement>('avatar').removeAttribute('src'); el('avatar').hidden=true; el('avatar-placeholder').hidden=false;
 }
 function clearProfile() {
  profile=null; clearAvatar(); el<HTMLInputElement>('name').value=''; el<HTMLTextAreaElement>('address').value='';
  el('profile-id').textContent='Not loaded'; el('object-path').textContent='';el<HTMLInputElement>('file').value='';
 }
 async function run(action:()=>Promise<void>) {
  if(busy)return; busy=true; controls();
  try { await action(); } catch(e) { notice(explain(e),true); }
  finally { busy=false;controls(); }
 }
 async function loadProfile() {
  if(!user)return;const uid=user.id,token=++generation;
  clearProfile();controls(); notice('Loading your profile…');
  const {data,error}=await api.from('my_profile').select('id,full_name,address,avatar_object_path').maybeSingle();
  if(token!==generation || user?.id!==uid)return;
  if(error)throw error;
  if(!data)throw new Error('No active profile found. Confirm Auth SQL is installed, your email is confirmed, and your account is active. Imported demo accounts are not automatically linked.');
  if(data.id!==uid)throw new Error('Unexpected profile identity. Stop and review the RLS setup.');
  profile=data as Profile;el<HTMLInputElement>('name').value=profile.full_name;el<HTMLTextAreaElement>('address').value=profile.address??'';
  el('profile-id').textContent=String(profile.id);el('object-path').textContent=profile.avatar_object_path??'No avatar uploaded yet.';
  if(profile.avatar_object_path){
   const download=await storage.download(profile.avatar_object_path);
   if(token!==generation || user?.id!==uid)return;
   if(download.error)throw new Error(`Profile loaded, but avatar download failed: ${download.error.message}`);
   preview=URL.createObjectURL(download.data);el<HTMLImageElement>('avatar').src=preview;el('avatar').hidden=false;el('avatar-placeholder').hidden=true;
  }
  notice('Your profile is ready.');controls();
 }
 async function displayUser(next:User|null){
  generation++;const changed=user?.id!==next?.id;user=next;
  if(changed || !next)clearProfile();
  explorer.setUser(next?.id??null);
  el('guest').hidden=!!next;el('account').hidden=!next;el('email').textContent=next?.email??'';el('uid').textContent=next?.id??'';controls();
  if(next)await loadProfile();else notice('Ready to sign in.');
 }
 el('login').addEventListener('click',()=>void run(async()=>{
  notice('Opening Google sign-in…');
  const {error}=await supabase.auth.signInWithOAuth({provider:'google',options:{redirectTo:window.location.origin+'/',queryParams:{prompt:'select_account'}}});if(error)throw error;
 }));
 el('logout').addEventListener('click',()=>void run(async()=>{
  const {error}=await supabase.auth.signOut({scope:'local'});if(error)throw error;await displayUser(null);
 }));
 el('refresh').addEventListener('click',()=>void run(loadProfile));
 el('profile-form').addEventListener('submit',event=>{event.preventDefault();void run(async()=>{
  if(!profile || !user)throw new Error('Sign in and load a profile first.');
  const name=el<HTMLInputElement>('name').value.trim();if(!name)throw new Error('Enter your name.');
  const {error}=await api.rpc('update_my_profile',{p_full_name:name,p_address:el<HTMLTextAreaElement>('address').value.trim()||null,p_avatar_object_path:profile.avatar_object_path});
  if(error)throw error;await loadProfile();notice('Profile saved.');
 });});
 el('upload').addEventListener('click',()=>void run(async()=>{
  if(!profile || !user)throw new Error('Sign in and load a profile first.');
  const file=el<HTMLInputElement>('file').files?.[0];if(!file)throw new Error('Choose an image first.');
  const extensions:Record<string,string>={'image/jpeg':'jpg','image/png':'png','image/webp':'webp'};
  if(!extensions[file.type])throw new Error('Choose a JPEG, PNG or WebP image.');
  if(file.size===0 || file.size>2*1024*1024)throw new Error('Choose a nonempty image no larger than 2 MB.');
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
 supabase.auth.onAuthStateChange(event=>{
  if(event==='SIGNED_IN'){setTimeout(()=>void run(async()=>{const result=await supabase.auth.getUser();if(result.error)throw result.error;await displayUser(result.data.user);}),0);}
  if(event==='SIGNED_OUT'){generation++;user=null;clearProfile();explorer.setUser(null);el('account').hidden=true;el('guest').hidden=false;controls();notice('Signed out.');}
 });
 const params=new URLSearchParams(location.search),hash=new URLSearchParams(location.hash.slice(1));
 const oauthError=params.get('error_description')||hash.get('error_description');
 const {data,error}=await supabase.auth.getSession();
 if(error)throw error;
 // The SDK handles the PKCE callback once. Remove callback parameters afterwards.
 if(params.has('code')||params.has('error')||hash.has('error'))history.replaceState({},'',location.pathname+'#profile');route();
 await run(()=>displayUser(data.session?.user??null));
 if(oauthError)notice(`Google sign-in did not finish: ${oauthError}`,true);
}
