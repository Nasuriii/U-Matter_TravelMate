@extends('travelmate.layout')
@section('title', 'Issue details')
@section('content')
<main class="browse-shell tm-operations">
<header class="browse-heading"><a href="{{ route($admin?'operations.issues':'issues.index') }}">← Reported issues</a><h1>Issue #{{ $issue->id }}</h1><p>{{ ucfirst($issue->report_type) }} · {{ ucfirst($issue->status) }}</p></header>@include('travelmate.errors')
<section class="planner-panel"><p class="browse-prose">{{ $issue->description }}</p><dl class="browse-facts"><div><dt>Submitted UTC</dt><dd>{{ $issue->submitted_at }}</dd></div><div><dt>Resolved UTC</dt><dd>{{ $issue->resolved_at??'Not resolved' }}</dd></div><div><dt>Assigned</dt><dd>{{ $issue->assigned_to?'Assigned to an admin':'Awaiting assignment' }}</dd></div></dl>
@if($admin)<p>Reporter account #{{ $issue->user_id }} · Assigned admin #{{ $issue->assigned_to??'None' }}</p>
@if($issue->listing_id)<a class="chip" href="{{ route('admin.show',$issue->listing_id) }}">Review related listing →</a>@endif
@if($issue->destination_id)<a class="chip" href="{{ route('admin.places.edit',$issue->destination_id) }}">Review related destination →</a>@endif
@if($issue->transport_id)<a class="chip" href="{{ route('transport.review',$issue->transport_id) }}">Review related transport →</a>@endif
@if($issue->review_id)<p>Related review #{{ $issue->review_id }}</p><a class="chip" href="{{ route('admin.reviews') }}">Review moderation →</a>@endif
@if($issue->photo_id)@php($issuePhoto=\Illuminate\Support\Facades\DB::table('photos')->where('id',$issue->photo_id)->first())@if($issuePhoto)<a class="chip" href="{{ route('content.manage',[$issuePhoto->listing_id?'listing':'destination',$issuePhoto->listing_id?:$issuePhoto->destination_id]) }}">Review related photo #{{ $issue->photo_id }} →</a>@endif @endif
<form class="tm-action-row" method="POST" action="{{ route('operations.moderate',$issue->id) }}">@csrf @method('PATCH')<input type="hidden" name="fingerprint" value="{{ \App\Services\TravelMateOperations::fingerprint($issue) }}"><button class="chip" name="action" value="assign">Assign to me</button>@if($issue->status==='pending')<button class="profile-save-btn" name="action" value="resolve">Mark resolved</button>@else<button class="chip" name="action" value="reopen">Reopen issue</button>@endif</form><p>Resolving records the outcome of your review. Use the related management page to change the reported content.</p>@endif
</section>
</main>
@endsection
