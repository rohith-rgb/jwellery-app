import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class LoanFormScreen extends StatefulWidget {
  const LoanFormScreen({super.key});
  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Customer? _selectedCustomer;
  LoanType? _selectedLoanType;
  DateTime _startDate = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadAll();
      context.read<LoanProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    _rateCtrl.dispose();
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onLoanTypeChanged(LoanType? t) {
    setState(() {
      _selectedLoanType = t;
    });
    if (t != null) {
      _rateCtrl.text = t.interestRate.toString();
      _durationCtrl.text = t.durationMonths.toString();
    }
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
          const SnackBar(content: Text('Please select a customer')));
      return;
    }
    setState(() => _saving = true);

    final ok = await context.read<LoanProvider>().createLoan({
      'customer_id': _selectedCustomer!.id,
      'loan_type_id': _selectedLoanType?.id,
      'principal': double.parse(_principalCtrl.text),
      'interest_rate': double.parse(_rateCtrl.text),
      'duration_months': int.parse(_durationCtrl.text),
      'start_date': _startDate.toIso8601String().split('T').first,
      'notes': _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    });

    setState(() => _saving = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Loan created')));
      context.go('/loans');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('New Loan'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/loans')),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.divider)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer selector
              _Section('Customer', [
                Consumer<CustomerProvider>(
                  builder: (_, prov, __) => DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: const InputDecoration(
                        labelText: 'Select Customer *',
                        prefixIcon: Icon(Icons.person_outline)),
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

              // Loan type
              _Section('Loan Type (Optional)', [
                Consumer<LoanProvider>(
                  builder: (_, prov, __) => DropdownButtonFormField<LoanType>(
                    value: _selectedLoanType,
                    decoration: const InputDecoration(
                        labelText: 'Loan Type',
                        prefixIcon: Icon(Icons.category_outlined)),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Custom')),
                      ...prov.loanTypes.map((t) =>
                          DropdownMenuItem(value: t, child: Text(t.name))),
                    ],
                    onChanged: _onLoanTypeChanged,
                  ),
                ),
              ]),
              const SizedBox(height: AppTheme.md),

              // Loan details
              _Section('Loan Details', [
                TextFormField(
                  controller: _principalCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  decoration: const InputDecoration(
                      labelText: 'Principal Amount *',
                      prefixIcon: Icon(Icons.currency_rupee),
                      prefixText: '₹ '),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter amount' : null,
                ),
                const SizedBox(height: AppTheme.md),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                    controller: _rateCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Interest Rate *', suffixText: '% p.a.'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextFormField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                        labelText: 'Duration *', suffixText: 'months'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  )),
                ]),
                const SizedBox(height: AppTheme.md),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        hintText: fmtDate(_startDate),
                      ),
                      controller:
                          TextEditingController(text: fmtDate(_startDate)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: AppTheme.md),

              _Section('Notes (Optional)', [
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Notes', alignLabelWithHint: true),
                ),
              ]),

              // EMI preview
              if (_principalCtrl.text.isNotEmpty &&
                  _rateCtrl.text.isNotEmpty &&
                  _durationCtrl.text.isNotEmpty)
                _EmiPreview(
                  principal: double.tryParse(_principalCtrl.text) ?? 0,
                  rate: double.tryParse(_rateCtrl.text) ?? 0,
                  months: int.tryParse(_durationCtrl.text) ?? 0,
                ),

              const SizedBox(height: AppTheme.xl),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Create Loan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmiPreview extends StatelessWidget {
  final double principal, rate;
  final int months;
  const _EmiPreview(
      {required this.principal, required this.rate, required this.months});

  @override
  Widget build(BuildContext context) {
    if (months == 0) return const SizedBox.shrink();
    final interest = principal * (rate / 100) * (months / 12);
    final total = principal + interest;
    final emi = total / months;

    return Container(
      margin: const EdgeInsets.only(top: AppTheme.md),
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.accentLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Loan Preview',
              style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _Kv('Total Interest', fmtCurrency(interest))),
            Expanded(child: _Kv('Total Payable', fmtCurrency(total))),
            Expanded(child: _Kv('Monthly EMI', fmtCurrency(emi))),
          ]),
        ],
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
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.primary)),
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
            border: Border.all(color: AppTheme.divider)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.primary)),
          const SizedBox(height: AppTheme.md),
          ...children,
        ]),
      );
}
