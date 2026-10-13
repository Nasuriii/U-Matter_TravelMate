export const paceGuides={
 relaxed:{name:'Easygoing',summary:'More breathing room between stops.',maxAttractions:1,visitMinutes:120,fit:'Best for slower mornings and longer visits.'},
 balanced:{name:'Balanced',summary:'A little exploring, a little downtime.',maxAttractions:2,visitMinutes:90,fit:'Best for a varied day with time to unwind.'},
 active:{name:'Packed with plans',summary:'Fit more exploring into your day.',maxAttractions:3,visitMinutes:90,fit:'Best for travelers comfortable with a fuller schedule.'}
} as const;
export const paceLimitations='These are maximum suggestions, not guaranteed stops. Your arrival/departure times and the available attraction catalog may reduce them. Plans cover 1–14 days. The planner allows an hour after arrival, 30 minutes after visits and 2 hours before departure; these are planning allowances, not calculated routes. Changing pace takes effect when you generate a new plan.';
export type Pace=keyof typeof paceGuides;
