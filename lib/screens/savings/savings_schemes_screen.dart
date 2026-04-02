import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class SavingsSchemesScreen extends StatefulWidget {
  const SavingsSchemesScreen({super.key});
  @override
  State<SavingsSchemesScreen> createState() => _SavingsSchemesScreenState();
}

class _SavingsSchemesScreenState extends State<SavingsSchemesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<SavingsProvider>().loadAll());
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController(text: '0');
    final monthCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String _frequency = 'monthly';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Add Savings Scheme'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Scheme Name *'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _frequency,
                    decoration: const InputDecoration(labelText: 'Frequency *'),
                    items: ['daily', 'weekly', 'monthly']
                        .map((f) => DropdownMenuItem(
                            value: f, child: Text(f.toUpperCase())))
                        .toList(),
                    onChanged: (v) => setD(() => _frequency = v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount per Period *',
                      prefixText: '₹ ',
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: rateCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Interest Rate',
                      suffixText: '% p.a.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: monthCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Duration *',
                      suffixText: 'months',
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final ok = await context.read<SavingsProvider>().createScheme({
                  'name': nameCtrl.text,
                  'frequency': _frequency,
                  'interest_rate': double.tryParse(rateCtrl.text) ?? 0,
                  'duration_months': int.parse(monthCtrl.text),
                  'amount_per_period': double.parse(amountCtrl.text),
                });
                if (ok && context.mounted) Navigator.pop(context);
              },
              child: const Text('Add Scheme'),
            ),
          ],
        ),
      ),
    );
  }

  Color _frequencyColor(String f) => switch (f) {
        'daily' => AppTheme.success,
        'weekly' => AppTheme.primary,
        'monthly' => AppTheme.warning,
        _ => AppTheme.textSecondary,
      };

  IconData _frequencyIcon(String f) => switch (f) {
        'daily' => Icons.today_rounded,
        'weekly' => Icons.date_range_rounded,
        'monthly' => Icons.calendar_month_rounded,
        _ => Icons.schedule,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Savings Schemes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/savings'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Scheme'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SavingsProvider>(
        builder: (_, prov, __) {
          if (prov.state == LoadState.loading) return const LoadingWidget();
          final schemes = prov.schemes;
          if (schemes.isEmpty)
            return const EmptyState(
              message: 'No savings schemes',
              icon: Icons.schema_outlined,
            );
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.md, AppTheme.md, AppTheme.md, 80),
            itemCount: schemes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppTheme.sm),
            itemBuilder: (_, i) {
              final s = schemes[i];
              final color = _frequencyColor(s.frequency);
              return Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_frequencyIcon(s.frequency),
                          color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                            '${s.frequency.toUpperCase()} · ${fmtCurrency(s.amountPerPeriod)}/period',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          Text(
                            '${s.durationMonths} months · ${s.interestRate}% interest',
                            style: const TextStyle(
                                color: AppTheme.textHint, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s.frequency.toUpperCase(),
                            style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
