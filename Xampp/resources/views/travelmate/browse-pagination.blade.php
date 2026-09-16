@if($paginator->hasPages())
<nav class="browse-pagination" aria-label="Results pages">
@if($paginator->previousPageUrl())<a rel="prev" href="{{ $paginator->previousPageUrl() }}">← Previous</a>@endif
<span>Page {{ $paginator->currentPage() }} of {{ $paginator->lastPage() }}</span>
@if($paginator->hasMorePages())<a rel="next" href="{{ $paginator->nextPageUrl() }}">Next →</a>@endif
</nav>
@endif
