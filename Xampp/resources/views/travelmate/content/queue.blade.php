@extends('travelmate.layout')
@section('title','Photo approvals')
@section('content')<main class="browse-shell"><header class="browse-heading"><a href="{{ route('admin.index') }}">← Admin dashboard</a><h1>Photo approvals</h1></header>
<section class="planner-panel">@forelse($photos as $photo)<p>Photo #{{ $photo->id }} — {{ $photo->caption ?: 'No caption' }} <a class="chip" href="{{ route('content.manage',[$photo->listing_id?'listing':'destination',$photo->listing_id?:$photo->destination_id]) }}">Review photos →</a></p>@empty<p>No pending photos.</p>@endforelse</section>
@include('travelmate.browse-pagination',['paginator'=>$photos])</main>@endsection
