import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});
  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<SavingsProvider>().loadAll());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Savings',
      currentRoute: '/savings',
      actions: [
        IconButton(
          icon: const Icon(Icons.schema_outlined),
          tooltip: 'Schemes',
          onPressed: () => context.go('/savings/schemes'),
        ),
      ],
      fab: FloatingActionButton.extended(
        onPressed: () => context.go('/savings/new'),
        icon: const Icon(Icons.add),
        label: const Text('Enroll'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SavingsProvider>(
        builder: (_, prov, __) {
          if (prov.state == LoadState.loading) return const LoadingWidget();
          final list = prov.savings;

          if (list.isEmpty)
            return EmptyState(
              message: 'No savings records',
              icon: Icons.savings_outlined,
              actionLabel: 'Enroll Customer',
              onAction: () => context.go('/savings/new'),
            );

          return RefreshIndicator(
            onRefresh: prov.loadAll,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                  AppTheme.md, AppTheme.md, AppTheme.md, 80),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppTheme.sm),
              itemBuilder: (_, i) => _SavingsCard(savings: list[i]),
            ),
          );
        },
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final CustomerSavings savings;
  const _SavingsCard({required this.savings});

  @override
  Widget build(BuildContext context) {
    final scheme = savings.scheme;
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 1))
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
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.savings_rounded,
                    color: AppTheme.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      savings.customer?.name ?? 'Customer',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      scheme?.name ?? 'Custom Savings',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusBadge(savings.status),
            ],
          ),
          const Divider(height: 20),
          if (scheme != null) ...[
            Row(
              children: [
                Expanded(
                    child:
                        _InfoItem('Frequency', scheme.frequency.toUpperCase())),
                Expanded(
                    child: _InfoItem(
                        'Amount', fmtCurrency(scheme.amountPerPeriod))),
                Expanded(
                    child:
                        _InfoItem('Duration', '${scheme.durationMonths} mo')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child:
                        _InfoItem('Interest', '${scheme.interestRate}% p.a.')),
                Expanded(
                    child: _InfoItem('Started', fmtDate(savings.startDate))),
                if (savings.endDate != null)
                  Expanded(child: _InfoItem('Ends', fmtDate(savings.endDate!))),
              ],
            ),
          ],
          if (scheme == null) ...[
            _InfoItem('Started', fmtDate(savings.startDate)),
          ],
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label, value;
  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }
}
