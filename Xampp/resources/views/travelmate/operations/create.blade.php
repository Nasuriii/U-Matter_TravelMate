@extends('travelmate.layout')
@section('title', 'Report an issue')
@section('content')
<main class="browse-shell tm-operations">
<header class="browse-heading"><a href="{{ route('issues.index') }}">← My reported issues</a><h1>Report an issue</h1><p>Explain what happened and what you expected. Your report is visible to you and the admins.</p></header>@include('travelmate.errors')
<section class="planner-panel"><form class="profile-form" method="POST" action="{{ route('issues.store') }}">@csrf
@if($target)<p>Related item: {{ $target['label'] }}</p><input type="hidden" name="report_type" value="{{ $type }}"><input type="hidden" name="target_id" value="{{ $target['id'] }}">@else<label>Category<select name="report_type">@foreach(\App\Services\TravelMateOperations::REPORT_TYPES as $t)<option value="{{ $t }}" @selected(old('report_type',$type)===$t)>{{ ucfirst($t) }}</option>@endforeach</select></label>@endif
<label>What went wrong?<textarea name="description" minlength="10" maxlength="5000" required rows="6">{{ is_string(old('description'))?old('description'):'' }}</textarea></label><p>Include the page or item name. Do not include passwords or payment details.</p><button class="profile-save-btn">Submit issue</button></form></section>
</main>
@endsection
