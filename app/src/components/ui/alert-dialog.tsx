import * as Primitive from '@radix-ui/react-alert-dialog';
import type { ComponentProps } from 'react';
import { cn } from '../../lib/utils';
import { buttonVariants } from './button';
export const AlertDialog = Primitive.Root;
export const AlertDialogTitle = Primitive.Title;
export const AlertDialogDescription = Primitive.Description;
export function AlertDialogContent({ className, ...props }: ComponentProps<typeof Primitive.Content>) { return <Primitive.Portal><Primitive.Overlay className="tm-confirm-overlay fixed inset-0 z-[500] bg-black/60 backdrop-blur-sm" /><Primitive.Content className={cn('tm-shadcn-confirm fixed left-1/2 top-1/2 z-[501] w-[calc(100%-2rem)] max-w-lg -translate-x-1/2 -translate-y-1/2 rounded-2xl border border-border bg-card p-6 text-card-foreground shadow-xl', className)} {...props} /></Primitive.Portal>; }
export function AlertDialogCancel({ className, ...props }: ComponentProps<typeof Primitive.Cancel>) { return <Primitive.Cancel data-confirm-button="cancel" className={cn(buttonVariants({ variant: 'outline' }), className)} {...props} />; }
export function AlertDialogAction({ className, ...props }: ComponentProps<typeof Primitive.Action>) { return <Primitive.Action data-confirm-button="action" className={cn(buttonVariants(), className)} {...props} />; }
