import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

// ── App Scaffold with sidebar nav ────────────────────────────
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? fab;
  final List<Widget>? actions;
  final String currentRoute;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentRoute,
    this.fab,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      drawer: _AppDrawer(currentRoute: currentRoute),
      body: body,
      floatingActionButton: fab,
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final String currentRoute;
  const _AppDrawer({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(height: 6),
                const Text('Finance Manager',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const Text('Admin Panel',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    route: '/dashboard',
                    current: currentRoute),
                _NavItem(
                    icon: Icons.people_rounded,
                    label: 'Customers',
                    route: '/customers',
                    current: currentRoute),
                const Divider(indent: 16, endIndent: 16),
                _NavItem(
                    icon: Icons.account_balance_wallet,
                    label: 'Loans',
                    route: '/loans',
                    current: currentRoute),
                _NavItem(
                    icon: Icons.savings_rounded,
                    label: 'Savings',
                    route: '/savings',
                    current: currentRoute),
                _NavItem(
                    icon: Icons.diamond_rounded,
                    label: 'Jewelry',
                    route: '/jewelry',
                    current: currentRoute),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.error),
            title:
                const Text('Sign Out', style: TextStyle(color: AppTheme.error)),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;

  const _NavItem(
      {required this.icon,
      required this.label,
      required this.route,
      required this.current});

  @override
  Widget build(BuildContext context) {
    final active = current.startsWith(route) && route != '/';
    return ListTile(
      leading: Icon(icon,
          color: active ? AppTheme.primary : AppTheme.textSecondary, size: 22),
      title: Text(label,
          style: TextStyle(
            color: active ? AppTheme.primary : AppTheme.textPrimary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          )),
      tileColor: active ? AppTheme.surfaceVariant : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () {
        Navigator.pop(context);
        if (!active) GoRouterExt(context).go(route);
      },
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatCard(
      {super.key,
      required this.title,
      required this.value,
      required this.icon,
      required this.color,
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(title,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

// ── Status Badge ─────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      'active' => (AppTheme.success, AppTheme.successLight),
      'completed' => (AppTheme.primary, AppTheme.accentLight),
      'closed' => (AppTheme.textSecondary, AppTheme.surfaceVariant),
      'defaulted' => (AppTheme.error, AppTheme.errorLight),
      'withdrawn' => (AppTheme.warning, AppTheme.warningLight),
      'pledged' => (AppTheme.primary, AppTheme.accentLight),
      'repledged' => (AppTheme.warning, AppTheme.warningLight),
      'redeemed' => (AppTheme.success, AppTheme.successLight),
      _ => (AppTheme.textSecondary, AppTheme.surfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}

// ── Info Row ─────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const InfoRow(
      {super.key, required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
          ],
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── Loading Overlay ──────────────────────────────────────────
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
}

// ── Empty State ──────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState(
      {super.key,
      required this.message,
      required this.icon,
      this.actionLabel,
      this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppTheme.surfaceVariant, shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: AppTheme.textHint),
          ),
          const SizedBox(height: 16),
          Text(message,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────
extension GoRouterExt on BuildContext {
  void go(String route) => GoRouter.of(this).go(route);
  void push(String route) => GoRouter.of(this).push(route);
  void pop() => GoRouter.of(this).pop();
}

final _currencyFmt =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final _dateFmt = DateFormat('dd MMM yyyy');

String fmtCurrency(double v) => _currencyFmt.format(v);
String fmtDate(DateTime d) => _dateFmt.format(d);
