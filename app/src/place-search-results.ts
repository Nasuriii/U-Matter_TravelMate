export type SearchPlaceKind = 'destination' | 'restaurant' | 'attraction' | 'hotel';
export type SearchPlace = {id: string; name: string; kind: SearchPlaceKind; area: string; image?: string; path: string};
export function normalizePlaceQuery(value: string) { return value.normalize('NFKC').trim().replace(/\s+/g, ' ').slice(0, 100); }
// Quote the complete PostgREST value, including punctuation; escape LIKE wildcards.
export function placeContainsFilter(value: string) {
  const pattern = '%' + normalizePlaceQuery(value).replace(/[\\%_*]/g, character => '\\' + character) + '%';
  return '"' + pattern.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"';
}
export function selectSearchPreviews(query: string, places: SearchPlace[], limit = 8) {
  const term = normalizePlaceQuery(query).toLocaleLowerCase();
  const score = (place: SearchPlace) => {
    const name = place.name.toLocaleLowerCase();
    return name === term ? 4 : name.startsWith(term) ? 3 : name.includes(term) ? 2 : 1;
  };
  const ranked = [...new Map(places.map(place => [place.path, place])).values()].sort((a, b) => score(b) - score(a) || Number(b.kind === 'destination') - Number(a.kind === 'destination') || a.name.localeCompare(b.name));
  // Reserve room for each kind before filling the remaining preview slots.
  const selected = new Set<SearchPlace>();
  for (const kind of ['destination', 'restaurant', 'attraction', 'hotel']) {
    const first = ranked.find(place => place.kind === kind);
    if (first && selected.size < limit) selected.add(first);
  }
  for (const place of ranked) { if (selected.size >= limit) break; selected.add(place); }
  return ranked.filter(place => selected.has(place));
}
