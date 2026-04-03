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
          address: address ?? this.address);

  @override
  List<Object?> get props => [id, name, phone, aadhaar];
}

// ── Loan Type ────────────────────────────────────────────────
class LoanType extends Equatable {
  final String id;
  final String name;
  final double interestRate;
  final int durationMonths;

  const LoanType(
      {required this.id,
      required this.name,
      required this.interestRate,
      required this.durationMonths});

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
// Interest rule: 1.5% for first 6 months, 2% after 6 months
class Jewelry extends Equatable {
  final String id;
  final String customerId;
  final String? description;
  final String? itemType; // e.g. necklace, bangle, ring
  final int? quantity;
  final double weightGrams;
  final double valueAmount;
  final DateTime pledgeDate;
  final String status;
  final double interestRatePhase1; // default 1.5% first 6 months
  final double interestRatePhase2; // default 2.0% after 6 months
  final String? imageUrl;

  // Re-pledge / renewal history
  final String? repledgeBank;
  final DateTime? repledgeDate;
  final double? repledgeAmount;
  final String? repledgeRef;
  final List<JewelryRenewal> renewals;

  final String? notes;
  final Customer? customer;

  const Jewelry({
    required this.id,
    required this.customerId,
    this.description,
    this.itemType,
    this.quantity,
    required this.weightGrams,
    required this.valueAmount,
    required this.pledgeDate,
    required this.status,
    this.interestRatePhase1 = 1.5,
    this.interestRatePhase2 = 2.0,
    this.imageUrl,
    this.repledgeBank,
    this.repledgeDate,
    this.repledgeAmount,
    this.repledgeRef,
    this.renewals = const [],
    this.notes,
    this.customer,
  });

  factory Jewelry.fromJson(Map<String, dynamic> j) => Jewelry(
        id: j['id'],
        customerId: j['customer_id'],
        description: j['description'],
        itemType: j['item_type'],
        quantity: j['quantity'],
        weightGrams: (j['weight_grams'] as num).toDouble(),
        valueAmount: (j['value_amount'] as num).toDouble(),
        pledgeDate: DateTime.parse(j['pledge_date']),
        status: j['status'] ?? 'pledged',
        interestRatePhase1: j['interest_rate_phase1'] != null
            ? (j['interest_rate_phase1'] as num).toDouble()
            : 1.5,
        interestRatePhase2: j['interest_rate_phase2'] != null
            ? (j['interest_rate_phase2'] as num).toDouble()
            : 2.0,
        imageUrl: j['image_url'],
        repledgeBank: j['repledge_bank'],
        repledgeDate: j['repledge_date'] != null
            ? DateTime.parse(j['repledge_date'])
            : null,
        repledgeAmount: j['repledge_amount'] != null
            ? (j['repledge_amount'] as num).toDouble()
            : null,
        repledgeRef: j['repledge_ref'],
        renewals: j['jewelry_renewals'] != null
            ? (j['jewelry_renewals'] as List)
                .map((r) => JewelryRenewal.fromJson(r))
                .toList()
            : [],
        notes: j['notes'],
        customer:
            j['customers'] != null ? Customer.fromJson(j['customers']) : null,
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'description': description,
        'item_type': itemType,
        'quantity': quantity,
        'weight_grams': weightGrams,
        'value_amount': valueAmount,
        'pledge_date': pledgeDate.toIso8601String().split('T').first,
        'status': status,
        'interest_rate_phase1': interestRatePhase1,
        'interest_rate_phase2': interestRatePhase2,
        'image_url': imageUrl,
        'repledge_bank': repledgeBank,
        'repledge_date': repledgeDate?.toIso8601String().split('T').first,
        'repledge_amount': repledgeAmount,
        'repledge_ref': repledgeRef,
        'notes': notes,
      };

  bool get isRepledged => status == 'repledged';

  // Days held from pledge date to today (or custom date)
  int daysHeld({DateTime? upTo}) {
    final end = upTo ?? DateTime.now();
    return end.difference(pledgeDate).inDays;
  }

  // Months held
  double monthsHeld({DateTime? upTo}) => daysHeld(upTo: upTo) / 30.0;

  // Has crossed 6-month threshold
  bool get isPastSixMonths => monthsHeld() >= 6;

  // Days until 6-month mark (negative means already past)
  int get daysUntilSixMonths {
    final sixMonth =
        DateTime(pledgeDate.year, pledgeDate.month + 6, pledgeDate.day);
    return sixMonth.difference(DateTime.now()).inDays;
  }

