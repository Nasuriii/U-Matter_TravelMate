export const LISTINGS_PER_PAGE = 6;

/** Clamp the current page after filtering, refreshes, or removing the last item. */
export function listingPage<T>(rows: readonly T[], requestedPage: number, size = LISTINGS_PER_PAGE) {
  const pageSize = Number.isFinite(size) ? Math.max(1, Math.floor(size)) : LISTINGS_PER_PAGE;
  const total = rows.length, pages = Math.max(1, Math.ceil(total / pageSize));
  const page = Math.min(pages, Math.max(1, Number.isFinite(requestedPage) ? Math.floor(requestedPage) : 1));
  const offset = (page - 1) * pageSize;
  return { items: rows.slice(offset, offset + pageSize), total, pages, page, start: total ? offset + 1 : 0, end: Math.min(offset + pageSize, total) };
}

export function listingRange(result: ReturnType<typeof listingPage>) {
  return result.total ? `${result.start}–${result.end} of ${result.total} listings` : 'No matching listings';
}
