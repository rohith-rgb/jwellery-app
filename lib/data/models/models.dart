import 'package:equatable/equatable.dart';

// ── Customer ─────────────────────────────────────────────────
class Customer extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String aadhaar;
  final String? address;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.aadhaar,
    this.address,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'],
        name: j['name'],
        phone: j['phone'],
        aadhaar: j['aadhaar'],
        address: j['address'],
        createdAt: DateTime.parse(j['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'aadhaar': aadhaar,
        'address': address,
      };

  Customer copyWith(
          {String? name, String? phone, String? aadhaar, String? address}) =>
      Customer(
        id: id,
        createdAt: createdAt,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        aadhaar: aadhaar ?? this.aadhaar,
        address: address ?? this.address,
      );

  @override
  List<Object?> get props => [id, name, phone, aadhaar];
}

// ── Loan Type ────────────────────────────────────────────────
class LoanType extends Equatable {
  final String id;
  final String name;
  final double interestRate;
  final int durationMonths;

  const LoanType({
    required this.id,
    required this.name,
    required this.interestRate,
    required this.durationMonths,
  });

  factory LoanType.fromJson(Map<String, dynamic> j) => LoanType(
        id: j['id'],
        name: j['name'],
        interestRate: (j['interest_rate'] as num).toDouble(),
        durationMonths: j['duration_months'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'interest_rate': interestRate,
        'duration_months': durationMonths,
      };

  @override
  List<Object?> get props => [id, name];
}

// ── Loan ─────────────────────────────────────────────────────
class Loan extends Equatable {
  final String id;
  final String customerId;
  final String? loanTypeId;
  final double principal;
  final double interestRate;
  final int durationMonths;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final String? notes;
  final Customer? customer;
  final LoanType? loanType;

  const Loan({
    required this.id,
    required this.customerId,
    this.loanTypeId,
    required this.principal,
    required this.interestRate,
    required this.durationMonths,
    required this.startDate,
    this.endDate,
    required this.status,
    this.notes,
    this.customer,
    this.loanType,
  });

  factory Loan.fromJson(Map<String, dynamic> j) => Loan(
        id: j['id'],
        customerId: j['customer_id'],
        loanTypeId: j['loan_type_id'],
        principal: (j['principal'] as num).toDouble(),
        interestRate: (j['interest_rate'] as num).toDouble(),
        durationMonths: j['duration_months'],
        startDate: DateTime.parse(j['start_date']),
        endDate: j['end_date'] != null ? DateTime.parse(j['end_date']) : null,
        status: j['status'] ?? 'active',
        notes: j['notes'],
        customer:
            j['customers'] != null ? Customer.fromJson(j['customers']) : null,
        loanType:
            j['loan_types'] != null ? LoanType.fromJson(j['loan_types']) : null,
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'loan_type_id': loanTypeId,
        'principal': principal,
        'interest_rate': interestRate,
        'duration_months': durationMonths,
        'start_date': startDate.toIso8601String().split('T').first,
        'status': status,
        'notes': notes,
      };

  double get totalInterest =>
      principal * (interestRate / 100) * (durationMonths / 12);
  double get totalPayable => principal + totalInterest;
  double get emiAmount => totalPayable / durationMonths;

  @override
  List<Object?> get props => [id, customerId, principal, status];
}

// ── Savings Scheme ───────────────────────────────────────────
class SavingsScheme extends Equatable {
  final String id;
  final String name;
  final String frequency;
  final double interestRate;
  final int durationMonths;
  final double amountPerPeriod;

  const SavingsScheme({
    required this.id,
    required this.name,
    required this.frequency,
    required this.interestRate,
    required this.durationMonths,
    required this.amountPerPeriod,
  });

