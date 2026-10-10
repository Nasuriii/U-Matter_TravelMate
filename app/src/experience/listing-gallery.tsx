import {sampleGallery} from '../sample-photos';
import {PhotoMosaic} from './photo-mosaic';
import type {Listing} from './state';
export function ListingGallery({listing}:{listing:Listing}){const photos=listing.preview?sampleGallery(listing.listing_type,listing.id):listing.gallery?.length?listing.gallery:listing.image?[listing.image]:[];return <PhotoMosaic name={listing.name} stacked={listing.listing_type==='hotel'} photos={photos.map((src,i)=>({src,alt:listing.name+(listing.preview?' · inspiration':'')+' photo '+(i+1)}))}/>;}
