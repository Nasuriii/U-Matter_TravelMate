import {DataSet,RegExpMatcher,englishDataset,englishRecommendedTransformers} from 'obscenity';
// Keep the automatic rule focused on strong curses; critical or negative reviews are welcome.
const strong=/fuck|shit|bitch|cunt|asshole|motherf|bastard|dickhead|nigger|faggot/i;
const dataset=new DataSet<{originalWord:string}>().addAll(englishDataset).removePhrasesIf(p=>!strong.test(p.metadata?.originalWord??''));
const matcher=new RegExpMatcher({...dataset.build(),...englishRecommendedTransformers});
const words=['fuck','fucker','fuckers','fucking','fucked','motherfucker','shit','shits','shitty','bullshit','bitch','bitches','cunt','cunts','asshole','assholes','bastard','bastards','dickhead','nigger','faggot','putangina','putanginamo','putahangina','tangina','tanginamo','puta','gago','ulol','pakyu','hindut','ukinnam'];
const disguisedCurses=new RegExp('(?:^|[^a-z])('+words.map(word=>Array.from(word,c=>c+'+').join('[^a-z]*')).join('|')+')(?:$|[^a-z])','i');
const localCurses=/(?:^|[^a-z])(?:p+u+t+a+n+g+[\s-]*i+n+a+[a-z]*|p+u+t+a+h+a+n+g+[\s-]*i+n+a+[a-z]*|p+u+t+a+|t+a+n+g+[\s-]*i+n+a+[a-z]*|g+a+g+o+|u+l+o+l+|p+a+k+y+u+|h+i+n+d+u+t+|u+k+i+n+n+a+m+)(?:$|[^a-z])/i;
export function hasInappropriateWords(text:string){const normalized=text.normalize('NFKD').replace(/[\u0300-\u036f\u200b-\u200d\ufeff]/g,'').toLowerCase().replace(/[013457@$!]/g,c=>({'0':'o','1':'i','3':'e','4':'a','5':'s','7':'t','@':'a','$':'s','!':'i'}[c]!));const matched=matcher.getAllMatches(text).some(m=>!/[\p{L}\p{N}]/u.test(text[m.startIndex-1]??'')&&!/[\p{L}\p{N}]/u.test(text[m.endIndex+1]??''));return matched||localCurses.test(normalized)||disguisedCurses.test(normalized);}
export const reviewDeclinedMessage='Sorry, your review was declined because it contains inappropriate words. Please remove the curse words and try again. Your text has been kept so you can edit it.';
