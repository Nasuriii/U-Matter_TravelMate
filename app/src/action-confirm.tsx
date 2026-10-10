import { createRoot } from 'react-dom/client';
import { ArrowLeft, Check, Eye, Pencil, Save, Trash2 } from 'lucide-react';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogTitle } from './components/ui/alert-dialog';
// One shared shadcn/Radix confirmation for both React and existing database workflows.
let queue = Promise.resolve();
export type ConfirmationDetail = { label: string; value: string };
export function confirmAction(title: string, message: string, label: string, cancelLabel = 'Keep editing', details?: ConfirmationDetail[]): Promise<boolean> {
  const destructive = /^(delete|remove|discard|reject|revoke)\b/i.test(label);
  const ActionIcon = destructive ? Trash2 : /preview|view|show/i.test(label) ? Eye : /save/i.test(label) ? Save : Check;
  const CancelIcon = /edit/i.test(cancelLabel) ? Pencil : ArrowLeft;
  let resolveResult!: (value: boolean) => void;
  const result = new Promise<boolean>(resolve => { resolveResult = resolve; });
  queue = queue.then(() => new Promise<void>(next => {
    const previous = document.activeElement as HTMLElement | null;
    const mount = document.createElement('div'); document.body.append(mount);
    const root = createRoot(mount); let done = false;
    const finish = (accepted: boolean) => {
      if (done) return; done = true; window.removeEventListener('hashchange', abort); window.removeEventListener('travelmate:identity', abort);
      root.render(null); setTimeout(() => { root.unmount(); mount.remove(); if (previous?.isConnected) previous.focus(); resolveResult(accepted); next(); }, 0);
    };
    const abort = () => finish(false);
    window.addEventListener('hashchange', abort); window.addEventListener('travelmate:identity', abort);
    root.render(<AlertDialog open onOpenChange={open => { if (!open) abort(); }}><AlertDialogContent>
      <div className="tm-confirm-symbol mb-4 inline-flex size-11 items-center justify-center rounded-xl bg-muted" aria-hidden="true"><ActionIcon size={22}/></div>
      <AlertDialogTitle className="text-xl font-semibold">{title}</AlertDialogTitle>
      {details?.length ? <dl className="tm-confirm-details">{details.map(detail=><div key={detail.label}><dt>{detail.label}</dt><dd>{detail.value}</dd></div>)}</dl> : null}
      <AlertDialogDescription className="mt-3 whitespace-pre-line text-sm leading-6 text-muted-foreground">{message}</AlertDialogDescription>
      <div className="tm-confirm-buttons mt-6 flex flex-wrap justify-end gap-3"><AlertDialogCancel onClick={abort}><CancelIcon aria-hidden="true"/>{cancelLabel}</AlertDialogCancel><AlertDialogAction className={destructive ? 'tm-confirm-destructive' : undefined} onClick={() => finish(true)}><ActionIcon aria-hidden="true"/>{label}</AlertDialogAction></div>
    </AlertDialogContent></AlertDialog>);
  }));
  return result;
}
