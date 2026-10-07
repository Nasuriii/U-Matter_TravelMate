// Suggestions use catalog evidence, never inferred popularity or availability.
export const interestLabels: Record<string, string> = {
  beaches: 'Beaches', mountains: 'Mountains', nature: 'Nature', food: 'Food & local culture',
  history: 'History & heritage', adventure: 'Adventure', relaxation: 'Relaxation', shopping: 'Shopping',
};
const keywords: Record<string, RegExp> = {
  beaches: /\b(beach(?:es)?|coast(?:al)?|shore(?:line)?|surf(?:ing)?|seaside)\b/i,
  mountains: /\b(mountains?|summit|highlands?|ridge|peak)\b/i,
  nature: /\b(nature|gardens?|parks?|trails?|mountains?|falls|waterfalls?|scenery|forests?)\b/i,
  food: /\b(food|cuisine|culinary|dining|restaurants?|cafes?|flavors?|flavours?)\b/i,
  history: /\b(history|historic|historical|heritage|museums?|church(?:es)?|landmarks?)\b/i,
  adventure: /\b(adventure|hiking|hike|trails?|surf(?:ing)?|zipline|trek(?:king)?)\b/i,
  relaxation: /\b(quiet|relax(?:ing|ation)?|gardens?|spa|peaceful|leisure|unwind|restful)\b/i,
  shopping: /\b(shopping|shops?|markets?|malls?|crafts?)\b/i,
};
type Place = { id: string; name: string; description: string | null };
type Destination = Place & { province: string };
type Listing = Place & { destination_id: string; listing_type: string; status?: string };
export function recommendPlaces<D extends Destination, L extends Listing>(destinations: D[], listings: L[], interests: string[]) {
  const chosen = [...new Set(interests)].filter(x => interestLabels[x]);
  const active = new Set(destinations.map(d => d.id));
  const approved = listings.filter(l => l.status === 'approved' && active.has(l.destination_id));
  const matches = (place: Place, restaurant = false) => chosen.filter(i =>
    (i === 'food' && restaurant) || keywords[i].test(`${place.name} ${place.description ?? ''}`));
  const sort = <T extends Place>(a: {place: T; interests: string[]}, b: {place: T; interests: string[]}) =>
    b.interests.length - a.interests.length || a.place.name.localeCompare(b.place.name) || a.place.id.localeCompare(b.place.id);
  const places = approved.map(place => ({place, interests: matches(place, place.listing_type === 'restaurant')})).filter(x => x.interests.length).sort(sort);
  const towns = destinations.map(place => {
    const own = matches(place);
    const listingMatches = places.filter(l => l.place.destination_id === place.id).flatMap(l => l.interests);
    return {place, interests: chosen.filter(i => own.includes(i) || listingMatches.includes(i)), source: own.length ? 'destination' : 'listings'};
  }).filter(x => x.interests.length).sort(sort);
  return {destinations: towns, listings: places, interests: chosen};
}
