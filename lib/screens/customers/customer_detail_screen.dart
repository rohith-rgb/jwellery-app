import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String id;
  const CustomerDetailScreen({super.key, required this.id});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Customer? _customer;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final prov = context.read<CustomerProvider>();
    await prov.loadAll();
    final c = prov.customers.where((c) => c.id == widget.id).firstOrNull;
    if (c != null) {
      prov.select(c);
      setState(() => _customer = c);
    }

    // Load linked data
    context.read<LoanProvider>().loadAll(customerId: widget.id);
    context.read<SavingsProvider>().loadAll(customerId: widget.id);
    context.read<JewelryProvider>().loadAll(customerId: widget.id);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _customer == null
          ? const LoadingWidget()
          : NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 180,
                  backgroundColor: AppTheme.surface,
                  leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/customers')),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          context.go('/customers/${widget.id}/edit'),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Text(
                                  _customer!.name[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_customer!.name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700)),
                                    Text(_customer!.phone,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13)),
                                    Text('Aadhaar: ${_customer!.aadhaar}',
                                        style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabs,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primary,
                    tabs: const [
                      Tab(text: 'Loans'),
                      Tab(text: 'Savings'),
                      Tab(text: 'Jewelry'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabs,
                children: [
                  _LoansTab(customerId: widget.id),
                  _SavingsTab(customerId: widget.id),
                  _JewelryTab(customerId: widget.id),
                ],
              ),
            ),
    );
  }
}

// ── Loans Tab ────────────────────────────────────────────────
class _LoansTab extends StatelessWidget {
  final String customerId;
  const _LoansTab({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanProvider>(
      builder: (_, prov, __) {
        if (prov.state == LoadState.loading) return const LoadingWidget();
        final loans = prov.loans;
        if (loans.isEmpty)
          return EmptyState(
            message: 'No loans found',
            icon: Icons.account_balance_wallet_outlined,
            actionLabel: 'Add Loan',
            onAction: () => context.go('/loans/new'),
          );
        return ListView.separated(
          padding: const EdgeInsets.all(AppTheme.md),
          itemCount: loans.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppTheme.sm),
          itemBuilder: (_, i) {
            final l = loans[i];
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
                      Text(l.loanType?.name ?? 'Loan',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      StatusBadge(l.status),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _Kv('Principal', fmtCurrency(l.principal))),
                      Expanded(
                          child: _Kv('Interest', '${l.interestRate}% p.a.')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                          child: _Kv('Duration', '${l.durationMonths} months')),
                      Expanded(child: _Kv('EMI', fmtCurrency(l.emiAmount))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _Kv('Start Date', fmtDate(l.startDate)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Savings Tab ──────────────────────────────────────────────
class _SavingsTab extends StatelessWidget {
  final String customerId;
  const _SavingsTab({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (_, prov, __) {
        if (prov.state == LoadState.loading) return const LoadingWidget();
        final savings = prov.savings;
        if (savings.isEmpty)
          return EmptyState(
            message: 'No savings records',
            icon: Icons.savings_outlined,
            actionLabel: 'Add Savings',
            onAction: () => context.go('/savings/new'),
          );
        return ListView.separated(
          padding: const EdgeInsets.all(AppTheme.md),
          itemCount: savings.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppTheme.sm),
          itemBuilder: (_, i) {
            final s = savings[i];
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
                      Text(s.scheme?.name ?? 'Savings',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      StatusBadge(s.status),
                    ],
                  ),
                  const Divider(height: 16),
                  if (s.scheme != null) ...[
                    Row(children: [
                      Expanded(
                          child: _Kv(
                              'Frequency', s.scheme!.frequency.toUpperCase())),
                      Expanded(
                          child: _Kv('Amount',
                              fmtCurrency(s.scheme!.amountPerPeriod))),
                    ]),
                    const SizedBox(height: 4),
                    _Kv('Start Date', fmtDate(s.startDate)),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Jewelry Tab ──────────────────────────────────────────────
class _JewelryTab extends StatelessWidget {
  final String customerId;
  const _JewelryTab({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Consumer<JewelryProvider>(
      builder: (_, prov, __) {
        if (prov.state == LoadState.loading) return const LoadingWidget();
        final items = prov.items;
        if (items.isEmpty)
          return EmptyState(
            message: 'No jewelry pledged',
            icon: Icons.diamond_outlined,
            actionLabel: 'Pledge Item',
            onAction: () => context.go('/jewelry/new'),
          );
        return ListView.separated(
          padding: const EdgeInsets.all(AppTheme.md),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppTheme.sm),
          itemBuilder: (_, i) {
            final j = items[i];
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
                      Text(j.description ?? 'Jewelry Item',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      StatusBadge(j.status),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(children: [
                    Expanded(child: _Kv('Weight', '${j.weightGrams}g')),
                    Expanded(child: _Kv('Value', fmtCurrency(j.valueAmount))),
                  ]),
                  const SizedBox(height: 4),
                  _Kv('Pledge Date', fmtDate(j.pledgeDate)),
                  if (j.isRepledged) ...[
                    const Divider(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppTheme.warningLight,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Re-pledged at Bank',
                                style: TextStyle(
                                    color: AppTheme.warning,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                            _Kv('Bank', j.repledgeBank ?? ''),
                            if (j.repledgeAmount != null)
                              _Kv('Amount', fmtCurrency(j.repledgeAmount!)),
                            if (j.repledgeRef != null)
                              _Kv('Ref No.', j.repledgeRef!),
                          ]),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Kv extends StatelessWidget {
  final String k, v;
  const _Kv(this.k, this.v);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        Text(v,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }
}
