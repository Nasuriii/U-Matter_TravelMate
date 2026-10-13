import {Bike,Bus,CarFront,CarTaxiFront} from 'lucide-react';
import {vehicleMode} from '../transport-options';
export function VehicleIcon({type,size=22}:{type:string;size?:number}){
 const mode=vehicleMode(type),Icon=mode==='tricycle'?Bike:mode==='taxi'?CarTaxiFront:mode==='car'||mode==='van'?CarFront:Bus;
 return <Icon size={size} aria-hidden="true"/>;
}
