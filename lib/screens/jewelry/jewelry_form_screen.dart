import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/photo_upload_widget.dart';

class JewelryFormScreen extends StatefulWidget {
  const JewelryFormScreen({super.key});
  @override
  State<JewelryFormScreen> createState() => _JewelryFormScreenState();
}

class _JewelryFormScreenState extends State<JewelryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _itemTypeCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _weightCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _manualIntCtrl = TextEditingController();
  final _phase1RateCtrl = TextEditingController(text: '1.5');
  final _phase2RateCtrl = TextEditingController(text: '2.0');
  final _dateTextCtrl = TextEditingController();

  Customer? _selectedCustomer;

  // FIX 1: past date — allow any date from 2015 onwards, default today
  DateTime _pledgeDate = DateTime.now();

  // FIX 2: manual interest toggle
  bool _autoInterest = true;
  bool _saving = false;

  // FIX 3: historical record mode
  bool _isHistoricalRecord = false;

  // Photo upload
  final List<String> _photoUrls = [];

  @override
  void initState() {
    super.initState();
    _dateTextCtrl.text = fmtDate(_pledgeDate);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<CustomerProvider>().loadAll());
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _itemTypeCtrl.dispose();
    _quantityCtrl.dispose();
    _weightCtrl.dispose();
    _valueCtrl.dispose();
    _notesCtrl.dispose();
    _manualIntCtrl.dispose();
    _phase1RateCtrl.dispose();
    _phase2RateCtrl.dispose();
    _dateTextCtrl.dispose();
    super.dispose();
  }

  // ── FIX: date picker allows past dates freely ──────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      // Allow all dates from 2015 up to today — no future dates for pledges
      initialDate: _pledgeDate.isAfter(now) ? now : _pledgeDate,
      firstDate: DateTime(2015, 1, 1), // historical records supported
      lastDate: now,
      helpText: 'Select Pledge Date',
      fieldLabelText: 'Pledge Date',
      fieldHintText: 'dd/mm/yyyy',
    );
    if (d != null) {
      setState(() {
        _pledgeDate = d;
        _dateTextCtrl.text = fmtDate(d);
      });
    }
  }

  // ── Live auto interest preview ─────────────────────────────
  JewelryInterestCalc? get _interestPreview {
    final val = double.tryParse(_valueCtrl.text);
    if (val == null || val <= 0) return null;
    final r1 = double.tryParse(_phase1RateCtrl.text) ?? 1.5;
    final r2 = double.tryParse(_phase2RateCtrl.text) ?? 2.0;
    final dummy = Jewelry(
      id: '',
      customerId: '',
      weightGrams: 0,
      valueAmount: val,
      pledgeDate: _pledgeDate,
      status: 'pledged',
      interestRatePhase1: r1,
      interestRatePhase2: r2,
    );
    return dummy.calculateInterest();
  }

  // ── FIX: save with exact past date, no rejection ───────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      _showError('Please select a customer');
      return;
    }
    if (_valueCtrl.text.isEmpty) {
      _showError('Please enter the principal amount');
      return;
    }

    setState(() => _saving = true);

    // Build the record — use the exact selected date (past or today)
    final pledgeDateStr = _pledgeDate.toIso8601String().split('T').first;

    final data = <String, dynamic>{
      'customer_id': _selectedCustomer!.id,
      'description':
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'item_type':
          _itemTypeCtrl.text.trim().isEmpty ? null : _itemTypeCtrl.text.trim(),
      'quantity': int.tryParse(_quantityCtrl.text) ?? 1,
      'weight_grams': double.parse(_weightCtrl.text),
      'value_amount': double.parse(_valueCtrl.text),
      // FIX: store the exact date string — works for past dates
      'pledge_date': pledgeDateStr,
      'status': 'pledged',
      'interest_rate_phase1': double.tryParse(_phase1RateCtrl.text) ?? 1.5,
      'interest_rate_phase2': double.tryParse(_phase2RateCtrl.text) ?? 2.0,
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      'image_url': _photoUrls.isNotEmpty ? _photoUrls.join(',') : null,
    };

    // If manual interest mode — store override in notes
    if (!_autoInterest && _manualIntCtrl.text.isNotEmpty) {
      final manualAmt = double.tryParse(_manualIntCtrl.text) ?? 0;
      data['notes'] = '[Manual Interest: ₹${manualAmt.toStringAsFixed(0)}] '
          '${data['notes'] ?? ''}';
    }

    try {
      final ok = await context.read<JewelryProvider>().create(data);
      setState(() => _saving = false);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isHistoricalRecord
                ? 'Historical record saved for ${fmtDate(_pledgeDate)}'
                : 'Jewelry pledged successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        GoRouter.of(context).go('/jewelry');
      }
    } catch (e) {
      setState(() => _saving = false);
      _showError('Save failed: ${e.toString()}');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _interestPreview;
    final isOldDate =
        _pledgeDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
            _isHistoricalRecord ? 'Add Historical Record' : 'Pledge Jewelry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/jewelry'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── FIX 3: Historical record toggle ──────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _isHistoricalRecord
                      ? AppTheme.warningLight
                      : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isHistoricalRecord
                        ? AppTheme.warning.withOpacity(0.4)
                        : AppTheme.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isHistoricalRecord
                          ? Icons.history_rounded
                          : Icons.add_circle_outline,
                      size: 18,
                      color: _isHistoricalRecord
                          ? AppTheme.warning
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isHistoricalRecord
                                ? 'Historical Record Mode'
                                : 'New Pledge Record',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: _isHistoricalRecord
                                  ? AppTheme.warning
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            _isHistoricalRecord
                                ? 'Enter existing loan with past date'
                                : 'Toggle for pre-existing loan records',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isHistoricalRecord,
                      onChanged: (v) => setState(() => _isHistoricalRecord = v),
                      activeColor: AppTheme.warning,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Customer ─────────────────────────────────
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
              const SizedBox(height: 12),

              // ── Jewelry Details ───────────────────────────
              _Section('Jewelry Details', [
                TextFormField(
                  controller: _descCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Gold Necklace 22K',
                    prefixIcon: Icon(Icons.diamond_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itemTypeCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'Item Type',
                          hintText: 'Necklace / Bangle'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Qty'),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                      ],
                      decoration: const InputDecoration(
                          labelText: 'Weight *', suffixText: 'grams'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _valueCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                      ],
                      decoration: const InputDecoration(
                          labelText: 'Principal Amount *', prefixText: '₹ '),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ]),
              ]),
              const SizedBox(height: 12),

              // ── Pledge Date (FIX: past dates work) ───────
              _Section(
                _isHistoricalRecord
                    ? 'Original Pledge Date (Historical)'
                    : 'Pledge Date',
                [
                  // Tap anywhere on the row to open picker
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(10),
                    child: TextFormField(
                      controller: _dateTextCtrl,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: InputDecoration(
                        labelText: _isHistoricalRecord
                            ? 'Original Pledge Date *'
                            : 'Pledge Date *',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        suffixIcon: const Icon(Icons.arrow_drop_down,
                            color: AppTheme.primary),
                        helperText: _isHistoricalRecord
                            ? 'Select the original date the item was pledged'
                            : null,
                      ),
                    ),
                  ),
                  // Show how long ago if past date selected
                  if (isOldDate) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isHistoricalRecord
                            ? AppTheme.warningLight
                            : AppTheme.successLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        Icon(
                          _isHistoricalRecord
                              ? Icons.history_rounded
                              : Icons.check_circle_outline,
                          size: 14,
                          color: _isHistoricalRecord
                              ? AppTheme.warning
                              : AppTheme.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${DateTime.now().difference(_pledgeDate).inDays} days ago'
                          '${_isHistoricalRecord ? " — historical record" : ""}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isHistoricalRecord
                                ? AppTheme.warning
                                : AppTheme.success,
                          ),
                        ),
                      ]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // ── Interest Settings ─────────────────────────
              _Section('Interest Settings', [
                // FIX 1: Auto / Manual toggle
                Row(children: [
                  const Icon(Icons.percent_rounded,
                      size: 18, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Auto-Calculate Interest',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(
                          '1.5% for 6 months, then 2%',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _autoInterest,
                    onChanged: (v) => setState(() => _autoInterest = v),
                    activeColor: AppTheme.primary,
                  ),
                ]),
                const Divider(height: 16),

                if (_autoInterest) ...[
                  // Editable rate fields
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phase1RateCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Rate Phase 1',
                          suffixText: '%',
                          helperText: 'First 6 months',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phase2RateCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Rate Phase 2',
                          suffixText: '%',
                          helperText: 'After 6 months',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ]),

                  // Live preview
                  if (preview != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.accentLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.calculate_outlined,
                                size: 14, color: AppTheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Interest Preview (${preview.daysHeld} days held)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          _PreviewRow(
                            'Phase 1 (${preview.phase1Months.toStringAsFixed(1)} mo @ ${preview.phase1Rate}%)',
                            fmtCurrency(preview.phase1Interest),
                          ),
                          if (preview.phase2Months > 0)
                            _PreviewRow(
                              'Phase 2 (${preview.phase2Months.toStringAsFixed(1)} mo @ ${preview.phase2Rate}%)',
                              fmtCurrency(preview.phase2Interest),
                            ),
                          const Divider(height: 10),
                          _PreviewRow(
                            'Total Interest',
                            fmtCurrency(preview.totalInterest),
                            bold: true,
                          ),
                          _PreviewRow(
                            'Total Payable',
                            fmtCurrency(preview.totalAmount),
                            bold: true,
                            highlight: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  // Manual interest entry
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.warningLight,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppTheme.warning.withOpacity(0.3)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.edit_note_rounded,
                          size: 16, color: AppTheme.warning),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Manual mode — enter the interest amount directly. Auto-calculation is disabled.',
                          style:
                              TextStyle(color: AppTheme.warning, fontSize: 12),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _manualIntCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Manual Interest Amount',
                      prefixText: '₹ ',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                  if (_manualIntCtrl.text.isNotEmpty &&
                      _valueCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ManualTotal(
                      principal: double.tryParse(_valueCtrl.text) ?? 0,
                      interest: double.tryParse(_manualIntCtrl.text) ?? 0,
                    ),
                  ],
                ],
              ]),
              const SizedBox(height: 12),

              // ── Jewelry Photos ────────────────────────────
              _Section('Jewelry Photos (Up to 4)', [
                const Text(
                  'Add clear photos of the jewelry for verification',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                MultiPhotoUpload(
                  bucket: 'jewelry-photos',
                  existingUrls: _photoUrls,
                  maxPhotos: 4,
                  onChanged: (urls) => setState(() {
                    _photoUrls
                      ..clear()
                      ..addAll(urls);
                  }),
                ),
              ]),
              const SizedBox(height: 12),

              // ── Notes ─────────────────────────────────────
              _Section('Notes (Optional)', [
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                    hintText: 'Additional details…',
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Save button ───────────────────────────────
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isHistoricalRecord
                                ? Icons.history_edu_rounded
                                : Icons.lock_outline,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isHistoricalRecord
                                ? 'Save Historical Record'
                                : 'Pledge Jewelry',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 8),
              // Helper text under button
              Center(
                child: Text(
                  _isHistoricalRecord
                      ? 'Record will be saved with date: ${fmtDate(_pledgeDate)}'
                      : 'Interest auto-calculates from pledge date',
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textHint),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Preview row ───────────────────────────────────────────────
class _PreviewRow extends StatelessWidget {
  final String label, value;
  final bool bold, highlight;
  const _PreviewRow(this.label, this.value,
      {this.bold = false, this.highlight = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color:
                        highlight ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                    color:
                        highlight ? AppTheme.primary : AppTheme.textPrimary)),
          ],
        ),
      );
}

// ── Manual total preview ──────────────────────────────────────
class _ManualTotal extends StatelessWidget {
  final double principal, interest;
  const _ManualTotal({required this.principal, required this.interest});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Payable',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(fmtCurrency(principal + interest),
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTheme.primary)),
          ],
        ),
      );
}

// ── Section card ──────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.primary)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );
}
