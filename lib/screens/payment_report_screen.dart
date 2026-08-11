import 'package:flutter/material.dart';

import '../models/sale.dart';
import '../services/sales_history_service.dart';

class PaymentReportScreen extends StatefulWidget {
  const PaymentReportScreen({super.key});

  @override
  State<PaymentReportScreen> createState() => _PaymentReportScreenState();
}

class _PaymentReportScreenState extends State<PaymentReportScreen> {
  List<Sale> sales = [];

  bool isLoading = true;

  double totalRevenue = 0;
  int totalTransactions = 0;
  double averageTransaction = 0;

  Map<String, double> paymentTotals = {};
  Map<String, int> paymentCounts = {};

  @override
  void initState() {
    super.initState();
    loadPaymentReport();
  }

  Future<void> loadPaymentReport() async {
    try {
      final loadedSales = await SalesHistoryService.getSales();

      double revenue = 0;

      final Map<String, double> totals = {};
      final Map<String, int> counts = {};

      for (final sale in loadedSales) {
        revenue += sale.total;

        final method = sale.paymentMethod.trim().isEmpty
            ? "Other"
            : sale.paymentMethod.trim();

        totals[method] = (totals[method] ?? 0) + sale.total;
        counts[method] = (counts[method] ?? 0) + 1;
      }

      if (!mounted) return;

      setState(() {
        sales = loadedSales;

        totalRevenue = revenue;
        totalTransactions = loadedSales.length;

        averageTransaction =
            loadedSales.isEmpty ? 0 : revenue / loadedSales.length;

        paymentTotals = totals;
        paymentCounts = counts;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error loading payment report: $e",
          ),
        ),
      );
    }
  }

  Widget buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData paymentIcon(String method) {
    final type = method.toLowerCase();

    if (type.contains("cash")) {
      return Icons.money;
    }

    if (type.contains("card")) {
      return Icons.credit_card;
    }

    if (type.contains("eft") ||
        type.contains("bank") ||
        type.contains("transfer")) {
      return Icons.account_balance;
    }

    if (type.contains("mobile") ||
        type.contains("wallet") ||
        type.contains("online")) {
      return Icons.phone_android;
    }

    return Icons.payments;
  }

  Color paymentColor(String method) {
    final type = method.toLowerCase();

    if (type.contains("cash")) {
      return Colors.green;
    }

    if (type.contains("card")) {
      return Colors.blue;
    }

    if (type.contains("eft") ||
        type.contains("bank") ||
        type.contains("transfer")) {
      return Colors.orange;
    }

    if (type.contains("mobile") ||
        type.contains("wallet") ||
        type.contains("online")) {
      return Colors.purple;
    }

    return Colors.grey;
  }

  Widget buildPaymentCard(String method) {
    final total = paymentTotals[method] ?? 0;
    final count = paymentCounts[method] ?? 0;

    final color = paymentColor(method);
    final icon = paymentIcon(method);

    final percentage = totalRevenue > 0 ? (total / totalRevenue) * 100 : 0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    method,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "R${total.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "$count transaction${count == 1 ? '' : 's'}",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 7,
              borderRadius: BorderRadius.circular(10),
              color: color,
              backgroundColor: color.withOpacity(0.10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final methods = paymentTotals.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment Report",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadPaymentReport,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadPaymentReport,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Payment Overview",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Analyze your sales by payment method.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      buildSummaryCard(
                        "Revenue",
                        "R${totalRevenue.toStringAsFixed(2)}",
                        Icons.payments,
                        Colors.green,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Transactions",
                        totalTransactions.toString(),
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      buildSummaryCard(
                        "Average Sale",
                        "R${averageTransaction.toStringAsFixed(2)}",
                        Icons.analytics,
                        Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Methods",
                        methods.length.toString(),
                        Icons.account_balance_wallet,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Payment Methods",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (methods.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.payments_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No payment transactions yet.",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...methods.map(buildPaymentCard),
                ],
              ),
            ),
    );
  }
}
