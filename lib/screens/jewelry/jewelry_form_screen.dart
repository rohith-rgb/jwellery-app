import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class JewelryFormScreen extends StatefulWidget {
  const JewelryFormScreen({super.key});
  @override
  State<JewelryFormScreen> createState() => _JewelryFormScreenState();
}

class _JewelryFormScreenState extends State<JewelryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Customer? _selectedCustomer;
  DateTime _pledgeDate = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<CustomerProvider>().loadAll());
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _weightCtrl.dispose();
    _valueCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _pledgeDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _pledgeDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    setState(() => _saving = true);

    final ok = await context.read<JewelryProvider>().create({
      'customer_id': _selectedCustomer!.id,
      'description':
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'weight_grams': double.parse(_weightCtrl.text),
      'value_amount': double.parse(_valueCtrl.text),
      'pledge_date': _pledgeDate.toIso8601String().split('T').first,
      'status': 'pledged',
      'notes': _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    });

    setState(() => _saving = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jewelry pledged successfully')),
      );
      context.go('/jewelry');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Pledge Jewelry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/jewelry'),
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
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: (c) => setState(() => _selectedCustomer = c),
                    validator: (v) =>
                        v == null ? 'Please select a customer' : null,
                  ),
                ),
              ]),
              const SizedBox(height: AppTheme.md),

              // Jewelry details
              _Section('Jewelry Details', [
                TextFormField(
                  controller: _descCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Gold Necklace 22K, Gold Bangle',
                    prefixIcon: Icon(Icons.diamond_outlined),
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Weight *',
                          suffixText: 'grams',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _valueCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Value *',
                          prefixText: '₹ ',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.md),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller:
                          TextEditingController(text: fmtDate(_pledgeDate)),
                      decoration: const InputDecoration(
                        labelText: 'Pledge Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: AppTheme.md),

              // Value estimate helper
              if (_weightCtrl.text.isNotEmpty)
                _GoldEstimate(
                    weightGrams: double.tryParse(_weightCtrl.text) ?? 0),

              const SizedBox(height: AppTheme.md),

              // Notes
              _Section('Notes (Optional)', [
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                    hintText: 'Any additional details about the item…',
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 18),
                          SizedBox(width: 8),
                          Text('Pledge Jewelry'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple gold rate estimate widget
class _GoldEstimate extends StatelessWidget {
  final double weightGrams;
  // Approximate 22K gold rate per gram (admin can adjust)
  static const double _ratePerGram = 6800.0;

  const _GoldEstimate({required this.weightGrams});

  @override
  Widget build(BuildContext context) {
    if (weightGrams <= 0) return const SizedBox.shrink();
    final estimated = weightGrams * _ratePerGram;

    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFF9A825)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Estimated 22K market value: ${fmtCurrency(estimated)} (at ₹${_ratePerGram.toInt()}/g)',
              style: const TextStyle(color: Color(0xFFF9A825), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
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
