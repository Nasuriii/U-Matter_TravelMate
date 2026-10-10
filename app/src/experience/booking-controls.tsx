import { BedDouble, Check, Minus, Plus, Users } from 'lucide-react';
import type { Room } from './catalog';
import { money } from './state';

export function RoomChoices({rooms,value,change}:{rooms:Room[];value:string;change:(id:string)=>void}){
 return <fieldset className="tm-room-choices"><legend><BedDouble size={21}/>Choose your room</legend><div>{rooms.map(room=><label className="tm-room-choice" key={room.id} data-selected={value===room.id} data-unavailable={room.operational_status!=='available'}><input type="radio" name="room" required value={room.id} checked={value===room.id} disabled={room.operational_status!=='available'} onChange={()=>change(room.id)}/><span><strong>{room.room_type}</strong><small>Room {room.room_number} · up to {room.max_guests} guests</small><b>{money(room.base_nightly_rate)} <small>/ night</small></b>{room.operational_status!=='available'&&<small>Unavailable</small>}</span>{value===room.id&&<Check size={20} aria-hidden="true"/>}</label>)}</div>{!rooms.length&&<p>No rooms available yet.</p>}</fieldset>;
}
export function GuestCount({value,max,change}:{value:string;max:number;change:(value:string)=>void}){
 const count=Number(value);
 return <div className="tm-guest-control"><label htmlFor="tm-guests"><Users size={21}/>Number of guests</label><div><button type="button" aria-label="Remove one guest" disabled={count<=1} onClick={()=>change(String(Math.max(1,count-1)))}><Minus size={20}/></button><input id="tm-guests" type="number" required min="1" max={max} value={value} onChange={e=>change(e.target.value)}/><button type="button" aria-label="Add one guest" disabled={count>=max} onClick={()=>change(String(Math.min(max,count+1)))}><Plus size={20}/></button></div><small>Up to {max} guests{count>max?' · choose a larger room or fewer guests':''}</small></div>;
}
