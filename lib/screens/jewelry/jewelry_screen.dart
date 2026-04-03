import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class JewelryScreen extends StatefulWidget {
  const JewelryScreen({super.key});
  @override
  State<JewelryScreen> createState() => _JewelryScreenState();
}

class _JewelryScreenState extends State<JewelryScreen> {
  String? _activeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<JewelryProvider>().loadAll());
  }

  void _setFilter(String? f) {
    setState(() => _activeFilter = f);
    context.read<JewelryProvider>().setFilter(f);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Jewelry',
      currentRoute: '/jewelry',
      fab: FloatingActionButton.extended(
        onPressed: () => GoRouter.of(context).go('/jewelry/new'),
        icon: const Icon(Icons.add),
        label: const Text('Pledge Item'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<JewelryProvider>(
        builder: (_, prov, __) {
          if (prov.state == LoadState.loading) return const LoadingWidget();

          // Alert banner: items approaching 6 months
          final approaching = prov.allItems
              .where((j) => j.isApproachingSixMonths && j.status != 'redeemed')
              .toList();

          return Column(
            children: [
              // ── 6-month alert banner ─────────────────────
              if (approaching.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.warningLight,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppTheme.warning.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded,
                          color: AppTheme.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${approaching.length} item${approaching.length > 1 ? 's' : ''} approaching 6-month mark! Interest will change to 2%.',
                          style: const TextStyle(
                              color: AppTheme.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Filter chips ─────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _Chip(
                        label: 'All',
                        value: null,
                        active: _activeFilter,
                        onTap: _setFilter),
                    const SizedBox(width: 8),
                    _Chip(
                        label: '⚠ 6-Month',
                        value: 'alert',
                        active: _activeFilter,
                        onTap: _setFilter),
                    const SizedBox(width: 8),
                    _Chip(
                        label: 'Pledged',
                        value: 'pledged',
                        active: _activeFilter,
                        onTap: _setFilter),
                    const SizedBox(width: 8),
                    _Chip(
                        label: 'Repledged',
                        value: 'repledged',
                        active: _activeFilter,
                        onTap: _setFilter),
                    const SizedBox(width: 8),
                    _Chip(
                        label: 'Redeemed',
                        value: 'redeemed',
                        active: _activeFilter,
                        onTap: _setFilter),
                  ],
                ),
              ),

              // ── List ─────────────────────────────────────
              Expanded(
                child: prov.items.isEmpty
                    ? EmptyState(
                        message: 'No jewelry records',
                        icon: Icons.diamond_outlined,
                        actionLabel: 'Pledge Item',
                        onAction: () => GoRouter.of(context).go('/jewelry/new'),
                      )
                    : RefreshIndicator(
                        onRefresh: prov.loadAll,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                          itemCount: prov.items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) => _JewelryCard(
                            item: prov.items[i],
                            onRepledge: () =>
                                _showRepledgeSheet(context, prov.items[i]),
                            onRedeem: () =>
                                _showRedeemDialog(context, prov.items[i]),
                            onViewBill: () => _showBill(context, prov.items[i]),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Re-pledge sheet ──────────────────────────────────────────
  void _showRepledgeSheet(BuildContext ctx, Jewelry item) {
    final bankCtrl = TextEditingController(text: item.repledgeBank ?? '');
    final amountCtrl = TextEditingController(
        text: item.repledgeAmount?.toStringAsFixed(0) ?? '');
    final refCtrl = TextEditingController(text: item.repledgeRef ?? '');
    final fromCtrl = TextEditingController();
    DateTime date = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl))),
      builder: (_) => StatefulBuilder(
        builder: (_, setS) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(_).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                      child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(2)),
                  )),
                  const SizedBox(height: 14),
                  Text('Renewal / Re-pledge',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  Text(
                    '${item.description ?? "Item"} · ${item.weightGrams}g',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: fromCtrl,
                    decoration: const InputDecoration(
                        labelText: 'From Bank (previous)',
                        prefixIcon: Icon(Icons.account_balance_outlined)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: bankCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: 'To Bank (new bank) *',
                        prefixIcon: Icon(Icons.account_balance_rounded)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'New Loan Amount *', prefixText: '₹ '),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: refCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Loan Number / Reference',
                        prefixIcon: Icon(Icons.tag)),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setS(() => date = d);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(text: fmtDate(date)),
                        decoration: const InputDecoration(
                            labelText: 'Renewal Date',
                            prefixIcon: Icon(Icons.calendar_today_outlined)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      // Calculate interest paid up to renewal date
                      final calc = item.calculateInterest(upTo: date);
                      final ok = await ctx.read<JewelryProvider>().repledge(
                            item.id,
                            bank: bankCtrl.text,
                            date: date,
                            amount: double.parse(amountCtrl.text),
                            ref: refCtrl.text.isEmpty ? null : refCtrl.text,
                            fromBank: fromCtrl.text,
                            interestPaid: calc.totalInterest,
                          );
                      if (ok && ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Confirm Renewal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Redeem dialog ────────────────────────────────────────────
  void _showRedeemDialog(BuildContext ctx, Jewelry item) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Redeem Jewelry'),
        content: Text(
            'Mark "${item.description ?? "this item"}" as redeemed?\nA bill will be generated.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            onPressed: () async {
              final ok = await ctx.read<JewelryProvider>().redeem(item.id);
              if (ok && ctx.mounted) {
                Navigator.pop(ctx);
                _showBill(ctx, item);
              }
            },
            child: const Text('Redeem & Generate Bill'),
          ),
        ],
      ),
    );
  }

  // ── Bill dialog ──────────────────────────────────────────────
  void _showBill(BuildContext ctx, Jewelry item) {
    final calc = item.calculateInterest();
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _BillSheet(item: item, calc: calc),
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final String? value, active;
  final void Function(String?) onTap;
  const _Chip(
      {required this.label,
      required this.value,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = active == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: isActive ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(label,
            style: TextStyle(
              color: isActive ? Colors.white : AppTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 12,
            )),
      ),
    );
  }
}

// ── Jewelry card ──────────────────────────────────────────────
class _JewelryCard extends StatelessWidget {
  final Jewelry item;
  final VoidCallback onRepledge, onRedeem, onViewBill;
  const _JewelryCard(
      {required this.item,
      required this.onRepledge,
      required this.onRedeem,
      required this.onViewBill});

  @override
  Widget build(BuildContext context) {
    final calc = item.calculateInterest();
    final alert = item.isApproachingSixMonths && item.status != 'redeemed';
    final pastSix = item.isPastSixMonths;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert ? AppTheme.warning.withOpacity(0.5) : AppTheme.divider,
          width: alert ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAD1457).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.diamond_rounded,
                      color: Color(0xFFAD1457), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.customer?.name ?? 'Customer',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        '${item.description ?? "Jewelry"}'
                        '${item.itemType != null ? " · ${item.itemType}" : ""}'
                        '${item.quantity != null ? " × ${item.quantity}" : ""}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(item.status),
                    if (alert)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.warning,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${item.daysUntilSixMonths}d to 6mo',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 16, indent: 12, endIndent: 12),

          // ── Details ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: _KV('Weight', '${item.weightGrams}g')),
                  Expanded(
                      child: _KV('Principal', fmtCurrency(item.valueAmount))),
                  Expanded(child: _KV('Days Held', '${calc.daysHeld} days')),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: _KV('Pledge Date', fmtDate(item.pledgeDate))),
                  Expanded(
                      child: _KV(
                    'Rate',
                    pastSix
                        ? '${item.interestRatePhase1}% → ${item.interestRatePhase2}%'
                        : '${item.interestRatePhase1}%',
                  )),
                  Expanded(
                      child: _KV('Interest', fmtCurrency(calc.totalInterest))),
                ]),
                const SizedBox(height: 6),
                // Total payable highlight
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: pastSix
                        ? AppTheme.warningLight
                        : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pastSix
                            ? '⚠ Past 6 months — Rate: ${item.interestRatePhase2}%'
                            : 'Total Amount Due',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: pastSix
                              ? AppTheme.warning
                              : AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        fmtCurrency(calc.totalAmount),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: pastSix ? AppTheme.warning : AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Repledge info ────────────────────────────────
          if (item.isRepledged && item.repledgeBank != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warningLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.account_balance,
                      size: 14, color: AppTheme.warning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'At: ${item.repledgeBank}'
                      '${item.repledgeRef != null ? " · Ref: ${item.repledgeRef}" : ""}',
                      style: const TextStyle(
                          color: AppTheme.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (item.repledgeAmount != null)
                    Text(fmtCurrency(item.repledgeAmount!),
                        style: const TextStyle(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                ]),
              ),
            ),

          // ── Renewal history ──────────────────────────────
          if (item.renewals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Renewal History',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  ...item.renewals.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          const Icon(Icons.swap_horiz_rounded,
                              size: 14, color: AppTheme.textHint),
                          const SizedBox(width: 6),
                          Text('${r.fromBank} → ${r.toBank}',
                              style: const TextStyle(fontSize: 11)),
                          const Spacer(),
                          Text(fmtDate(r.renewalDate),
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.textSecondary)),
                        ]),
                      )),
                ],
              ),
            ),

          // ── Action buttons ───────────────────────────────
          if (item.status != 'redeemed')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(children: [
                if (item.status == 'pledged')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRepledge,
                      icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                      label: const Text('Renew'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.warning,
                        side: const BorderSide(color: AppTheme.warning),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                if (item.status == 'pledged') const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewBill,
                    icon: const Icon(Icons.receipt_long_outlined, size: 14),
                    label: const Text('Bill'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRedeem,
                    icon: const Icon(Icons.check_circle_outline, size: 14),
                    label: const Text('Redeem'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ]),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: OutlinedButton.icon(
                onPressed: onViewBill,
                icon: const Icon(Icons.receipt_long_outlined, size: 14),
                label: const Text('View Bill'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Bill sheet ────────────────────────────────────────────────
class _BillSheet extends StatelessWidget {
  final Jewelry item;
  final JewelryInterestCalc calc;
  const _BillSheet({required this.item, required this.calc});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bill header
          Center(
            child: Column(children: [
              const Icon(Icons.diamond_rounded,
                  color: AppTheme.primary, size: 32),
              const SizedBox(height: 6),
              const Text('REDEMPTION BILL',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
              Text(fmtDate(DateTime.now()),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ]),
          ),
          const Divider(height: 24),

          // Customer
          _BillRow('Customer', item.customer?.name ?? '-'),
          _BillRow('Phone', item.customer?.phone ?? '-'),
          const Divider(height: 16),

          // Jewelry details
          _BillRow('Description', item.description ?? '-'),
          if (item.itemType != null) _BillRow('Type', item.itemType!),
          if (item.quantity != null) _BillRow('Quantity', '${item.quantity}'),
          _BillRow('Weight', '${item.weightGrams} grams'),
          const Divider(height: 16),

          // Date & duration
          _BillRow('Pledge Date', fmtDate(item.pledgeDate)),
          _BillRow('Redemption Date', fmtDate(DateTime.now())),
          _BillRow('Days Held', '${calc.daysHeld} days'),
          const Divider(height: 16),

          // Interest breakdown
          _BillRow('Principal Amount', fmtCurrency(calc.principal)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(children: [
              _BillRow(
                'Phase 1 (${calc.phase1Months.toStringAsFixed(1)} mo @ ${calc.phase1Rate}%)',
                fmtCurrency(calc.phase1Interest),
              ),
              if (calc.phase2Months > 0)
                _BillRow(
                  'Phase 2 (${calc.phase2Months.toStringAsFixed(1)} mo @ ${calc.phase2Rate}%)',
                  fmtCurrency(calc.phase2Interest),
                ),
              const Divider(height: 10),
              _BillRow('Total Interest', fmtCurrency(calc.totalInterest),
                  bold: true),
            ]),
          ),
          const SizedBox(height: 12),

          // Total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(children: [
              const Text('TOTAL AMOUNT DUE',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(fmtCurrency(calc.totalAmount),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900)),
            ]),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Close'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Bill ready — connect printer to print')),
                  );
                },
                icon: const Icon(Icons.print_rounded, size: 16),
                label: const Text('Print'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _BillRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          ],
        ),
      );
}

class _KV extends StatelessWidget {
  final String k, v;
  const _KV(this.k, this.v);
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
          Text(v,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      );
}
