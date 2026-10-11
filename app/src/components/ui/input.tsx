import type { ComponentProps } from 'react';
import { cn } from '../../lib/utils';

export function Input({ className, type, ...props }: ComponentProps<'input'>) {
  return <input type={type} data-slot="input" className={cn('flex h-12 w-full min-w-0 rounded-xl border border-border bg-card px-4 py-3 text-base text-foreground transition-colors placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20', className)} {...props} />;
}