  // Is approaching 6 months (within 7 days)
  bool get isApproachingSixMonths =>
      daysUntilSixMonths >= 0 && daysUntilSixMonths <= 7;

  // ── Interest calculation ─────────────────────────────────
  // Phase 1: first 6 months at interestRatePhase1 (1.5%)
  // Phase 2: months beyond 6 at interestRatePhase2 (2.0%)
  // Interest = principal × rate/100 × months/12
  JewelryInterestCalc calculateInterest({DateTime? upTo}) {
    final totalMonths = monthsHeld(upTo: upTo);
    final days = daysHeld(upTo: upTo);

    if (totalMonths <= 6) {
      // Only phase 1
      final interest =
          valueAmount * (interestRatePhase1 / 100) * (totalMonths / 12) * 12;
      // Simpler: monthly interest = principal × rate% per month
      final phase1Interest =
          valueAmount * (interestRatePhase1 / 100) * totalMonths;
      return JewelryInterestCalc(
        principal: valueAmount,
        phase1Months: totalMonths,
        phase2Months: 0,
        phase1Rate: interestRatePhase1,
        phase2Rate: interestRatePhase2,
        phase1Interest: phase1Interest,
        phase2Interest: 0,
        totalInterest: phase1Interest,
        totalAmount: valueAmount + phase1Interest,
        daysHeld: days,
      );
    } else {
      // Phase 1 for first 6 months + Phase 2 for remaining
      final phase1Interest = valueAmount * (interestRatePhase1 / 100) * 6;
      final phase2Months = totalMonths - 6;
      final phase2Interest =
          valueAmount * (interestRatePhase2 / 100) * phase2Months;
      final total = phase1Interest + phase2Interest;
      return JewelryInterestCalc(
        principal: valueAmount,
        phase1Months: 6,
        phase2Months: phase2Months,
        phase1Rate: interestRatePhase1,
        phase2Rate: interestRatePhase2,
        phase1Interest: phase1Interest,
        phase2Interest: phase2Interest,
        totalInterest: total,
        totalAmount: valueAmount + total,
        daysHeld: days,
      );
    }
  }

  @override
  List<Object?> get props => [id, customerId, weightGrams, status];
}

// ── Interest calculation result ───────────────────────────────
class JewelryInterestCalc {
  final double principal;
  final double phase1Months;
  final double phase2Months;
  final double phase1Rate;
  final double phase2Rate;
  final double phase1Interest;
  final double phase2Interest;
  final double totalInterest;
  final double totalAmount;
  final int daysHeld;

  const JewelryInterestCalc({
    required this.principal,
    required this.phase1Months,
    required this.phase2Months,
    required this.phase1Rate,
    required this.phase2Rate,
    required this.phase1Interest,
    required this.phase2Interest,
    required this.totalInterest,
    required this.totalAmount,
    required this.daysHeld,
  });
}

// ── Jewelry Renewal (replacement history) ────────────────────
class JewelryRenewal extends Equatable {
  final String id;
  final String jewelryId;
  final String fromBank;
  final String toBank;
  final String? loanNumber;
  final double loanAmount;
  final double interestPaid;
  final DateTime renewalDate;
  final String? notes;

  const JewelryRenewal({
    required this.id,
    required this.jewelryId,
    required this.fromBank,
    required this.toBank,
    this.loanNumber,
    required this.loanAmount,
    required this.interestPaid,
    required this.renewalDate,
    this.notes,
  });

  factory JewelryRenewal.fromJson(Map<String, dynamic> j) => JewelryRenewal(
        id: j['id'],
        jewelryId: j['jewelry_id'],
        fromBank: j['from_bank'] ?? '',
        toBank: j['to_bank'] ?? '',
        loanNumber: j['loan_number'],
        loanAmount: (j['loan_amount'] as num).toDouble(),
        interestPaid: (j['interest_paid'] as num).toDouble(),
        renewalDate: DateTime.parse(j['renewal_date']),
        notes: j['notes'],
      );

  Map<String, dynamic> toJson() => {
        'jewelry_id': jewelryId,
        'from_bank': fromBank,
        'to_bank': toBank,
        'loan_number': loanNumber,
        'loan_amount': loanAmount,
        'interest_paid': interestPaid,
        'renewal_date': renewalDate.toIso8601String().split('T').first,
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, jewelryId, renewalDate];
}
