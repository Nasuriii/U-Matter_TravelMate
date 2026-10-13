import {cleanTransport} from './catalog-label';
export type Transport={id:string;name:string;type:string;provider:string;description:string|null};
export type VehicleMode='bus'|'jeepney'|'tricycle'|'taxi'|'car'|'van';
export const vehicleModes:{key:VehicleMode;name:string;copy:string}[]=[
 {key:'bus',name:'Bus ride',copy:'A shared ride for longer transfers. Check the terminal, route and timetable.'},
 {key:'jeepney',name:'Jeepney ride',copy:'A shared local ride. Confirm the route, boarding point and fare.'},
 {key:'tricycle',name:'Tricycle ride',copy:'A short local transfer. Agree on the fare and destination before boarding.'},
 {key:'taxi',name:'Taxi ride',copy:'A point-to-point transfer. Check local availability, pickup and fare.'},
 {key:'car',name:'Private car',copy:'Plan your own drive. Allow for traffic, parking and rest stops.'},
 {key:'van',name:'Van / shuttle',copy:'Plan a group transfer. Confirm capacity, pickup and the operator’s schedule.'}
];
export function vehicleMode(type:string):VehicleMode{
 const value=type.toLowerCase();
 return /jeep/.test(value)?'jeepney':/tricycle|tuk/.test(value)?'tricycle':/taxi|cab/.test(value)?'taxi':/van|shuttle/.test(value)?'van':/car|private|drive/.test(value)?'car':'bus';
}
/** Personal modes remain separate from the destination's listed operators. */
export function planningTransportOptions(rows:Transport[]):Transport[]{
 return [...rows.map(cleanTransport),...vehicleModes.map(mode=>({id:'plan:'+mode.key,name:mode.name,type:mode.name,provider:'Personal transport plan',description:mode.copy}))];
}
export function transportPreviewData(transport:Transport){
 const mode=vehicleMode(transport.type),guide=vehicleModes.find(item=>item.key===mode)!;
 return {'data-place-preview':'transport','data-place-id':transport.id,'data-place-name':transport.name,'data-place-area':transport.provider,'data-place-image':'/illustrations/vehicles/'+mode+'.svg','data-place-description':transport.description||guide.copy,'data-place-note':transport.id.startsWith('plan:')?'A planning choice · arrange the ride yourself.':'Confirm pickup, route and fare with the provider.'};
}
