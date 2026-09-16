@extends('travelmate.layout')
@section('title', 'Activity dashboard')
@section('content')
<main class="browse-shell tm-operations">
<header class="browse-heading"><a href="{{ route('admin.index') }}">← Admin dashboard</a><h1>Activity dashboard</h1><p>Counts of records created or submitted during the selected period, using their status now.</p></header>@include('travelmate.errors')
<form method="GET" action="{{ route('operations.analytics') }}" class="planner-panel profile-form"><div class="profile-row"><label>Start date (UTC)<input type="date" name="period_start" value="{{ $period['period_start'] }}" min="2000-01-01" max="2099-12-30"></label><label>End date (UTC, inclusive)<input type="date" name="period_end" value="{{ $period['period_end'] }}" min="2000-01-01" max="2099-12-30"></label></div><div><button class="profile-save-btn">Apply dates</button> <a href="{{ route('operations.analytics') }}">All dates</a></div><p>Provide both dates or leave both blank. Booking counts include demo and manually entered records.</p></form>
<div class="tm-metrics">@foreach($metrics as $name=>$value)<article><span>{{ $name }}</span><strong>{{ number_format($value) }}</strong></article>@endforeach</div>
<section class="planner-panel"><h2>Save a report</h2><p>Create a fixed snapshot of these metrics for download. The snapshot uses the applied dates.</p><form method="POST" action="{{ route('operations.generate') }}">@csrf<input type="hidden" name="period_start" value="{{ $period['period_start'] }}"><input type="hidden" name="period_end" value="{{ $period['period_end'] }}"><button class="profile-save-btn">Generate report snapshot</button></form></section>
<section class="planner-panel"><h2>Saved reports — all periods</h2>@forelse($reports as $report)<p><a href="{{ route('operations.report',$report->id) }}">Report #{{ $report->id }}</a> · {{ $report->generated_at }} UTC · {{ $report->period_start??'All dates' }} {{ $report->period_end?'to '.$report->period_end:'' }}</p>@empty<p>No saved reports yet.</p>@endforelse</section>@include('travelmate.browse-pagination',['paginator'=>$reports])
</main>
@endsection
