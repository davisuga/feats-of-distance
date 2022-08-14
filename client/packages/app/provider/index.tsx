import { Dripsy } from './dripsy'
import { NavigationProvider } from './navigation'
import { QueryClient, QueryClientProvider } from 'react-query'
import { NativeBaseProvider } from 'native-base'

const queryClient = new QueryClient()

export function Provider({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      <NavigationProvider>
        <NativeBaseProvider>
          <Dripsy>{children}</Dripsy>
        </NativeBaseProvider>
      </NavigationProvider>
    </QueryClientProvider>
  )
}
