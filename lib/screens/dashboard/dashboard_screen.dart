import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<DashboardProvider>().load()
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      currentRoute: '/dashboard',
      body: Consumer<DashboardProvider>(
        builder: (_, dash, __) {
          if (dash.state == LoadState.loading) return const LoadingWidget();
          return RefreshIndicator(
            onRefresh: () => dash.load(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Hero banner ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryDark, AppTheme.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome, Admin 👋',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Finance & Jewelry',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Loan Portfolio',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                fmtCurrency(dash.totalLoanAmount),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Stat cards — 2 columns, fixed height ─────
                  Row(
                    children: [
                      Expanded(child: _StatTile(
                        title: 'Customers',
                        value: '${dash.totalCustomers}',
                        icon: Icons.people_rounded,
                        color: AppTheme.primary,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatTile(
                        title: 'Active Loans',
                        value: '${dash.activeLoans}',
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppTheme.warning,
                      )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _StatTile(
                        title: 'Savings',
                        value: '${dash.activeSavings}',
                        icon: Icons.savings_rounded,
                        color: AppTheme.success,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatTile(
                        title: 'Jewelry',
                        value: '${dash.pledgedJewelry}',
                        icon: Icons.diamond_rounded,
                        color: const Color(0xFFAD1457),
                      )),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Quick actions ────────────────────────────
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Row 1
                  Row(
                    children: [
                      Expanded(child: _QuickAction(
                        icon: Icons.person_add_rounded,
                        label: 'New Customer',
                        color: AppTheme.primary,
                        route: '/customers/new',
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _QuickAction(
                        icon: Icons.add_card_rounded,
                        label: 'New Loan',
                        color: AppTheme.warning,
                        route: '/loans/new',
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _QuickAction(
                        icon: Icons.savings_rounded,
                        label: 'New Savings',
                        color: AppTheme.success,
                        route: '/savings/new',
                      )),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 2
                  Row(
                    children: [
                      Expanded(child: _QuickAction(
                        icon: Icons.diamond_rounded,
                        label: 'Pledge Item',
                        color: const Color(0xFFAD1457),
                        route: '/jewelry/new',
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _QuickAction(
                        icon: Icons.category_rounded,
                        label: 'Loan Types',
                        color: AppTheme.accent,
                        route: '/loans/types',
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _QuickAction(
                        icon: Icons.schema_rounded,
                        label: 'Schemes',
                        color: AppTheme.textSecondary,
                        route: '/savings/schemes',
                      )),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Navigation shortcuts ─────────────────────
                  const Text(
                    'Modules',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _NavTile(
                    icon: Icons.people_rounded,
                    title: 'Customers',
                    subtitle: 'View all customers & history',
                    color: AppTheme.primary,
                    route: '/customers',
                  ),
                  const SizedBox(height: 8),
                  _NavTile(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Loans',
                    subtitle: 'Manage active & closed loans',
                    color: AppTheme.warning,
                    route: '/loans',
                  ),
                  const SizedBox(height: 8),
                  _NavTile(
                    icon: Icons.savings_rounded,
                    title: 'Savings',
                    subtitle: 'Daily, weekly & monthly schemes',
                    color: AppTheme.success,
                    route: '/savings',
                  ),
                  const SizedBox(height: 8),
                  _NavTile(
                    icon: Icons.diamond_rounded,
                    title: 'Jewelry',
                    subtitle: 'Pledged & re-pledged gold items',
                    color: const Color(0xFFAD1457),
                    route: '/jewelry',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Compact stat tile ─────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick action tile ─────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GoRouterHelper(context).go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Module nav tile ───────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GoRouterHelper(context).go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}