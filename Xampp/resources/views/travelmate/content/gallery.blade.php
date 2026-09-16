@php($gallery=\App\Services\TravelMateContent::photos($photoKind,$photoTarget)->where('status','approved')->get()->filter(fn($p)=>preg_match('~\Atravelmate-media/[a-f0-9-]{36}\.(jpg|png|webp)\z~D',$p->url)))
@if($gallery->isNotEmpty())<section class="planner-panel"><h2>Photos</h2><div class="tm-gallery">
@foreach($gallery as $photo)<figure><img loading="lazy" src="{{ route('content.image',$photo->id) }}" alt="{{ $photo->caption ?: 'Photo of '.$photoName }}">@if($photo->caption)<figcaption>{{ $photo->caption }}</figcaption>@endif<p><a class="link-btn" href="{{ route('issues.create',['type'=>'photo','target'=>$photo->id]) }}">Report photo</a></p></figure>@endforeach
</div></section>@endif
