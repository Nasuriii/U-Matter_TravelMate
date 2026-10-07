// Hide temporary catalog setup notes while preserving real destination details.
export function destinationDescription(value: string | null): string {
  return (value ?? '')
    .replace(/Sample TravelMate destination entry\.\s*Venue details will use fictional demonstration records\./gi, '')
    .replace(/Reference catalog prepared for a classroom demonstration\./gi, '')
    .trim();
}
