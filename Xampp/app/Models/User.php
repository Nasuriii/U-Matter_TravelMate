<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use Notifiable;

    protected $fillable = ['full_name', 'email', 'password_hash', 'address'];
    protected $hidden = ['password_hash'];

    // The existing TravelMate schema has no remember_token column.
    protected $rememberTokenName = '';

    public function getAuthPasswordName(): string
    {
        return 'password_hash';
    }

    protected function casts(): array
    {
        return ['email_verified_at' => 'datetime'];
    }
}
