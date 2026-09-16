@extends('travelmate.layout')
@section('title', 'Reported issues')
@section('content')
<main class="browse-shell tm-operations">
<header class="browse-heading"><a href="{{ $admin?route('admin.index'):route('dashboard') }}">← {{ $admin?'Admin dashboard':'My account' }}</a><h1>{{ $admin?'Reported issues':'My reported issues' }}</h1>@unless($admin)<a class="chip" href="{{ route('issues.create') }}">Report an issue →</a>@endunless</header>
@if($admin)<nav class="browse-tabs">@foreach(['pending','resolved','all'] as $s)<a class="chip" href="{{ route('operations.issues',['status'=>$s]) }}">{{ ucfirst($s) }}</a>@endforeach</nav>@endif
<section class="planner-panel">@forelse($issues as $issue)<article class="tm-operation-row"><h2>Issue #{{ $issue->id }} · {{ ucfirst($issue->report_type) }}</h2><p>{{ ucfirst($issue->status) }} · {{ $issue->submitted_at }} UTC</p><p>{{ \Illuminate\Support\Str::limit($issue->description,180) }}</p><a class="chip" href="{{ route($admin?'operations.issue':'issues.show',$issue->id) }}">Open issue →</a></article>@empty<p>No reported issues in this list.</p>@endforelse</section>@include('travelmate.browse-pagination',['paginator'=>$issues])
</main>
@endsection
