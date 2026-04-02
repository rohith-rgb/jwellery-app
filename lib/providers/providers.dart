import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/repositories/repositories.dart';

// ── Auth Provider ────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();
  bool _loading = false;
  String? _error;
  bool _isLoggedIn = false;

  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _repo.signIn(email, password);
      _isLoggedIn = res.user != null;
      _loading = false;
      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _isLoggedIn = false;
    notifyListeners();
  }

  void checkSession() {
    _isLoggedIn = _repo.authStateChanges != null;
  }
}

// ── Generic async state helper ───────────────────────────────
enum LoadState { idle, loading, success, error }

// ── Customer Provider ────────────────────────────────────────
class CustomerProvider extends ChangeNotifier {
  final _repo = CustomerRepository();

  List<Customer> _customers = [];
  List<Customer> _filtered = [];
  Customer? _selected;
  LoadState _state = LoadState.idle;
  String? _error;

  List<Customer> get customers =>
      _filtered.isNotEmpty || _searchQuery.isNotEmpty ? _filtered : _customers;
  Customer? get selected => _selected;
  LoadState get state => _state;
  String? get error => _error;
  String _searchQuery = '';

  Future<void> loadAll() async {
    _state = LoadState.loading;
    notifyListeners();
    try {
      _customers = await _repo.fetchAll();
      _filtered = [];
      _state = LoadState.success;
    } catch (e) {
      _error = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }

  void search(String q) {
    _searchQuery = q;
    if (q.isEmpty) {
      _filtered = [];
      notifyListeners();
      return;
    }
    _filtered = _customers
        .where((c) =>
            c.name.toLowerCase().contains(q.toLowerCase()) ||
            c.phone.contains(q) ||
            c.aadhaar.contains(q))
        .toList();
    notifyListeners();
  }

  void select(Customer c) {
    _selected = c;
    notifyListeners();
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      final c = await _repo.create(data);
      _customers.insert(0, c);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try {
      final c = await _repo.update(id, data);
      final idx = _customers.indexWhere((x) => x.id == id);
      if (idx >= 0) _customers[idx] = c;
      if (_selected?.id == id) _selected = c;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repo.delete(id);
      _customers.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

// ── Loan Provider ────────────────────────────────────────────
class LoanProvider extends ChangeNotifier {
  final _loanRepo = LoanRepository();
  final _typeRepo = LoanTypeRepository();

  List<Loan> _loans = [];
  List<LoanType> _loanTypes = [];
  LoadState _state = LoadState.idle;
  String? _error;
  String? _filterStatus;

  List<Loan> get loans => _filterStatus == null
      ? _loans
      : _loans.where((l) => l.status == _filterStatus).toList();
  List<LoanType> get loanTypes => _loanTypes;
  LoadState get state => _state;
  String? get error => _error;

  Future<void> loadAll({String? customerId}) async {
    _state = LoadState.loading;
    notifyListeners();
    try {
      _loans = await _loanRepo.fetchAll(customerId: customerId);
      _loanTypes = await _typeRepo.fetchAll();
      _state = LoadState.success;
    } catch (e) {
      _error = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }

  void setFilter(String? status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<bool> createLoan(Map<String, dynamic> data) async {
    try {
      final l = await _loanRepo.create(data);
      _loans.insert(0, l);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLoanStatus(String id, String status) async {
    try {
      final l = await _loanRepo.update(id, {'status': status});
      final idx = _loans.indexWhere((x) => x.id == id);
      if (idx >= 0) _loans[idx] = l;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createLoanType(Map<String, dynamic> data) async {
    try {
      final t = await _typeRepo.create(data);
      _loanTypes.add(t);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

// ── Savings Provider ─────────────────────────────────────────
class SavingsProvider extends ChangeNotifier {
  final _schemeRepo = SavingsSchemeRepository();
  final _savingsRepo = CustomerSavingsRepository();

  List<SavingsScheme> _schemes = [];
  List<CustomerSavings> _savings = [];
  LoadState _state = LoadState.idle;
  String? _error;

  List<SavingsScheme> get schemes => _schemes;
  List<CustomerSavings> get savings => _savings;
  LoadState get state => _state;
  String? get error => _error;

  Future<void> loadAll({String? customerId}) async {
    _state = LoadState.loading;
    notifyListeners();
    try {
      _schemes = await _schemeRepo.fetchAll();
      _savings = await _savingsRepo.fetchAll(customerId: customerId);
      _state = LoadState.success;
    } catch (e) {
      _error = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<bool> createScheme(Map<String, dynamic> data) async {
    try {
      final s = await _schemeRepo.create(data);
      _schemes.add(s);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> enrollCustomer(Map<String, dynamic> data) async {
    try {
      final s = await _savingsRepo.create(data);
      _savings.insert(0, s);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addPayment(Map<String, dynamic> data) async {
    try {
      await _savingsRepo.addPayment(data);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

// ── Jewelry Provider ─────────────────────────────────────────
class JewelryProvider extends ChangeNotifier {
  final _repo = JewelryRepository();

  List<Jewelry> _items = [];
  LoadState _state = LoadState.idle;
  String? _error;
  String? _filterStatus;

  List<Jewelry> get items => _filterStatus == null
      ? _items
      : _items.where((j) => j.status == _filterStatus).toList();
  LoadState get state => _state;
  String? get error => _error;

  Future<void> loadAll({String? customerId, String? status}) async {
    _state = LoadState.loading;
    notifyListeners();
    try {
      _items = await _repo.fetchAll(customerId: customerId, status: status);
      _state = LoadState.success;
    } catch (e) {
      _error = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }

  void setFilter(String? status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      final j = await _repo.create(data);
      _items.insert(0, j);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> repledge(
    String id, {
    required String bank,
    required DateTime date,
    required double amount,
    String? ref,
  }) async {
    try {
      final j = await _repo.update(id, {
        'status': 'repledged',
        'repledge_bank': bank,
        'repledge_date': date.toIso8601String().split('T').first,
        'repledge_amount': amount,
        'repledge_ref': ref,
      });
      final idx = _items.indexWhere((x) => x.id == id);
      if (idx >= 0) _items[idx] = j;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> redeem(String id) async {
    try {
      final j = await _repo.update(id, {'status': 'redeemed'});
      final idx = _items.indexWhere((x) => x.id == id);
      if (idx >= 0) _items[idx] = j;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repo.delete(id);
      _items.removeWhere((j) => j.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

// ── Dashboard Stats Provider ──────────────────────────────────
class DashboardProvider extends ChangeNotifier {
  final _customerRepo = CustomerRepository();
  final _loanRepo = LoanRepository();
  final _savingsRepo = CustomerSavingsRepository();
  final _jewelryRepo = JewelryRepository();

  int _totalCustomers = 0;
  int _activeLoans = 0;
  int _activeSavings = 0;
  int _pledgedJewelry = 0;
  double _totalLoanAmount = 0;
  LoadState _state = LoadState.idle;

  int get totalCustomers => _totalCustomers;
  int get activeLoans => _activeLoans;
  int get activeSavings => _activeSavings;
  int get pledgedJewelry => _pledgedJewelry;
  double get totalLoanAmount => _totalLoanAmount;
  LoadState get state => _state;

  Future<void> load() async {
    _state = LoadState.loading;
    notifyListeners();
    try {
      final customers = await _customerRepo.fetchAll();
      final loans = await _loanRepo.fetchAll(status: 'active');
      final savings = await _savingsRepo.fetchAll();
      final jewelry = await _jewelryRepo.fetchAll(status: 'pledged');

      _totalCustomers = customers.length;
      _activeLoans = loans.length;
      _totalLoanAmount = loans.fold(0, (s, l) => s + l.principal);
      _activeSavings = savings.where((s) => s.status == 'active').length;
      _pledgedJewelry = jewelry.length;
      _state = LoadState.success;
    } catch (e) {
      _state = LoadState.error;
    }
    notifyListeners();
  }
}
