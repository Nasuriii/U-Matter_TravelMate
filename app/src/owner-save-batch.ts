export type OwnerSaveJob = {
  prepare: () => () => Promise<void>;
  saved: () => void;
  afterSave?: () => Promise<void>;
};

/** Validate every section before writing, and only reload editors after all writes succeed. */
export async function saveOwnerChanges(jobs:OwnerSaveJob[],confirm:()=>Promise<boolean>,stillOwner:()=>boolean){
  const saves=jobs.map(job=>job.prepare());
  if(!await confirm())return false;
  for(let index=0;index<jobs.length;index++){
    if(!stillOwner())throw new Error('Your account changed. Reopen your listing.');
    await saves[index]();jobs[index].saved();
  }
  if(!stillOwner())throw new Error('Your account changed. Reopen your listing.');
  for(const afterSave of new Set(jobs.map(job=>job.afterSave).filter(Boolean)))await afterSave!();
  return true;
}
