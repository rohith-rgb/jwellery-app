// ── customers_screen.dart ────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<CustomerProvider>().loadAll());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Customers',
      currentRoute: '/customers',
      fab: FloatingActionButton.extended(
        onPressed: () => context.go('/customers/new'),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Customer'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search by name, phone or Aadhaar…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: context.read<CustomerProvider>().search,
            ),
          ),
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (_, prov, __) {
                if (prov.state == LoadState.loading)
                  return const LoadingWidget();
                final list = prov.customers;
                if (list.isEmpty)
                  return EmptyState(
                    message: 'No customers found',
                    icon: Icons.people_outline,
                    actionLabel: 'Add Customer',
                    onAction: () => context.go('/customers/new'),
                  );
                return RefreshIndicator(
                  onRefresh: prov.loadAll,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppTheme.md, 0, AppTheme.md, 80),
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppTheme.sm),
                    itemBuilder: (_, i) => _CustomerTile(customer: list[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/customers/${customer.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.md),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryLight.withOpacity(0.15),
              child: Text(
                customer.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(customer.phone,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  Text('Aadhaar: ${customer.aadhaar}',
                      style: const TextStyle(
                          color: AppTheme.textHint, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }
}
