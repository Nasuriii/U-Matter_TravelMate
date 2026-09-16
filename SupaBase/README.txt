TRAVELMATE GOOGLE LOGIN / PROFILE / AVATAR TEST

This is a small standalone TypeScript + Vite test page, not the full TravelMate
website. It does not use Laravel or XAMPP. Your old project is unchanged.

1. REQUIREMENTS
Install a current Node.js LTS release from https://nodejs.org/ (Node 22.12+;
Node 24 LTS recommended). Close/reopen Command Prompt after installation.
Run node -v and npm -v to check installation.

Your Supabase project must already contain:
- The original TravelMate database import and auth_user_id addition.
- 01_Auth_and_Profile.sql from TravelMate-Auth-Storage.zip, successfully installed.
- PRIVATE travelmate-avatars bucket (2 MB; JPEG, PNG, WebP).
- 03_Avatar_Storage_Policies.sql successfully installed.
- Google provider enabled with its Google Cloud client ID and secret.
Do NOT rerun the database import or those migrations just to install this page.

2. UNZIP AND CONFIGURE
Extract TravelMate-Login-Test.zip. Open its TravelMate-Login-Test folder.
The correct folder contains package.json, README.txt, src and .env.example.
Click the File Explorer address bar, type cmd, press Enter.
In that Command Prompt run:

copy .env.example .env.local
notepad .env.local

Replace placeholders in .env.local:
VITE_SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY

Get the PROJECT URL from your project's Connect dialog or Data API settings.
Get the PUBLISHABLE key from Settings -> API Keys (starts sb_publishable_).
A legacy anon key also works. Never paste the service_role key, secret key,
database password, or Google client secret. The page rejects known secret keys.
All VITE_ variables are bundled into browser code: they cannot hold secrets.
Save and close Notepad. .env.local must not end in .txt.
You do not need to send these values to ChatGPT.

3. DASHBOARD SETTINGS
Supabase -> Data API settings:
- Data API enabled.
- Add api to Exposed schemas so api.my_profile and api.update_my_profile work.
- Keep travelmate, travelmate_private and auth unexposed.
- Do not add broad grants, disable RLS or create allow-all policies.
The earlier private-schema notice for travelmate can remain; it is expected.

Supabase -> Authentication -> URL Configuration:
Site URL: http://localhost:5173
Allowed Redirect URL: http://localhost:5173/

Google Cloud OAuth Web client:
Authorized JavaScript origin: http://localhost:5173
Authorized redirect URI: the EXACT Supabase Google provider callback URL,
usually https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback .
The Supabase callback and frontend return URL are different settings.
If Google's consent app is in Testing, register your test Google accounts.
Keep both Skip nonce checks and Allow users without an email OFF in Supabase.

4. INSTALL AND START (COMMAND PROMPT)
Run these inside the folder containing package.json:

npm ci
npm run dev

Open http://localhost:5173 in your browser. Keep the terminal open.
Use localhost consistently, not 127.0.0.1, for this OAuth test.
The port is fixed to 5173. If occupied, stop the other dev server first.
To stop this page: press Ctrl+C in its terminal.
After editing .env.local, stop and restart npm run dev.

5. TEST YOUR FIRST ACCOUNT
Click Continue with Google. Sign in using a Google test account.
The browser should return to the page and show your email, profile form, and IDs.
Open 'Account identifiers for testing' to see the Auth UUID and TravelMate ID.
Edit name/address -> Save profile -> Reload profile -> verify changes remain.
Choose an image <=2 MB -> Upload selected image -> check the preview.
The file is stored under your Auth UUID and a random filename. Its relative
object path is saved to avatar_object_path. Private previews use an authenticated
Storage download, not a public URL. Replacing an avatar attempts to remove the
previous object after saving the new reference. Save profile edits BEFORE upload;
upload reloads the profile and uses the last saved name/address.
Sign out, sign back in, verify your saved profile and avatar reload.
Never share a URL containing OAuth code/token parameters; this page removes
callback parameters after the SDK processes them.

6. TEST A SECOND ACCOUNT
Use another browser profile or a private window and sign in as a second Google
account. It should receive a different Auth UUID and TravelMate ID and its own
profile. It must not display the first account's name/address/avatar.
This proves basic session separation, not all cross-user security properties.
For formal evidence we still need explicit denied-operation tests. In particular,
using the second session's Storage client to request the FIRST account's known
avatar object path must fail. No service_role key or administrator session may
be used for those tests. The page itself does not expose a cross-user probe UI.

7. COMMON PROBLEMS
- 'Setup needed': fill .env.local and restart npm run dev.
- npm is not recognized: install Node.js LTS and reopen Command Prompt.
- PowerShell blocks npm.ps1: use Command Prompt as instructed; no need to relax
  your system execution policy.
- redirect_uri_mismatch: check Google's authorized redirect URI against the
  exact Supabase provider callback, not the frontend URL.
- access_denied from Google: check test-user/audience configuration and the
  account selected, or retry if consent was cancelled.
- 'Invalid schema' / PGRST106: add api to exposed schemas in Data API settings.
- Profile missing: confirm Auth SQL is installed, email is confirmed, account
  is active, and this is the same Supabase project used by your .env.local.
- 'Database error saving new user': inspect Supabase Auth/database logs. An
  imported email collision deliberately requires administrator-reviewed linking;
  do not auto-link an existing admin profile merely by matching its email.
- Permission/RLS failure: inspect the exact failing policy/grant. Do not disable RLS.
- Bucket not found: create private bucket travelmate-avatars in THIS project.
- Avatar upload denied: ensure Storage policies are installed, account is active,
  bucket is private, and signed-in UUID owns the path.
- Image uploaded but profile save unconfirmed: reload first. Network failure can
  hide a committed save, so the newly uploaded object is deliberately retained.
  Remove confirmed orphan images later through the Storage UI/API.
- No avatar preview: use Reload profile; check Storage access and object path.
- Credentials pasted in screenshots: redact them before sharing errors.

8. VALIDATION / SCOPE
TypeScript strict check and Vite production build passed in the authoring runtime.
Local Vite server started successfully. Automated browser inspection was unavailable
because the browser executable was absent. Live Google OAuth, real profile calls
and Storage service uploads were NOT tested against your project.
Run npm run build yourself to repeat the compilation check.
This is development-only: no admin tools, bookings, directory or full-site UI yet.
Dependencies are pinned in package-lock.json; use npm ci for reproducibility.
The browser uses PKCE via Supabase SDK; do not manually exchange the same code
again. Sign-out clears the local session. Policies, not hidden buttons, enforce
access. Public/publishable keys are intended for clients; privileged keys are not.

NEXT
After sign-in/profile/avatar work, record the results, test explicit denied access,
then implement directory and trip policies before connecting the full prototype.
Keep v_public_listings. This page neither drops it nor exposes it.

References:
https://supabase.com/docs/guides/auth/social-login/auth-google
https://supabase.com/docs/guides/storage/security/access-control
https://vite.dev/guide/
