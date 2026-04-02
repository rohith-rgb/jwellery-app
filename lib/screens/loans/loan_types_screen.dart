import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class LoanTypesScreen extends StatefulWidget {
  const LoanTypesScreen({super.key});
  @override
  State<LoanTypesScreen> createState() => _LoanTypesScreenState();
}

class _LoanTypesScreenState extends State<LoanTypesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<LoanProvider>().loadAll());
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final monthCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Loan Type'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: rateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Interest Rate (%)*', suffixText: '%'),
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: monthCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'Duration (months) *', suffixText: 'mo'),
                validator: (v) => v!.isEmpty ? 'Required' : null),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await context.read<LoanProvider>().createLoanType({
                'name': nameCtrl.text,
                'interest_rate': double.parse(rateCtrl.text),
                'duration_months': int.parse(monthCtrl.text),
              });
              if (ok && context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Loan Types'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/loans')),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.divider)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Type'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<LoanProvider>(
        builder: (_, prov, __) {
          if (prov.state == LoadState.loading) return const LoadingWidget();
          final types = prov.loanTypes;
          if (types.isEmpty)
            return const EmptyState(
                message: 'No loan types', icon: Icons.category_outlined);
          return ListView.separated(
            padding: const EdgeInsets.all(AppTheme.md),
            itemCount: types.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppTheme.sm),
            itemBuilder: (_, i) {
              final t = types[i];
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.account_balance_wallet,
                          color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(t.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                              '${t.interestRate}% p.a. · ${t.durationMonths} months',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13)),
                        ])),
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
