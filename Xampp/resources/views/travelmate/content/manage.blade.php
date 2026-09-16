@extends('travelmate.layout')
@section('title','Photos and details')
@section('content')
<main class="browse-shell tm-content-editor"><header class="browse-heading"><a class="back-link" href="{{ $kind==='destination'?route('admin.places.edit',$row->id):($admin?route('admin.show',$row->id):route('owner.edit',$row->id)) }}">← Back to {{ $row->name }}</a><h1>Photos & details</h1><p>{{ $row->name }}</p></header>
@include('travelmate.errors')
<section class="planner-panel"><h2>Add a photo</h2><p>JPEG, PNG or WebP, up to 2 MB and 4096 × 4096 pixels. Maximum 20 photos. Lower display numbers appear first.</p>
<form class="profile-form" method="POST" enctype="multipart/form-data" action="{{ route('content.upload',[$kind,$row->id]) }}">@csrf
<label>Photo<input required type="file" name="photo" accept="image/jpeg,image/png,image/webp"></label><label>Caption<input name="caption" maxlength="255"></label><label>Display order<input type="number" name="sort_order" value="0" min="0" max="9999" required></label><button class="profile-save-btn">Upload photo</button></form></section>
<section class="planner-panel"><h2>Manage photos</h2><div class="tm-gallery">
@forelse($photos as $photo)<article>
@if(preg_match('~\Atravelmate-media/[a-f0-9-]{36}\.(jpg|png|webp)\z~D',$photo->url))<img loading="lazy" src="{{ route('content.image',$photo->id) }}" alt="{{ $photo->caption ?: 'Uploaded photo' }}">@else<p>Older external photo: upload a local replacement.</p>@endif
<p>{{ $photo->caption }}</p><p>{{ ucfirst($photo->status) }} · Order {{ $photo->sort_order }}</p>
<form method="POST" action="{{ route('content.photo',[$kind,$row->id,$photo->id]) }}">@csrf
@if($admin)<button class="chip" name="action" value="approved">Approve</button><button class="chip" name="action" value="rejected">Reject</button>@endif<button class="wishlist-remove" name="action" value="remove">Remove</button></form></article>
@empty<p>No photos uploaded yet.</p>@endforelse</div></section>
@if($kind==='listing')
<section class="planner-panel"><h2>Business details</h2><p>Saving or removing these details submits the listing for approval again.</p>
@if($row->listing_type==='hotel')
<form class="profile-form" method="POST" action="{{ route('content.save',[$kind,$row->id]) }}">@csrf<input type="hidden" name="action" value="amenities"><div class="tm-chips">
@foreach($amenities as $a)<label><input type="checkbox" name="amenities[]" value="{{ $a->id }}" @checked(in_array($a->id,array_column($extras['amenities'],'id')))>{{ $a->name }}</label>@endforeach</div><button class="profile-save-btn">Save amenities</button></form>
@if($admin)<form class="profile-form" method="POST" action="{{ route('content.amenity') }}">@csrf<label>New amenity name<input name="name" required maxlength="100"></label><button class="chip">Add amenity option</button></form>@else<p>Ask an admin to add any missing amenity option.</p>@endif
@elseif($row->listing_type==='restaurant')
@foreach($extras['menu'] as $item)@include('travelmate.content.menu-form',['item'=>$item])@endforeach
<h3>Add menu item</h3>@include('travelmate.content.menu-form',['item'=>null])
@else
@foreach($extras['schedules'] as $item)<div class="tm-schedule"><strong>{{ $item->operating_day }}</strong><p>{{ $item->schedule_text }}</p><form method="POST" action="{{ route('content.save',[$kind,$row->id]) }}">@csrf<input type="hidden" name="item_id" value="{{ $item->id }}"><button class="wishlist-remove" name="action" value="remove_schedule">Remove</button></form></div>@endforeach
<form class="profile-form" method="POST" action="{{ route('content.save',[$kind,$row->id]) }}">@csrf<input type="hidden" name="action" value="schedule"><label>Day<select name="operating_day">@foreach(['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'] as $day)<option>{{ $day }}</option>@endforeach</select></label><label>Local hours or closure note<input required name="schedule_text" maxlength="255" placeholder="9:00 AM – 5:00 PM, or Closed"></label><button class="profile-save-btn">Save day schedule</button></form><p>Saving an existing day replaces its hours. Missing days have no published hours.</p>
@endif</section>@endif
</main>@endsection
