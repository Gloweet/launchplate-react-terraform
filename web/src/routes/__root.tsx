import type { JSX } from 'react';

import { createRootRoute, Outlet } from '@tanstack/react-router';
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools';

import { DefaultCatchBoundary } from '@/core/components/default-catch-bounrdary';
import Footer from '@/core/components/footer/footer';
import Navbar from '@/core/components/navbar/navbar';
import { NotFound } from '@/core/components/not-found';
import { TSRBreadCrumbs } from '@/core/components/tsr-breadcrumb/tsr-breadcrumbs';

export const Route = createRootRoute({
  component: RootComponent,
  errorComponent: (props) => {
    return (
      <RootDocument>
        <DefaultCatchBoundary {...props} />
      </RootDocument>
    );
  },
  notFoundComponent: () => <NotFound />
});

function RootDocument({ children }: { children: JSX.Element }) {
  return (
    <>
      <Navbar />

      {/* This is where the child routes will be rendered */}
      <div id='content' className='page-content p-2'>
        <TSRBreadCrumbs />
        {children}
        <TanStackRouterDevtools initialIsOpen={false} />
      </div>

      <Footer />
    </>
  );
}

function RootComponent() {
  return (
    <RootDocument>
      <Outlet />
    </RootDocument>
  );
}
