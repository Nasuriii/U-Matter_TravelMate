// Edit the HTML in the template string. Ids used by main.ts must stay the same.
export const authPage = `<section data-page="auth" class="auth" hidden>
<aside class="auth-photo"><a href="#/" class="brand light">TRAVEL<span>MATE</span></a>
<div class="auth-copy"><h2 data-for="login">Welcome back</h2><h2 data-for="register">Start your journey</h2><h2 data-for="forgot">Forgot your password?</h2><h2 data-for="reset">Choose a new password</h2>
<p data-for="login">Log in to see your saved places and keep planning your next trip.</p><p data-for="register">Create a free account to save destinations, plan trips and share reviews.</p><p data-for="forgot">No problem. We'll email you a link to reset it.</p><p data-for="reset">Pick something you haven't used before.</p></div>
<small>© 2026 TravelMate — a U-Matter platform</small></aside>
<div class="auth-panel"><div class="auth-box"><a class="back" href="#/">← Back to home</a>
<h1 data-for="login">Log in</h1><h1 data-for="register">Create your account</h1><h1 data-for="forgot">Reset password</h1><h1 data-for="reset">New password</h1>
<p class="sub" data-for="login">Welcome back! Please enter your details.</p><p class="sub" data-for="register">Register now to start your journey.</p><p class="sub" data-for="forgot">Enter your email and we'll send a reset link.</p><p class="sub" data-for="reset">Enter and confirm your new password.</p>
<form id="auth-form" novalidate>
<div class="row2" data-for="register"><div><label for="reg-first">First name</label><input id="reg-first" maxlength="75" autocomplete="given-name" placeholder="Juan"></div><div><label for="reg-last">Last name</label><input id="reg-last" maxlength="75" autocomplete="family-name" placeholder="Dela Cruz"></div></div>
<div data-for="login register forgot"><label for="auth-email">Email</label><input id="auth-email" type="email" autocomplete="email" placeholder="juan@email.com"></div>
<div data-for="login register reset"><label for="auth-password">Password</label><div class="pw-wrap"><input id="auth-password" type="password" autocomplete="current-password" placeholder="At least 8 characters"><button id="toggle-pw" type="button">Show</button></div></div>
<div data-for="register reset"><label for="auth-confirm">Confirm password</label><input id="auth-confirm" type="password" autocomplete="new-password"></div>
<div class="auth-row" data-for="login"><a href="#/forgot">Forgot password?</a></div>
<button id="auth-submit" class="primary" type="submit"><span data-for="login">Log in</span><span data-for="register">Create account</span><span data-for="forgot">Send reset link</span><span data-for="reset">Save new password</span></button></form>
<p id="auth-notice" class="auth-notice" role="status" aria-live="polite"></p>
<div data-for="login register"><p class="divider">or continue with</p><button id="login" type="button">Continue with Google</button></div>
<p class="switch" data-for="login">Don't have an account? <a href="#/register">Sign up</a></p><p class="switch" data-for="register">Already have an account? <a href="#/login">Log in</a></p><p class="switch" data-for="forgot reset"><a href="#/login">Back to log in</a></p>
</div></div></section>`;
