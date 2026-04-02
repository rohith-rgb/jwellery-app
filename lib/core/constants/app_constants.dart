class AppConstants {
  // Supabase — replace with your actual project values
  static const String supabaseUrl = 'https://vfqnianvxywrmihogjod.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmcW5pYW52eHl3cm1paG9nam9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5NjcxNDMsImV4cCI6MjA5MDU0MzE0M30.iIuBf7cxvjGjki4KwslANslWVEwPF9ic11FfvNXBRr4';

  // Table names
  static const String tCustomers = 'customers';
  static const String tLoanTypes = 'loan_types';
  static const String tLoans = 'loans';
  static const String tSavingsSchemes = 'savings_schemes';
  static const String tCustomerSavings = 'customer_savings';
  static const String tSavingsPayments = 'savings_payments';
  static const String tJewelry = 'jewelry';
  static const String tSchemeLinks = 'customer_scheme_links';

  // Loan statuses
  static const String loanActive = 'active';
  static const String loanClosed = 'closed';
  static const String loanDefaulted = 'defaulted';

  // Savings statuses
  static const String savingsActive = 'active';
  static const String savingsCompleted = 'completed';
  static const String savingsWithdrawn = 'withdrawn';

  // Jewelry statuses
  static const String jewelryPledged = 'pledged';
  static const String jewelryRepledged = 'repledged';
  static const String jewelryRedeemed = 'redeemed';

  // Frequencies
  static const List<String> frequencies = ['daily', 'weekly', 'monthly'];

  // Scheme types
  static const String schemeTypeLoan = 'loan';
  static const String schemeTypeSavings = 'savings';
  static const String schemeTypeJewelry = 'jewelry';
}
