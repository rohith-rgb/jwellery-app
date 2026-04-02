import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class CustomerFormScreen extends StatefulWidget {
  final String? customerId;
  const CustomerFormScreen({super.key, this.customerId});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _saving = false;

  bool get _isEditing => widget.customerId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _prefill();
  }

  void _prefill() {
    final c = context.read<CustomerProvider>().selected;
    if (c != null) {
      _nameCtrl.text = c.name;
      _phoneCtrl.text = c.phone;
      _aadhaarCtrl.text = c.aadhaar;
      _addressCtrl.text = c.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _aadhaarCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'aadhaar': _aadhaarCtrl.text.trim(),
      'address':
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
    };

    final prov = context.read<CustomerProvider>();
    final ok = _isEditing
        ? await prov.update(widget.customerId!, data)
        : await prov.create(data);

    setState(() => _saving = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(_isEditing ? 'Customer updated' : 'Customer created')),
      );
      context.go('/customers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Customer' : 'New Customer'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/customers')),
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
              _buildSection('Personal Information', [
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: AppTheme.md),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                  decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      prefixIcon: Icon(Icons.phone_outlined),
                      prefixText: '+91 '),
                  validator: (v) => (v == null || v.length != 10)
                      ? 'Enter valid 10-digit number'
                      : null,
                ),
                const SizedBox(height: AppTheme.md),
                TextFormField(
                  controller: _aadhaarCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12)
                  ],
                  decoration: const InputDecoration(
                      labelText: 'Aadhaar Number *',
                      prefixIcon: Icon(Icons.badge_outlined)),
                  validator: (v) => (v == null || v.length != 12)
                      ? 'Enter 12-digit Aadhaar'
                      : null,
                ),
              ]),
              const SizedBox(height: AppTheme.md),
              _buildSection('Address (Optional)', [
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      alignLabelWithHint: true),
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
                            color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Update Customer' : 'Create Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
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
                  color: AppTheme.primary)),
          const SizedBox(height: AppTheme.md),
          ...children,
        ],
      ),
    );
  }
}
