import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
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
    _tabs = TabController(length: 4, vsync: this);
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
    if (!mounted) return;
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
                  expandedHeight: 160,
                  backgroundColor: AppTheme.surface,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => GoRouterExt(context).go('/customers'),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => GoRouterExt(context)
                          .go('/customers/${widget.id}/edit'),
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
                          padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
                          child: Row(
                            children: [
                              _CustomerPhoto(customer: _customer!),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _customer!.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      _customer!.phone,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                    ),
                                    Text(
                                      'Aadhaar: ${_customer!.aadhaar}',
                                      style: const TextStyle(
                                          color: Colors.white60, fontSize: 11),
                                    ),
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
                    labelStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Payments'),
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
                  _PaymentsTab(customerId: widget.id),
                  _LoansTab(customerId: widget.id),
                  _SavingsTab(customerId: widget.id),
                  _JewelryTab(customerId: widget.id),
                ],
              ),
            ),
    );
  }
}

// ── Customer photo widget ─────────────────────────────────────
class _CustomerPhoto extends StatelessWidget {
  final Customer customer;
  const _CustomerPhoto({required this.customer});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = customer.photoUrl != null && customer.photoUrl!.isNotEmpty;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.2),
        border: hasPhoto
            ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
            : null,
      ),
      child: hasPhoto
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                customer.photoUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initials(),
              ),
            )
          : _initials(),
    );
  }

  Widget _initials() => Center(
        child: Text(
          customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// PAYMENTS TAB — record & view all payments
// ─────────────────────────────────────────────────────────────
class _PaymentsTab extends StatefulWidget {
  final String customerId;
  const _PaymentsTab({required this.customerId});

  @override
  State<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<_PaymentsTab> {
  final _repo = CustomerSavingsRepository();
  List<Map<String, dynamic>> _allPayments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _loading = true);
    try {
      // Load all savings enrollments for this customer
      final savings = await _repo.fetchAll(customerId: widget.customerId);
      final List<Map<String, dynamic>> payments = [];

      for (final s in savings) {
        final pmts = await _repo.fetchPayments(s.id);
        for (final p in pmts) {
          payments.add({
            'id': p.id,
            'date': p.paymentDate,
            'amount': p.amount,
            'scheme': s.scheme?.name ?? 'Savings',
            'savingsId': s.id,
          });
        }
      }

      // Sort by date descending
      payments.sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

      setState(() {
        _allPayments = payments;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _showAddPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (_) => _AddPaymentSheet(
        customerId: widget.customerId,
        onSaved: _loadPayments,
      ),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingWidget();

    final todayPayments =
        _allPayments.where((p) => _isToday(p['date'] as DateTime)).toList();
    final pastPayments =
        _allPayments.where((p) => !_isToday(p['date'] as DateTime)).toList();

    final todayTotal =
        todayPayments.fold<double>(0, (s, p) => s + (p['amount'] as double));

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaymentSheet,
        icon: const Icon(Icons.add),
        label: const Text('Record Payment'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
          children: [
            // ── Today's summary card ──────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Collections",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fmtCurrency(todayTotal),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${todayPayments.length} payment${todayPayments.length == 1 ? '' : 's'} today',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.payments_rounded,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Today's payments ─────────────────────────
            if (todayPayments.isNotEmpty) ...[
              _SectionLabel(
                  label: "Today — ${fmtDate(DateTime.now())}",
                  color: AppTheme.success),
              const SizedBox(height: 8),
              ...todayPayments
                  .map((p) => _PaymentTile(payment: p, isToday: true)),
              const SizedBox(height: 16),
            ],

            // ── Past payments ─────────────────────────────
            if (pastPayments.isNotEmpty) ...[
              const _SectionLabel(
                  label: 'Previous Payments', color: AppTheme.textSecondary),
              const SizedBox(height: 8),
              ...pastPayments
                  .map((p) => _PaymentTile(payment: p, isToday: false)),
            ],

            if (_allPayments.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: EmptyState(
                  message: 'No payments recorded yet',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 14,
            color: color,
            margin: const EdgeInsets.only(right: 8)),
        Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

// ── Payment tile ──────────────────────────────────────────────
class _PaymentTile extends StatelessWidget {
  final Map<String, dynamic> payment;
  final bool isToday;
  const _PaymentTile({required this.payment, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isToday ? AppTheme.successLight : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? AppTheme.success.withOpacity(0.3) : AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.success.withOpacity(0.15)
                  : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.currency_rupee_rounded,
              color: isToday ? AppTheme.success : AppTheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['scheme'] as String,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  fmtDate(payment['date'] as DateTime),
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtCurrency(payment['amount'] as double),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isToday ? AppTheme.success : AppTheme.primary,
                ),
              ),
              if (isToday)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('TODAY',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add Payment bottom sheet ───────────────────────────────────
class _AddPaymentSheet extends StatefulWidget {
  final String customerId;
  final VoidCallback onSaved;
  const _AddPaymentSheet({required this.customerId, required this.onSaved});

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _amountCtrl = TextEditingController();
  final _repo = CustomerSavingsRepository();
  final _savingsRepo = CustomerSavingsRepository();

  List<CustomerSavings> _savings = [];
  CustomerSavings? _selectedSavings;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavings() async {
    final list = await _savingsRepo.fetchAll(customerId: widget.customerId);
    setState(() {
      _savings = list.where((s) => s.status == 'active').toList();
      if (_savings.isNotEmpty) _selectedSavings = _savings.first;
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (_amountCtrl.text.isEmpty) return;
    if (_selectedSavings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a savings scheme first')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.addPayment({
        'customer_savings_id': _selectedSavings!.id,
        'payment_date': _date.toIso8601String().split('T').first,
        'amount': double.parse(_amountCtrl.text),
      });
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Payment of ${fmtCurrency(double.parse(_amountCtrl.text))} recorded'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Record Payment',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Add a payment for this customer',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),

          // Savings scheme selector
          if (_savings.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
              ),
              child: const Text(
                'No active savings scheme found.\nEnroll this customer in a savings scheme first.',
                style: TextStyle(color: AppTheme.warning, fontSize: 12),
              ),
            )
          else
            DropdownButtonFormField<CustomerSavings>(
              value: _selectedSavings,
              decoration: const InputDecoration(
                labelText: 'Savings Scheme',
                prefixIcon: Icon(Icons.savings_outlined),
              ),
              items: _savings
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.scheme?.name ?? 'Savings',
                            style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (s) => setState(() => _selectedSavings = s),
            ),
          const SizedBox(height: 14),

          // Amount
          TextFormField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
            ],
            decoration: const InputDecoration(
              labelText: 'Amount Paid *',
              prefixIcon: Icon(Icons.currency_rupee),
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 14),

          // Date picker
          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: TextFormField(
                controller: TextEditingController(text: fmtDate(_date)),
                decoration: const InputDecoration(
                  labelText: 'Payment Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: (_saving || _savings.isEmpty) ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Save Payment'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LOANS TAB
// ─────────────────────────────────────────────────────────────
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
            onAction: () => GoRouterExt(context).go('/loans/new'),
          );
        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: loans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final l = loans[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(l.loanType?.name ?? 'Loan',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    StatusBadge(l.status),
                  ]),
                  const Divider(height: 14),
                  Row(children: [
                    Expanded(child: _Kv('Principal', fmtCurrency(l.principal))),
                    Expanded(child: _Kv('Interest', '${l.interestRate}% p.a.')),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Expanded(
                        child: _Kv('Duration', '${l.durationMonths} months')),
                    Expanded(child: _Kv('EMI', fmtCurrency(l.emiAmount))),
                  ]),
                  const SizedBox(height: 4),
                  _Kv('Started', fmtDate(l.startDate)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SAVINGS TAB
// ─────────────────────────────────────────────────────────────
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
            onAction: () => GoRouterExt(context).go('/savings/new'),
          );
        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: savings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final s = savings[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(s.scheme?.name ?? 'Savings',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    StatusBadge(s.status),
                  ]),
                  const Divider(height: 14),
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
                    _Kv('Started', fmtDate(s.startDate)),
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

// ─────────────────────────────────────────────────────────────
// JEWELRY TAB
// ─────────────────────────────────────────────────────────────
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
            onAction: () => GoRouterExt(context).go('/jewelry/new'),
          );
        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final j = items[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(j.description ?? 'Jewelry Item',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    StatusBadge(j.status),
                  ]),
                  const Divider(height: 14),
                  Row(children: [
                    Expanded(child: _Kv('Weight', '${j.weightGrams}g')),
                    Expanded(child: _Kv('Value', fmtCurrency(j.valueAmount))),
                  ]),
                  const SizedBox(height: 4),
                  _Kv('Pledged', fmtDate(j.pledgeDate)),
                  if (j.isRepledged) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warningLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Re-pledged at: ${j.repledgeBank}',
                            style: const TextStyle(
                                color: AppTheme.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                          if (j.repledgeAmount != null)
                            _Kv('Bank Loan', fmtCurrency(j.repledgeAmount!)),
                        ],
                      ),
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

// ── Shared key-value widget ───────────────────────────────────
class _Kv extends StatelessWidget {
  final String k, v;
  const _Kv(this.k, this.v);
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(v,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      );
}
