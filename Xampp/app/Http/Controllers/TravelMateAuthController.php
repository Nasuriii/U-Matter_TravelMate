<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class TravelMateAuthController extends Controller
{
    public function registerForm(): View
    {
        return view('travelmate.register');
    }

    public function loginForm(): View
    {
        return view('travelmate.login');
    }

    public function register(Request $request): RedirectResponse
    {
        if (is_string($request->input('email'))) {
            $request->merge(['email' => mb_strtolower(trim($request->input('email')))]);
        }
        $data = $request->validate([
            'full_name' => ['required', 'string', 'max:150'],
            'email' => ['required', 'string', 'email', 'max:254', Rule::unique('users', 'email')],
            // Bcrypt has a 72-byte limit, checked explicitly below.
            'password' => ['bail', 'required', 'string', 'min:12', 'max:72', 'confirmed',
                function ($attribute, $value, $fail) {
                    if (strlen($value) > 72) {
                        $fail('Please use a password of at most 72 bytes.');
                    }
                }],
            'account_type' => ['required', Rule::in(['traveler', 'business_owner'])],
        ]);

        try {
            $user = DB::transaction(function () use ($data) {
                $names = $data['account_type'] === 'business_owner'
                    ? ['traveler', 'business_owner'] : ['traveler'];
                $roles = DB::table('roles')->whereIn('name', $names)->pluck('id', 'name');
                if ($roles->count() !== count($names)) {
                    throw ValidationException::withMessages([
                        'account_type' => 'Account setup is unavailable. Ask the project administrator to check the role records.',
                    ]);
                }

                $user = User::create([
                    'full_name' => trim($data['full_name']),
                    'email' => $data['email'],
                    'password_hash' => Hash::make($data['password']),
                ]);
                foreach ($names as $name) {
                    DB::table('user_roles')->insert(['user_id' => $user->id, 'role_id' => $roles[$name]]);
                }
                if ($data['account_type'] === 'business_owner') {
                    DB::table('business_owners')->insert([
                        'user_id' => $user->id,
                        'contact_name' => $user->full_name,
                        'contact_email' => $user->email,
                    ]);
                }
                return $user;
            });
        } catch (QueryException $exception) {
            // Handle a concurrent registration using the same unique email.
            if ((int) ($exception->errorInfo[1] ?? 0) === 1062) {
                throw ValidationException::withMessages(['email' => 'That email is already registered. Please sign in.']);
            }
            throw $exception;
        }

        Auth::login($user, false);
        $request->session()->regenerate();
        $request->session()->put('tm_password_stamp',\App\Services\TravelMateSecurity::stamp($request->user()->getAuthPassword()));
        return redirect()->route('dashboard')->with('status', 'Your account is ready.');
    }

    public function login(Request $request): RedirectResponse
    {
        if (is_string($request->input('email'))) {
            $request->merge(['email' => mb_strtolower(trim($request->input('email')))]);
        }
        $data = $request->validate([
            'email' => ['required', 'string', 'email', 'max:254'],
            'password' => ['required', 'string', 'max:256'],
        ]);
        $key = 'travelmate-login:'.hash('sha256', $data['email'].'|'.$request->ip());
        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);
            throw ValidationException::withMessages(['email' => "Too many attempts. Try again in {$seconds} seconds."]);
        }

        RateLimiter::hit($key, 60);
        try {
            $authenticated = Auth::attempt([
                'email' => $data['email'],
                'password' => $data['password'],
                'account_status' => 'active',
            ], false);
        } catch (\RuntimeException $exception) {
            // Legacy/imported hashes must not turn a failed login into a 500.
            // Preserve unrelated errors; never bypass password verification.
            if ($exception->getMessage() !== 'This password does not use the Bcrypt algorithm.') {
                throw $exception;
            }
            $authenticated = false;
        }
        if (! $authenticated) {
            throw ValidationException::withMessages(['email' => 'Unable to sign in with those details.']);
        }

        RateLimiter::clear($key);
        $request->session()->regenerate();
        $request->session()->put('tm_password_stamp',\App\Services\TravelMateSecurity::stamp($request->user()->getAuthPassword()));
        return redirect()->intended(route('dashboard'));
    }

    public function dashboard(Request $request): View
    {
        $roles = DB::table('roles')
            ->join('user_roles', 'roles.id', '=', 'user_roles.role_id')
            ->where('user_roles.user_id', $request->user()->id)
            ->orderBy('roles.name')->pluck('roles.name');

        return view('travelmate.dashboard', [
            'user' => $request->user(),
            'roles' => $roles,
            'destinations' => DB::table('destinations')->where('is_active', 1)
                ->orderBy('name')->limit(20)->get(['name', 'province']),
        ]);
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('login')->with('status', 'You have signed out.');
    }
}
