import { strict as assert } from 'node:assert';
import { buildItinerary } from '../src/itinerary-engine.ts';
const brief={id:'trip',name:'Trip',destination_id:'place',start_date:'2027-01-10',end_date:'2027-01-10',arrival_time:'07:00',departure_time:'19:00',travel_pace:'relaxed',interests:['beaches'],budget:1000,budget_currency:'PHP',updated_at:''};
const venues=[{id:'mountain',name:'A Mountain Trail',listing_type:'attraction',description:'A summit hike',address:null},{id:'beach',name:'Z Coastal Beach',listing_type:'attraction',description:'Quiet seaside exploring',address:null}];
assert.equal(buildItinerary(brief,venues).find(x=>x.listing_id)?.listing_id,'beach');
assert.equal(buildItinerary({...brief,interests:['mountains']},venues).find(x=>x.listing_id)?.listing_id,'mountain');
assert.equal(buildItinerary({...brief,interests:['relaxation']},venues).find(x=>x.listing_id)?.listing_id,'beach');
assert.equal(buildItinerary({...brief,interests:['adventure']},venues).find(x=>x.listing_id)?.listing_id,'mountain');
console.log('4 itinerary preference-ranking assertions passed.');
