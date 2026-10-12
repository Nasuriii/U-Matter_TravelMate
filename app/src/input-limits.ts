/** UX limits only. Database validation and ownership checks remain authoritative. */
export function installInputLimits() {
  const isSearch = (field: HTMLInputElement | HTMLTextAreaElement) => field instanceof HTMLInputElement && (field.type === 'search' || field.type === 'text' && /search/i.test(field.id + field.name + field.placeholder));
  const apply = (root: ParentNode) => root.querySelectorAll<HTMLInputElement | HTMLTextAreaElement>('input,textarea').forEach(field => {
    if (isSearch(field)) {
      if (field.maxLength < 0 || field.maxLength > 120) field.maxLength = 120;
      return;
    }
    if (field.hasAttribute('maxlength')) return;
    if (field instanceof HTMLTextAreaElement) field.maxLength = 2000;
    else if (field.type === 'email') field.maxLength = 150;
    else if (field.type === 'tel') field.maxLength = 30;
    else if (field.type === 'url') field.maxLength = 500;
    else if (field.type === 'text') field.maxLength = /address|description/i.test(field.name + field.id) ? 500 : 150;
  });
  apply(document);
  // Paste, autofill, and scripted entry can bypass the native maxlength attribute.
  // Capture before search handlers/React read the value; setRangeText preserves
  // React's change tracking, so the bounded value reaches controlled input state.
  document.addEventListener('input', event => {
    const field = event.target;
    if (!(field instanceof HTMLInputElement) || !isSearch(field)) return;
    const limit = field.maxLength < 0 ? 120 : Math.min(field.maxLength, 120);
    if (field.value.length > limit) field.setRangeText('', limit, field.value.length, 'end');
  }, true);
  new MutationObserver(records => {
    if (records.some(record => record.addedNodes.length || record.type === 'attributes')) apply(document);
  }).observe(document.body, {childList:true, subtree:true, attributes:true, attributeFilter:['maxlength','type']});
}
