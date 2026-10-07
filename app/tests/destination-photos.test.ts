import {strict as assert} from 'node:assert';
import {destinationPhoto} from '../src/experience/destination-photos.ts';
const names=['Agoo','Aringay','Bacnotan','Baguio','Bagulin','Balaoan','Bangar','Bauang','Burgos','Caba','Luna','Naguilian','Pugo','Rosario','San Fernando City','San Juan'];
for (const name of names) {
  const photo=destinationPhoto(name,name==='Baguio'?'Benguet (geographic location)':'La Union');
  assert.ok(photo?.src && photo.author && photo.source && photo.license,`Missing picture or credit: ${name}`);
}
assert.equal(destinationPhoto('San Juan','Metro Manila'),undefined);
assert.equal(destinationPhoto('Burgos','Ilocos Norte'),undefined);
assert.equal(destinationPhoto('San Fernando','La Union')?.src,destinationPhoto('San Fernando City','La Union')?.src);
console.log('16 destination photo credits and 3 location checks passed.');
