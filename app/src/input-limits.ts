/** UX limits only. Database validation and ownership checks remain authoritative. */
export function installInputLimits() {
  const apply = (root: ParentNode) => root.querySelectorAll<HTMLInputElement | HTMLTextAreaElement>('input:not([maxlength]),textarea:not([maxlength])').forEach(field => {
    if (field instanceof HTMLTextAreaElement) field.maxLength = 2000;
    else if (field.type === 'search' || field.type === 'text' && /search/i.test(field.id + field.name + field.placeholder)) field.maxLength = 120;
    else if (field.type === 'email') field.maxLength = 150;
    else if (field.type === 'tel') field.maxLength = 30;
    else if (field.type === 'url') field.maxLength = 500;
    else if (field.type === 'text') field.maxLength = /address|description/i.test(field.name + field.id) ? 500 : 150;
  });
  apply(document);
  new MutationObserver(records => {
    if (records.some(record => record.addedNodes.length)) apply(document);
  }).observe(document.body, {childList:true, subtree:true});
}
