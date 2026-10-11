import type { SupabaseClient } from '@supabase/supabase-js';
import { tidy } from './ui';
type Row = Record<string, any>;
function h(tag: string, cls = '', text = '') { const e = document.createElement(tag); if (cls) e.className = cls; if (text) e.textContent = text; return e; }

/** Shows the signed-in user's own notifications (database/09_hotel_listing.sql: my_notifications). */
export async function loadNotifications(client: SupabaseClient, box: HTMLElement) {
  box.replaceChildren(h('h3', '', 'Notifications'));
  const x = await client.schema('public').rpc('my_notifications', { p_limit: 10 });
  if (x.error) { box.append(h('p', 'muted', 'Notifications are not available yet. Run database/09_hotel_listing.sql in the Supabase SQL Editor.')); return; }
  const rows = (x.data ?? []) as Row[];
  if (!rows.length) { box.append(h('p', 'muted', 'No notifications yet.')); return; }
  const ul = h('ul', 'o-notes');
  for (const n of rows) {
    const li = h('li', n.read ? '' : 'unread'), when = new Date(n.created_at);
    li.append(h('span', '', tidy(String(n.message))), h('small', 'muted', Number.isNaN(when.getTime()) ? '' : when.toLocaleString()));
    ul.append(li);
  }
  box.append(ul);
  if (rows.some(n => !n.read)) {
    const b = h('button', 'quiet', 'Mark all as read') as HTMLButtonElement; b.type = 'button';
    b.addEventListener('click', async () => { b.disabled = true; await client.schema('public').rpc('mark_my_notifications_read'); await loadNotifications(client, box); });
    box.append(b);
  }
}
