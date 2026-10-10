import assert from 'node:assert/strict';
import {hasInappropriateWords} from '../src/review-moderation.ts';
for(const text of ['The service was fucking terrible.','This is sh1t service.','You are a b!tch.','This is f.u.c.k service.','PUTANG INA rude service.','This gago was rude.','This is g@g0 service.','Putanginamo rude service.','Tanginamo rude service.'])assert.equal(hasInappropriateWords(text),true,text);
for(const text of ['The room was dirty and the service was terrible.','I would not recommend this hotel.','The food was cold. Staff should improve.','We enjoyed the classic mushrooms and shiitake soup.','Our trip to Scunthorpe was lovely.','Please make the place accessible.'])assert.equal(hasInappropriateWords(text),false,text);
console.log('Strong English/Filipino curses and obfuscation blocked; negative reviews and ordinary words allowed.');
