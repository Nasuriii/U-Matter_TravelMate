import type { ComponentProps } from 'react';
import { cn } from '../../lib/utils';

export function FieldGroup({ className, ...props }: ComponentProps<'div'>) {
  return <div data-slot="field-group" className={cn('flex flex-col gap-5', className)} {...props} />;
}
export function Field({ className, ...props }: ComponentProps<'div'>) {
  return <div data-slot="field" className={cn('flex min-w-0 flex-col gap-2', className)} {...props} />;
}
export function FieldLabel({ className, ...props }: ComponentProps<'label'>) {
  return <label data-slot="field-label" className={cn('text-sm font-semibold text-foreground', className)} {...props} />;
}
export function FieldDescription({ className, ...props }: ComponentProps<'p'>) {
  return <p data-slot="field-description" className={cn('text-sm leading-relaxed text-muted-foreground', className)} {...props} />;
}
export function FieldError({ className, ...props }: ComponentProps<'p'>) {
  return <p data-slot="field-error" className={cn('text-sm text-destructive', className)} {...props} />;
}