  factory SavingsScheme.fromJson(Map<String, dynamic> j) => SavingsScheme(
        id: j['id'],
        name: j['name'],
        frequency: j['frequency'],
        interestRate: (j['interest_rate'] as num).toDouble(),
        durationMonths: j['duration_months'],
        amountPerPeriod: (j['amount_per_period'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'frequency': frequency,
        'interest_rate': interestRate,
        'duration_months': durationMonths,
        'amount_per_period': amountPerPeriod,
      };

  @override
  List<Object?> get props => [id, name];
}

// ── Customer Savings ─────────────────────────────────────────
class CustomerSavings extends Equatable {
  final String id;
  final String customerId;
  final String? savingsSchemeId;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final String? notes;
  final SavingsScheme? scheme;
  final Customer? customer;
  final List<SavingsPayment> payments;

  const CustomerSavings({
    required this.id,
    required this.customerId,
    this.savingsSchemeId,
    required this.startDate,
    this.endDate,
    required this.status,
    this.notes,
    this.scheme,
    this.customer,
    this.payments = const [],
  });

  factory CustomerSavings.fromJson(Map<String, dynamic> j) => CustomerSavings(
        id: j['id'],
        customerId: j['customer_id'],
        savingsSchemeId: j['savings_scheme_id'],
        startDate: DateTime.parse(j['start_date']),
        endDate: j['end_date'] != null ? DateTime.parse(j['end_date']) : null,
        status: j['status'] ?? 'active',
        notes: j['notes'],
        scheme: j['savings_schemes'] != null
            ? SavingsScheme.fromJson(j['savings_schemes'])
            : null,
        customer:
            j['customers'] != null ? Customer.fromJson(j['customers']) : null,
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'savings_scheme_id': savingsSchemeId,
        'start_date': startDate.toIso8601String().split('T').first,
        'status': status,
        'notes': notes,
      };

  double get totalPaid => payments.fold(0, (s, p) => s + p.amount);

  @override
  List<Object?> get props => [id, customerId, status];
}

// ── Savings Payment ──────────────────────────────────────────
class SavingsPayment extends Equatable {
  final String id;
  final String customerSavingsId;
  final DateTime paymentDate;
  final double amount;

  const SavingsPayment({
    required this.id,
    required this.customerSavingsId,
    required this.paymentDate,
    required this.amount,
  });

  factory SavingsPayment.fromJson(Map<String, dynamic> j) => SavingsPayment(
        id: j['id'],
        customerSavingsId: j['customer_savings_id'],
        paymentDate: DateTime.parse(j['payment_date']),
        amount: (j['amount'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'customer_savings_id': customerSavingsId,
        'payment_date': paymentDate.toIso8601String().split('T').first,
        'amount': amount,
      };

  @override
  List<Object?> get props => [id, customerSavingsId, paymentDate];
}

// ── Jewelry ──────────────────────────────────────────────────
class Jewelry extends Equatable {
  final String id;
  final String customerId;
  final String? description;
  final double weightGrams;
  final double valueAmount;
  final DateTime pledgeDate;
  final String status;
  final String? repledgeBank;
  final DateTime? repledgeDate;
  final double? repledgeAmount;
  final String? repledgeRef;
  final String? notes;
  final Customer? customer;

  const Jewelry({
    required this.id,
    required this.customerId,
    this.description,
    required this.weightGrams,
    required this.valueAmount,
    required this.pledgeDate,
    required this.status,
    this.repledgeBank,
    this.repledgeDate,
    this.repledgeAmount,
    this.repledgeRef,
    this.notes,
    this.customer,
  });

  factory Jewelry.fromJson(Map<String, dynamic> j) => Jewelry(
        id: j['id'],
        customerId: j['customer_id'],
        description: j['description'],
        weightGrams: (j['weight_grams'] as num).toDouble(),
        valueAmount: (j['value_amount'] as num).toDouble(),
        pledgeDate: DateTime.parse(j['pledge_date']),
        status: j['status'] ?? 'pledged',
        repledgeBank: j['repledge_bank'],
        repledgeDate: j['repledge_date'] != null
            ? DateTime.parse(j['repledge_date'])
            : null,
        repledgeAmount: j['repledge_amount'] != null
            ? (j['repledge_amount'] as num).toDouble()
            : null,
        repledgeRef: j['repledge_ref'],
        notes: j['notes'],
        customer:
            j['customers'] != null ? Customer.fromJson(j['customers']) : null,
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'description': description,
        'weight_grams': weightGrams,
        'value_amount': valueAmount,
        'pledge_date': pledgeDate.toIso8601String().split('T').first,
        'status': status,
        'repledge_bank': repledgeBank,
        'repledge_date': repledgeDate?.toIso8601String().split('T').first,
        'repledge_amount': repledgeAmount,
        'repledge_ref': repledgeRef,
        'notes': notes,
      };

  bool get isRepledged => status == 'repledged';

  @override
  List<Object?> get props => [id, customerId, weightGrams, status];
}
