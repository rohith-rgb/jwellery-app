import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class SavingsFormScreen extends StatefulWidget {
  const SavingsFormScreen({super.key});
  @override
  State<SavingsFormScreen> createState() => _SavingsFormScreenState();
}

class _SavingsFormScreenState extends State<SavingsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();

  Customer? _selectedCustomer;
  SavingsScheme? _selectedScheme;
  DateTime _startDate = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadAll();
      context.read<SavingsProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    if (_selectedScheme == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a savings scheme')),
      );
      return;
    }
    setState(() => _saving = true);

    // Calculate end date based on scheme duration
    final endDate = DateTime(
      _startDate.year,
      _startDate.month + _selectedScheme!.durationMonths,
      _startDate.day,
    );

    final ok = await context.read<SavingsProvider>().enrollCustomer({
      'customer_id': _selectedCustomer!.id,
      'savings_scheme_id': _selectedScheme!.id,
      'start_date': _startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'status': 'active',
      'notes': _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    });

    setState(() => _saving = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer enrolled in savings scheme')),
      );
      context.go('/savings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Enroll in Savings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/savings'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer
              _Section('Customer', [
                Consumer<CustomerProvider>(
                  builder: (_, prov, __) => DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: const InputDecoration(
                      labelText: 'Select Customer *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: prov.customers
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c.name)))
                        .toList(),
                    onChanged: (c) => setState(() => _selectedCustomer = c),
                    validator: (v) =>
                        v == null ? 'Please select a customer' : null,
                  ),
                ),
              ]),
              const SizedBox(height: AppTheme.md),

              // Scheme selector
              _Section('Savings Scheme', [
                Consumer<SavingsProvider>(
                  builder: (_, prov, __) =>
                      DropdownButtonFormField<SavingsScheme>(
                    value: _selectedScheme,
                    decoration: const InputDecoration(
                      labelText: 'Select Scheme *',
                      prefixIcon: Icon(Icons.schema_outlined),
                    ),
                    items: prov.schemes
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(s.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                    '${s.frequency} · ${fmtCurrency(s.amountPerPeriod)} · ${s.durationMonths} mo',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (s) => setState(() => _selectedScheme = s),
                    validator: (v) =>
                        v == null ? 'Please select a scheme' : null,
                  ),
                ),

                // Scheme preview
                if (_selectedScheme != null) ...[
                  const SizedBox(height: AppTheme.md),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.md),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.accentLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scheme Details',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: _Kv('Frequency',
                                    _selectedScheme!.frequency.toUpperCase())),
                            Expanded(
                                child: _Kv(
                                    'Amount/Period',
                                    fmtCurrency(
                                        _selectedScheme!.amountPerPeriod))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                                child: _Kv('Duration',
                                    '${_selectedScheme!.durationMonths} months')),
                            Expanded(
                                child: _Kv('Interest',
                                    '${_selectedScheme!.interestRate}% p.a.')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: AppTheme.md),

              // Start date
              _Section('Enrollment Date', [
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller:
                          TextEditingController(text: fmtDate(_startDate)),
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                ),
                if (_selectedScheme != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Ends on: ${fmtDate(DateTime(_startDate.year, _startDate.month + _selectedScheme!.durationMonths, _startDate.day))}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ]),
              const SizedBox(height: AppTheme.md),

              // Notes
              _Section('Notes (Optional)', [
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                  ),
                ),
              ]),
              const SizedBox(height: AppTheme.xl),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Enroll Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      );
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppTheme.md),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.primary,
                )),
            const SizedBox(height: AppTheme.md),
            ...children,
          ],
        ),
      );
}
