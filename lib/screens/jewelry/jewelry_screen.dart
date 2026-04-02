import 'package:flutter/material.dart';
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
        onPressed: () => context.go('/jewelry/new'),
        icon: const Icon(Icons.add),
        label: const Text('Pledge Item'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<JewelryProvider>(
        builder: (_, prov, __) {
          if (prov.state == LoadState.loading) return const LoadingWidget();
          return Column(
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.md,
                  vertical: AppTheme.sm,
                ),
                child: Row(
                  children: [
                    _Chip(
                        label: 'All',
                        value: null,
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

              // List
              Expanded(
                child: prov.items.isEmpty
                    ? EmptyState(
                        message: 'No jewelry records',
                        icon: Icons.diamond_outlined,
                        actionLabel: 'Pledge Item',
                        onAction: () => context.go('/jewelry/new'),
                      )
                    : RefreshIndicator(
                        onRefresh: prov.loadAll,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              AppTheme.md, 0, AppTheme.md, 80),
                          itemCount: prov.items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppTheme.sm),
                          itemBuilder: (_, i) => _JewelryCard(
                            item: prov.items[i],
                            onRepledge: () =>
                                _showRepledgeSheet(context, prov.items[i]),
                            onRedeem: () =>
                                _confirmRedeem(context, prov.items[i]),
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

  void _showRepledgeSheet(BuildContext ctx, Jewelry item) {
    final bankCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    DateTime date = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (_, setS) => Padding(
          padding: EdgeInsets.only(
            left: AppTheme.md,
            right: AppTheme.md,
            top: AppTheme.md,
            bottom: MediaQuery.of(_).viewInsets.bottom + AppTheme.lg,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppTheme.divider,
                            borderRadius: BorderRadius.circular(2))),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Re-pledge at Bank',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${item.description ?? "Item"} · ${item.weightGrams}g',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: bankCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name *',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Loan Amount from Bank *',
                    prefixText: '₹ ',
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: refCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Reference / Loan Number',
                    prefixIcon: Icon(Icons.tag),
                  ),
                ),
                const SizedBox(height: 12),
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
                        labelText: 'Re-pledge Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final ok = await ctx.read<JewelryProvider>().repledge(
                          item.id,
                          bank: bankCtrl.text,
                          date: date,
                          amount: double.parse(amountCtrl.text),
                          ref: refCtrl.text.isEmpty ? null : refCtrl.text,
                        );
                    if (ok && ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Confirm Re-pledge'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmRedeem(BuildContext ctx, Jewelry item) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Redeem Jewelry'),
        content: Text(
            'Mark "${item.description ?? 'this item'}" as redeemed by customer?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            onPressed: () async {
              final ok = await ctx.read<JewelryProvider>().redeem(item.id);
              if (ok && ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String? value;
  final String? active;
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: isActive ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _JewelryCard extends StatelessWidget {
  final Jewelry item;
  final VoidCallback onRepledge;
  final VoidCallback onRedeem;
  const _JewelryCard(
      {required this.item, required this.onRepledge, required this.onRedeem});

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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFAD1457).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.diamond_rounded,
                    color: Color(0xFFAD1457), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customer?.name ?? 'Customer',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      item.description ?? 'Jewelry Item',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusBadge(item.status),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(child: _KV('Weight', '${item.weightGrams}g')),
              Expanded(child: _KV('Value', fmtCurrency(item.valueAmount))),
              Expanded(child: _KV('Pledged', fmtDate(item.pledgeDate))),
            ],
          ),

          // Re-pledge info
          if (item.isRepledged) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.warningLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance,
                          size: 14, color: AppTheme.warning),
                      const SizedBox(width: 6),
                      Text(
                        'Re-pledged at: ${item.repledgeBank}',
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (item.repledgeAmount != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                            child: _KV('Bank Loan',
                                fmtCurrency(item.repledgeAmount!))),
                        if (item.repledgeRef != null)
                          Expanded(child: _KV('Ref No.', item.repledgeRef!)),
                        if (item.repledgeDate != null)
                          Expanded(
                              child: _KV('Date', fmtDate(item.repledgeDate!))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Action buttons
          if (item.status == 'pledged' || item.status == 'repledged') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (item.status == 'pledged')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRepledge,
                      icon: const Icon(Icons.account_balance, size: 16),
                      label: const Text('Re-pledge'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.warning,
                        side: const BorderSide(color: AppTheme.warning),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                if (item.status == 'pledged') const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRedeem,
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Redeem'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
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
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(v,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      );
}
