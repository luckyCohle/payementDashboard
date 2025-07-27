// models/payment_stats.dart

class PaymentStats {
  final int totalTransactions;
  final int failedTransactions;
  final double totalRevenue;
  final List<DailyRevenue> recentRevenue;

  PaymentStats({
    required this.totalTransactions,
    required this.failedTransactions,
    required this.totalRevenue,
    required this.recentRevenue,
  });

  factory PaymentStats.fromJson(Map<String, dynamic> json) {
    return PaymentStats(
      totalTransactions: json['totalTransactions'],
      failedTransactions: json['failedTransactions'],
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      recentRevenue: (json['recentRevenue'] as List)
          .map((e) => DailyRevenue.fromJson(e))
          .toList(),
    );
  }
}

class DailyRevenue {
  final String date;
  final double amount;

  DailyRevenue({required this.date, required this.amount});

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: json['date'],
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
