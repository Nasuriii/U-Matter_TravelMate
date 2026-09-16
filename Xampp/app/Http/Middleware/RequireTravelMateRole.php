<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RequireTravelMateRole
{
    public function handle(Request $request, Closure $next, string $role)
    {
        abort_unless($request->user() && DB::table('user_roles as ur')
            ->join('roles as r', 'r.id', '=', 'ur.role_id')
            ->where('ur.user_id', $request->user()->id)->where('r.name', $role)->exists(), 403);
        return $next($request);
    }
}
