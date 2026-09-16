@php($contentDetails=\App\Services\TravelMateContent::details($listing))
<section class="planner-panel"><h2>{{ match($listing->listing_type){'hotel'=>'Amenities','restaurant'=>'Menu',default=>'Visiting schedule'} }}</h2>
@if($listing->listing_type==='hotel')<div class="tm-chips">@forelse($contentDetails['amenities'] as $a)<span class="chip">{{ $a->name }}</span>@empty<p>No amenities listed yet.</p>@endforelse</div>
@elseif($listing->listing_type==='restaurant')<div class="tm-menu">@forelse($contentDetails['menu'] as $item)
<article><h3>{{ $item->name }}</h3><p>{{ $item->category }}</p><p>{{ $item->description }}</p><strong>{{ $item->price===null?'Price not provided':'₱'.number_format((float)$item->price,2) }}</strong>@if(!$item->is_available)<p>Currently unavailable</p>@endif</article>
@empty<p>No menu items listed yet.</p>@endforelse</div>
@else<p>Local visiting hours. These are not reservation slots.</p><dl class="browse-facts">@forelse($contentDetails['schedules'] as $item)<div><dt>{{ $item->operating_day }}</dt><dd>{{ $item->schedule_text }}</dd></div>@empty<p>No schedule provided yet.</p>@endforelse</dl>@endif
</section>
