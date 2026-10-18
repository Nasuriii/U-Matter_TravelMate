import {test} from 'node:test';
import assert from 'node:assert/strict';
import {saveOwnerChanges,type OwnerSaveJob} from '../src/owner-save-batch.ts';

test('all sections validate before confirmation or any writes',async()=>{
  const events:string[]=[];
  const jobs:OwnerSaveJob[]=[{prepare:()=>{events.push('validate basics');return async()=>{events.push('write basics');};},saved:()=>{}},{prepare:()=>{throw new Error('Missing dish photo');},saved:()=>{}}];
  await assert.rejects(saveOwnerChanges(jobs,async()=>{events.push('confirm');return true;},()=>true),/Missing dish photo/);
  assert.deepEqual(events,['validate basics']);
});

test('one confirmation saves in order and reloads editors only after all writes',async()=>{
  const events:string[]=[];const after=async()=>{events.push('reload');};
  const jobs=['basics','contact','photos'].map(name=>({prepare:()=>async()=>{events.push('write '+name);},saved:()=>{events.push('saved '+name);},afterSave:after}));
  assert.equal(await saveOwnerChanges(jobs,async()=>{events.push('confirm');return true;},()=>true),true);
  assert.deepEqual(events,['confirm','write basics','saved basics','write contact','saved contact','write photos','saved photos','reload']);
});

test('failed writes retain failed and remaining drafts without reloading them',async()=>{
  const completed:string[]=[];let reloads=0;
  const jobs=['basics','photos','menu'].map(name=>({prepare:()=>async()=>{if(name==='photos')throw new Error('Upload failed');},saved:()=>{completed.push(name);},afterSave:async()=>{reloads++;}}));
  await assert.rejects(saveOwnerChanges(jobs,async()=>true,()=>true),/Upload failed/);
  assert.deepEqual(completed,['basics']);assert.equal(reloads,0);
});

test('cancel and identity changes stop saving',async()=>{
  let writes=0;const job={prepare:()=>async()=>{writes++;},saved:()=>{}};
  assert.equal(await saveOwnerChanges([job],async()=>false,()=>true),false);assert.equal(writes,0);
  await assert.rejects(saveOwnerChanges([job],async()=>true,()=>false),/account changed/);assert.equal(writes,0);
});
