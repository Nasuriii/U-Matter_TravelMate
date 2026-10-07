import * as TabsPrimitive from '@radix-ui/react-tabs';
import type { ComponentProps } from 'react';
import { cn } from '../../lib/utils';
export const Tabs = TabsPrimitive.Root;
export function TabsList({ className, ...props }: ComponentProps<typeof TabsPrimitive.List>) { return <TabsPrimitive.List className={cn('inline-flex flex-wrap gap-1 rounded-xl bg-muted p-1', className)} {...props} />; }
export function TabsTrigger({ className, ...props }: ComponentProps<typeof TabsPrimitive.Trigger>) { return <TabsPrimitive.Trigger className={cn('inline-flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-muted-foreground transition-colors data-[state=active]:bg-card data-[state=active]:text-foreground data-[state=active]:shadow-sm focus-visible:ring-2 focus-visible:ring-ring', className)} {...props} />; }
export function TabsContent({ className, ...props }: ComponentProps<typeof TabsPrimitive.Content>) { return <TabsPrimitive.Content className={cn('mt-6 outline-none focus-visible:ring-2 focus-visible:ring-ring', className)} {...props} />; }
