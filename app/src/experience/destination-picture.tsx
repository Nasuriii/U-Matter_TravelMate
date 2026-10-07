import { useState } from 'react';
import { MapPin } from 'lucide-react';
import type { DestinationPhoto } from './destination-photos';
export function DestinationCover({photo}: {photo?: DestinationPhoto}) {
  const [failed, setFailed] = useState(false);
  return <div className="tm-recommendation-cover">{photo && !failed ? <img src={photo.src} alt={photo.alt} loading="lazy" onError={() => setFailed(true)}/> : <MapPin size={42} strokeWidth={1.2}/>}{photo && !failed && <span>{photo.caption}</span>}</div>;
}
export function PhotoCredit({photo, compact = false}: {photo?: DestinationPhoto; compact?: boolean}) {
  if (!photo?.source) return null;
  if (compact) return <details className="tm-photo-credit-details"><summary>Photo credits</summary><PhotoCredit photo={photo}/></details>;
  return <p className="tm-recommendation-credit"><a href={photo.source} target="_blank" rel="noreferrer">{photo.author}</a> · {photo.licenseUrl ? <a href={photo.licenseUrl} target="_blank" rel="noreferrer">{photo.license}</a> : photo.license} · cropped</p>;
}
