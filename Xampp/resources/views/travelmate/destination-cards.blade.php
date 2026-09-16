<div class="tm-cards">
@forelse($destinations as $destination)
<article class="landing-feature">
<p class="eyebrow">{{ $destination->province }}</p>
<h3>{{ $destination->name }}</h3>
</article>
@empty
<p>No destinations are available yet.</p>
@endforelse
</div>
