/** Keep provenance in storage, with clean names in the presentation layer. */
export const catalogLabel = (name: string) => name.replace(/\s*\(Demo\)\s*$/i, '').trim();
export const isPreview = (name: string) => /\(Demo\)\s*$/i.test(name);
export function cleanTransport<T extends {name:string;provider:string}>(item:T):T { return {...item,name:catalogLabel(item.name),provider:catalogLabel(item.provider)}; }
