import { Dripsy } from './dripsy'
import { NavigationProvider } from './navigation'
import { QueryClient, QueryClientProvider } from 'react-query'

const queryClient = new QueryClient()

export function Provider({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      <NavigationProvider>
        <Dripsy>{children}</Dripsy>
      </NavigationProvider>
    </QueryClientProvider>
  )
}
