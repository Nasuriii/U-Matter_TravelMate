@extends('travelmate.layout')
@section('title', 'Saved activity report')
@section('content')
<main class="browse-shell tm-operations">
<header class="browse-heading"><a href="{{ route('operations.analytics') }}">← Activity dashboard</a><h1>Activity report #{{ $report->id }}</h1><p>Generated {{ $report->generated_at }} UTC</p><p>Period: {{ $report->period_start??'All dates' }} {{ $report->period_end?'to '.$report->period_end.' (inclusive)':'' }}</p><a class="chip" href="{{ route('operations.csv',$report->id) }}">Download CSV for Excel →</a></header>
<section class="planner-panel"><p>These saved values do not change. Status counts describe records created in the period, using their status at generation time.</p><div class="tm-table-wrap"><table><thead><tr><th>Metric</th><th>Value</th><th>Unit</th></tr></thead><tbody>@foreach($metrics as $metric)<tr><td>{{ $metric->name }}</td><td>{{ number_format((float)$metric->value,0) }}</td><td>{{ $metric->unit }}</td></tr>@endforeach</tbody></table></div></section>
</main>
@endsection
