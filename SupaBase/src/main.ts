import { createClient, type User } from '@supabase/supabase-js';
import './style.css';

// Static markup only. User/database content is inserted through textContent/value.
document.querySelector<HTMLDivElement>('#app')!.innerHTML = `
<header><a href="/" class="brand">TRAVEL<span>MATE</span></a><span class="tag">ACCOUNT TEST</span></header>
<main><section class="intro"><p class="eyebrow">YOUR NEXT CHAPTER</p><h1>A little setup.<br>A world to explore.</h1><p>Sign in, make your profile yours, and try your private avatar storage.</p><div class="route"><span>01 · Sign in</span><span>02 · Profile</span><span>03 · Avatar</span></div></section>
<section class="card"><div id="notice" role="status" aria-live="polite">Checking configuration…</div>
<div id="guest" hidden><h2>Welcome to TravelMate</h2><p>Use your Google test account to get started.</p><button id="login" class="primary">Continue with Google</button></div>
<div id="account" hidden><div class="account-top"><div><p class="eyebrow">SIGNED IN</p><p id="email"></p></div><button id="logout" class="quiet">Sign out</button></div>
<details><summary>Account identifiers for testing</summary><dl><dt>Auth UUID</dt><dd id="uid"></dd><dt>TravelMate ID</dt><dd id="profile-id">Not loaded</dd></dl></details>
<button id="refresh" class="quiet">Reload profile</button>
<form id="profile-form"><fieldset id="fields" disabled><label for="name">Full name</label><input id="name" required maxlength="150" autocomplete="name"><label for="address">Address <span>(optional)</span></label><textarea id="address" maxlength="255" rows="3" autocomplete="street-address"></textarea><button id="save" class="primary" type="submit">Save profile</button></fieldset></form>
<div class="avatar-area"><div class="portrait"><img id="avatar" alt="Your private avatar" hidden><span id="avatar-placeholder">TM</span></div><div><h3>Your avatar</h3><p>Private · JPEG, PNG or WebP · up to 2 MB</p><label for="file">Choose an image</label><input id="file" type="file" accept="image/jpeg,image/png,image/webp" disabled><button id="upload" disabled>Upload selected image</button><p id="object-path" class="small"></p></div></div>
</div></section></main><footer>TravelMate development test · Your original website is unchanged.</footer>`;
const el = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;
const notice = (message: string, error = false) => { el('notice').textContent = message; el('notice').classList.toggle('error', error); };
const rawError = (e: unknown): string => e instanceof Error ? e.message : typeof e === 'object' && e && 'message' in e ? String(e.message) : String(e);
function explain(e: unknown) {
 const message = rawError(e);
 if (/Invalid schema|schema.*exposed|PGRST106/i.test(message)) return `${message} — Add api to the Data API exposed schemas, then reload.`;
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
try { validConfig(); await start(); } catch(e) { notice(explain(e),true); }
async function start() {
 const supabase = createClient(url!, key!, { auth: { flowType: 'pkce', detectSessionInUrl: true, persistSession: true, autoRefreshToken: true } });
 type Profile = {id: number|string; auth_user_id:string; full_name:string; address:string|null; avatar_object_path:string|null};
 let user: User|null=null, profile:Profile|null=null, preview:string|null=null, busy=false, generation=0;
 const storage = supabase.storage.from('travelmate-avatars');
 const api = supabase.schema('api');
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
  const {data,error}=await api.from('my_profile').select('id,auth_user_id,full_name,address,avatar_object_path').maybeSingle();
  if(token!==generation || user?.id!==uid)return;
  if(error)throw error;
  if(!data)throw new Error('No active profile found. Confirm Auth SQL is installed, your email is confirmed, and your account is active. Imported demo accounts are not automatically linked.');
  if(data.auth_user_id!==uid)throw new Error('Unexpected profile identity. Stop and review the RLS setup.');
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
  const uid=user.id,previous=profile.avatar_object_path;
  const path=`${uid}/${crypto.randomUUID()}.${extensions[file.type]}`;
  notice('Uploading your private avatar…');
  const {error}=await storage.upload(path,file,{contentType:file.type,upsert:false});if(error)throw error;
  // Storage and profile changes are separate transactions. On RPC failure retain
  // the uploaded file: a network error can hide a committed profile update.
  const saved=await api.rpc('update_my_profile',{p_full_name:profile.full_name,p_address:profile.address,p_avatar_object_path:path});
  if(saved.error)throw new Error(`Image uploaded at ${path}, but saving its profile link was not confirmed: ${saved.error.message}. Reload your profile before retrying; the uploaded file was retained.`);
  let cleanup='';
  if(previous && previous.startsWith(uid+'/')){const removed=await storage.remove([previous]);if(removed.error)cleanup=' Previous image cleanup failed; it remains in your private folder.';}
  el<HTMLInputElement>('file').value='';await loadProfile();notice('Avatar uploaded and linked to your profile.'+cleanup);
 }));
 // Do not make awaited Supabase calls inside the Auth event callback.
 supabase.auth.onAuthStateChange(event=>{
  if(event==='SIGNED_OUT'){generation++;user=null;clearProfile();el('account').hidden=true;el('guest').hidden=false;controls();notice('Signed out.');}
 });
 const params=new URLSearchParams(location.search),hash=new URLSearchParams(location.hash.slice(1));
 const oauthError=params.get('error_description')||hash.get('error_description');
 const {data,error}=await supabase.auth.getSession();
 if(error)throw error;
 // The SDK handles the PKCE callback once. Remove callback parameters afterwards.
 if(params.has('code')||params.has('error')||hash.has('error'))history.replaceState({},'',location.pathname);
 await run(()=>displayUser(data.session?.user??null));
 if(oauthError)notice(`Google sign-in did not finish: ${oauthError}`,true);
}
