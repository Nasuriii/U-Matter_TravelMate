/** Static-page search fields use the same icon and spacing as the React catalog. */
export function searchControl(inputMarkup: string) {
  return `<span class="tm-search-control"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true" focusable="false"><circle cx="11" cy="11" r="8"></circle><path d="m21 21-4.35-4.35"></path></svg>${inputMarkup}</span>`;
}
