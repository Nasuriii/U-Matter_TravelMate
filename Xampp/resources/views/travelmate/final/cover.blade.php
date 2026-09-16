<div class="tm-cover" data-photo-frame>
<div class="tm-cover-fallback"><span>{{ $coverLabel??'TravelMate' }}</span>@include('travelmate.final.icon',['name'=>$coverIcon??'compass'])</div>
@if($cover)<img src="{{ route('content.image',$cover->id) }}" alt="{{ $cover->caption ?: $coverLabel }}" loading="lazy" width="640" height="420" data-fallback-image>@endif
</div>