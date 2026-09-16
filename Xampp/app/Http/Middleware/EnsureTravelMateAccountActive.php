<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureTravelMateAccountActive
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->account_status !== 'active' || !is_string($request->session()->get('tm_password_stamp')) || !hash_equals(\App\Services\TravelMateSecurity::stamp($request->user()->getAuthPassword()), $request->session()->get('tm_password_stamp'))) {
            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();
            return redirect()->route('login')->withErrors(['email' => 'Please sign in with an active account.']);
        }
        $response = $next($request);
        $response->headers->set('Cache-Control', 'no-store, private');
        return $response;
    }
}
