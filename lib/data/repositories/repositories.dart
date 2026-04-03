import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../supabase/supabase_service.dart';
import '../../core/constants/app_constants.dart';

// ── Auth Repository ──────────────────────────────────────────
class AuthRepository {
  final _client = SupabaseService.client;

  Future<AuthResponse> signIn(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _client.auth.signOut();

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}

// ── Customer Repository ──────────────────────────────────────
class CustomerRepository {
  final _db = SupabaseService.client;

  Future<List<Customer>> fetchAll() async {
    final res = await _db.from(AppConstants.tCustomers).select().order('name');
    return (res as List).map((e) => Customer.fromJson(e)).toList();
  }

  Future<Customer> fetchById(String id) async {
    final res =
        await _db.from(AppConstants.tCustomers).select().eq('id', id).single();
    return Customer.fromJson(res);
  }

  Future<List<Customer>> search(String query) async {
    final res = await _db
        .from(AppConstants.tCustomers)
        .select()
        .or('name.ilike.%$query%,phone.ilike.%$query%,aadhaar.ilike.%$query%')
        .order('name');
    return (res as List).map((e) => Customer.fromJson(e)).toList();
  }

  Future<Customer> create(Map<String, dynamic> data) async {
    final res =
        await _db.from(AppConstants.tCustomers).insert(data).select().single();
    return Customer.fromJson(res);
  }

  Future<Customer> update(String id, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    final res = await _db
        .from(AppConstants.tCustomers)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Customer.fromJson(res);
  }

  Future<void> delete(String id) =>
      _db.from(AppConstants.tCustomers).delete().eq('id', id);
}

// ── Loan Type Repository ─────────────────────────────────────
class LoanTypeRepository {
  final _db = SupabaseService.client;

  Future<List<LoanType>> fetchAll() async {
    final res = await _db.from(AppConstants.tLoanTypes).select().order('name');
    return (res as List).map((e) => LoanType.fromJson(e)).toList();
  }

  Future<LoanType> create(Map<String, dynamic> data) async {
    final res =
        await _db.from(AppConstants.tLoanTypes).insert(data).select().single();
    return LoanType.fromJson(res);
  }

  Future<LoanType> update(String id, Map<String, dynamic> data) async {
    final res = await _db
        .from(AppConstants.tLoanTypes)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return LoanType.fromJson(res);
  }

  Future<void> delete(String id) =>
      _db.from(AppConstants.tLoanTypes).delete().eq('id', id);
}

// ── Loan Repository ──────────────────────────────────────────
class LoanRepository {
  final _db = SupabaseService.client;

  Future<List<Loan>> fetchAll({String? customerId, String? status}) async {
    var query =
        _db.from(AppConstants.tLoans).select('*, customers(*), loan_types(*)');
    if (customerId != null) query = query.eq('customer_id', customerId);
    if (status != null) query = query.eq('status', status);
    final res = await query.order('start_date', ascending: false);
    return (res as List).map((e) => Loan.fromJson(e)).toList();
  }

  Future<Loan> create(Map<String, dynamic> data) async {
    final res = await _db
        .from(AppConstants.tLoans)
        .insert(data)
        .select('*, customers(*), loan_types(*)')
        .single();
    return Loan.fromJson(res);
  }

  Future<Loan> update(String id, Map<String, dynamic> data) async {
    final res = await _db
        .from(AppConstants.tLoans)
        .update(data)
        .eq('id', id)
        .select('*, customers(*), loan_types(*)')
        .single();
    return Loan.fromJson(res);
  }

  Future<void> delete(String id) =>
      _db.from(AppConstants.tLoans).delete().eq('id', id);
}

// ── Savings Scheme Repository ────────────────────────────────
class SavingsSchemeRepository {
  final _db = SupabaseService.client;

  Future<List<SavingsScheme>> fetchAll() async {
    final res =
        await _db.from(AppConstants.tSavingsSchemes).select().order('name');
    return (res as List).map((e) => SavingsScheme.fromJson(e)).toList();
  }

  Future<SavingsScheme> create(Map<String, dynamic> data) async {
    final res = await _db
        .from(AppConstants.tSavingsSchemes)
        .insert(data)
        .select()
        .single();
    return SavingsScheme.fromJson(res);
  }

  Future<SavingsScheme> update(String id, Map<String, dynamic> data) async {
    final res = await _db
        .from(AppConstants.tSavingsSchemes)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return SavingsScheme.fromJson(res);
  }

  Future<void> delete(String id) =>
      _db.from(AppConstants.tSavingsSchemes).delete().eq('id', id);
}

// ── Customer Savings Repository ──────────────────────────────
class CustomerSavingsRepository {
  final _db = SupabaseService.client;

  Future<List<CustomerSavings>> fetchAll({String? customerId}) async {
    var query = _db
        .from(AppConstants.tCustomerSavings)
        .select('*, customers(*), savings_schemes(*)');
    if (customerId != null) query = query.eq('customer_id', customerId);
    final res = await query.order('start_date', ascending: false);
    return (res as List).map((e) => CustomerSavings.fromJson(e)).toList();
  }

  Future<CustomerSavings> create(Map<String, dynamic> data) async {
    final res = await _db
        .from(AppConstants.tCustomerSavings)
        .insert(data)
        .select('*, customers(*), savings_schemes(*)')
        .single();
    return CustomerSavings.fromJson(res);
  }

  Future<CustomerSavings> update(String id, Map<String, dynamic> data) async {
    final res = await _db
        .from(AppConstants.tCustomerSavings)
        .update(data)
        .eq('id', id)
        .select('*, customers(*), savings_schemes(*)')
        .single();
    return CustomerSavings.fromJson(res);
  }

  Future<SavingsPayment> addPayment(Map<String, dynamic> data) async {
    final res = await _db
        .from(AppConstants.tSavingsPayments)
        .insert(data)
        .select()
        .single();
    return SavingsPayment.fromJson(res);
  }

  Future<List<SavingsPayment>> fetchPayments(String customerSavingsId) async {
    final res = await _db
        .from(AppConstants.tSavingsPayments)
        .select()
        .eq('customer_savings_id', customerSavingsId)
        .order('payment_date', ascending: false);
    return (res as List).map((e) => SavingsPayment.fromJson(e)).toList();
  }
}

// ── Jewelry Repository ───────────────────────────────────────
class JewelryRepository {
  final _db = SupabaseService.client;

  Future<List<Jewelry>> fetchAll({String? customerId, String? status}) async {
    var query = _db
        .from(AppConstants.tJewelry)
        .select('*, customers(*), jewelry_renewals(*)');
    if (customerId != null) query = query.eq('customer_id', customerId);
    if (status != null) query = query.eq('status', status);
    final res = await query.order('pledge_date', ascending: false);
    return (res as List).map((e) => Jewelry.fromJson(e)).toList();
  }

  Future<Jewelry> create(Map<String, dynamic> data) async {
    final res = await _db
        .from(AppConstants.tJewelry)
        .insert(data)
        .select('*, customers(*), jewelry_renewals(*)')
        .single();
    return Jewelry.fromJson(res);
  }

  Future<Jewelry> update(String id, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    final res = await _db
        .from(AppConstants.tJewelry)
        .update(data)
        .eq('id', id)
        .select('*, customers(*), jewelry_renewals(*)')
        .single();
    return Jewelry.fromJson(res);
  }

  Future<void> addRenewal(Map<String, dynamic> data) async {
    await _db.from('jewelry_renewals').insert(data);
  }

  Future<void> delete(String id) =>
      _db.from(AppConstants.tJewelry).delete().eq('id', id);
}
