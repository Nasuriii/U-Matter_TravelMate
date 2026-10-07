import { createRoot } from 'react-dom/client';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogTitle } from './components/ui/alert-dialog';
// One shared shadcn/Radix confirmation for both React and existing database workflows.
let queue = Promise.resolve();
export function confirmAction(title: string, message: string, label: string): Promise<boolean> {
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
      <div className="mb-4 inline-flex size-11 items-center justify-center rounded-xl bg-muted text-xl" aria-hidden="true">↗</div>
      <AlertDialogTitle className="text-xl font-semibold">{title}</AlertDialogTitle>
      <AlertDialogDescription className="mt-3 whitespace-pre-line text-sm leading-6 text-muted-foreground">{message}</AlertDialogDescription>
      <div className="mt-6 flex flex-wrap justify-end gap-3"><AlertDialogCancel onClick={abort}>Keep editing</AlertDialogCancel><AlertDialogAction onClick={() => finish(true)}>{label}</AlertDialogAction></div>
    </AlertDialogContent></AlertDialog>);
  }));
  return result;
}
