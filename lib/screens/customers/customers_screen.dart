import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        onPressed: () => GoRouterExt(context).go('/customers/new'),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Customer'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(14),
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
                if (prov.state == LoadState.loading) {
                  return const LoadingWidget();
                }
                final list = prov.customers;
                if (list.isEmpty) {
                  return EmptyState(
                    message: 'No customers found',
                    icon: Icons.people_outline,
                    actionLabel: 'Add Customer',
                    onAction: () => GoRouterExt(context).go('/customers/new'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: prov.loadAll,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
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
    final hasPhoto = customer.photoUrl != null && customer.photoUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () => GoRouterExt(context).go('/customers/${customer.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            // Photo or avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.primaryLight.withOpacity(0.15),
                border: hasPhoto
                    ? Border.all(
                        color: AppTheme.primary.withOpacity(0.3), width: 2)
                    : null,
              ),
              child: hasPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        customer.photoUrl!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _InitialAvatar(name: customer.name),
                      ),
                    )
                  : _InitialAvatar(name: customer.name),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(customer.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      if (hasPhoto) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.successLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('✓ Photo',
                              style: TextStyle(
                                  color: AppTheme.success,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
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

class _InitialAvatar extends StatelessWidget {
  final String name;
  const _InitialAvatar({required this.name});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 20),
        ),
      );
}
