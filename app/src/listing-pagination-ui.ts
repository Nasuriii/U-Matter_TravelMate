import type { listingPage } from './listing-pagination';

/** Shared accessible controls for the existing owner and admin DOM screens. */
export function renderListingPagination(host: HTMLElement, result: ReturnType<typeof listingPage>, label: string, change: (page: number) => void) {
  host.replaceChildren(); host.className = 'tm-listing-pagination'; host.hidden = result.pages === 1;
  host.setAttribute('aria-label', label);
  const count = document.createElement('p'); count.textContent = `${result.total} listings`;
  host.append(count);
  if (result.pages === 1) return;
  const controls = document.createElement('div'); controls.className = 'tm-page-controls';
  const previous = document.createElement('button'), next = document.createElement('button'), current = document.createElement('span');
  previous.type = next.type = 'button'; previous.className = next.className = 'quiet';
  previous.textContent = '← Previous'; next.textContent = 'Next →';
  previous.setAttribute('aria-label', 'Previous page of ' + label); next.setAttribute('aria-label', 'Next page of ' + label);
  previous.disabled = result.page === 1; next.disabled = result.page === result.pages;
  previous.dataset.direction = 'previous'; next.dataset.direction = 'next';
  current.textContent = `Page ${result.page} of ${result.pages}`;
  const go = (page: number, direction: string) => {
    change(page);
    const target = host.querySelector<HTMLButtonElement>(`button[data-direction=${direction}]:not(:disabled)`)
      ?? host.querySelector<HTMLButtonElement>('button:not(:disabled)');
    target?.focus({ preventScroll: true });
  };
  previous.addEventListener('click', () => go(result.page - 1, 'previous'));
  next.addEventListener('click', () => go(result.page + 1, 'next'));
  controls.append(previous, current, next); host.append(controls);
}
