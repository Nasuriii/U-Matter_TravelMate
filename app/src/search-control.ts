/** Static-page search fields use the same icon and spacing as the React catalog. */
export function searchControl(inputMarkup: string) {
  // Static catalogs must be bounded before the runtime input setup runs.
  const boundedInput = /\bmaxlength\s*=/i.test(inputMarkup) ? inputMarkup : inputMarkup.replace(/<input\b/i, '<input maxlength="120"');
  return `<span class="tm-search-control"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true" focusable="false"><circle cx="11" cy="11" r="8"></circle><path d="m21 21-4.35-4.35"></path></svg>${boundedInput}</span>`;
}
