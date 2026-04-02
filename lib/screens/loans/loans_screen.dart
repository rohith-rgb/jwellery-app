// ── loans_screen.dart ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});
  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<LoanProvider>().loadAll());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Loans',
      currentRoute: '/loans',
      fab: FloatingActionButton.extended(
        onPressed: () => context.go('/loans/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Loan'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.category_outlined),
          tooltip: 'Loan Types',
          onPressed: () => context.go('/loans/types'),
        ),
      ],
      body: Consumer<LoanProvider>(
        builder: (_, prov, __) {
          if (prov.state == LoadState.loading) return const LoadingWidget();

          return Column(
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.md, vertical: AppTheme.sm),
                child: Row(
                  children: [
                    _FilterChip(label: 'All', value: null, prov: prov),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Active', value: 'active', prov: prov),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Closed', value: 'closed', prov: prov),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'Defaulted', value: 'defaulted', prov: prov),
                  ],
                ),
              ),
              Expanded(
                child: prov.loans.isEmpty
                    ? EmptyState(
                        message: 'No loans found',
                        icon: Icons.account_balance_wallet_outlined,
                        actionLabel: 'Add Loan',
                        onAction: () => context.go('/loans/new'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            AppTheme.md, 0, AppTheme.md, 80),
                        itemCount: prov.loans.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppTheme.sm),
                        itemBuilder: (_, i) => _LoanCard(loan: prov.loans[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final LoanProvider prov;
  const _FilterChip(
      {required this.label, required this.value, required this.prov});

  @override
  Widget build(BuildContext context) {
    final active = prov.loans.isNotEmpty; // simplified
    return ChoiceChip(
      label: Text(label),
      selected: false,
      onSelected: (_) => prov.setFilter(value),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final Loan loan;
  const _LoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(loan.customer?.name ?? 'Customer',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text(loan.loanType?.name ?? 'Loan',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ]),
              const Spacer(),
              StatusBadge(loan.status),
            ],
          ),
          const Divider(height: 16),
          Row(children: [
            Expanded(child: _Stat('Principal', fmtCurrency(loan.principal))),
            Expanded(child: _Stat('Total', fmtCurrency(loan.totalPayable))),
            Expanded(child: _Stat('EMI', fmtCurrency(loan.emiAmount))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 12, color: AppTheme.textHint),
            const SizedBox(width: 4),
            Text('Started ${fmtDate(loan.startDate)}',
                style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
            const Spacer(),
            Text('${loan.interestRate}% p.a. · ${loan.durationMonths}mo',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ]),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      );
}
