import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/customers/customers_screen.dart';
import '../../screens/customers/customer_detail_screen.dart';
import '../../screens/customers/customer_form_screen.dart';
import '../../screens/loans/loans_screen.dart';
import '../../screens/loans/loan_form_screen.dart';
import '../../screens/loans/loan_types_screen.dart';
import '../../screens/savings/savings_screen.dart';
import '../../screens/savings/savings_form_screen.dart';
import '../../screens/savings/savings_schemes_screen.dart';
import '../../screens/jewelry/jewelry_screen.dart';
import '../../screens/jewelry/jewelry_form_screen.dart';

class AppRouter {
  static GoRouter router(BuildContext context) => GoRouter(
        initialLocation: '/login',
        redirect: (ctx, state) {
          final auth = ctx.read<AuthProvider>();
          final isLogin = state.matchedLocation == '/login';
          if (!auth.isLoggedIn && !isLogin) return '/login';
          if (auth.isLoggedIn && isLogin) return '/dashboard';
          return null;
        },
        routes: [
          GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
          GoRoute(
              path: '/dashboard', builder: (_, __) => const DashboardScreen()),

          // Customers
          GoRoute(
              path: '/customers', builder: (_, __) => const CustomersScreen()),
          GoRoute(
              path: '/customers/new',
              builder: (_, __) => const CustomerFormScreen()),
          GoRoute(
              path: '/customers/:id',
              builder: (_, s) =>
                  CustomerDetailScreen(id: s.pathParameters['id']!)),
          GoRoute(
              path: '/customers/:id/edit',
              builder: (_, s) =>
                  CustomerFormScreen(customerId: s.pathParameters['id'])),

          // Loans
          GoRoute(path: '/loans', builder: (_, __) => const LoansScreen()),
          GoRoute(
              path: '/loans/new', builder: (_, __) => const LoanFormScreen()),
          GoRoute(
              path: '/loans/types',
              builder: (_, __) => const LoanTypesScreen()),

          // Savings
          GoRoute(path: '/savings', builder: (_, __) => const SavingsScreen()),
          GoRoute(
              path: '/savings/new',
              builder: (_, __) => const SavingsFormScreen()),
          GoRoute(
              path: '/savings/schemes',
              builder: (_, __) => const SavingsSchemesScreen()),

          // Jewelry
          GoRoute(path: '/jewelry', builder: (_, __) => const JewelryScreen()),
          GoRoute(
              path: '/jewelry/new',
              builder: (_, __) => const JewelryFormScreen()),
        ],
      );
}
