import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: 'home',
    loadComponent: () => import('./home/home.page').then((m) => m.HomePage),
  },
  {
    path: '',
    redirectTo: 'home',
    pathMatch: 'full',
  },
  {
    path: 'login',
    loadComponent: () => import('./login/login.page').then((m) => m.LoginPage),
  },
  {
    path: 'dashboard',
    loadComponent: () =>
      import('./dashboard/home/dashboard.page').then((m) => m.DashboardPage),
  },
  {
    path: 'communities',
    loadComponent: () =>
      import('./dashboard/communities/communities.page').then(
        (m) => m.CommunitiesPage
      ),
  },
  {
    path: 'users',
    loadComponent: () =>
      import('./dashboard/users/users.page').then((m) => m.UsersPage),
  },
];
