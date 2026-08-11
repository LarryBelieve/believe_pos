import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  bool isLoading = true;

  double todaySales = 0;
  double yesterdaySales = 0;
  double weekSales = 0;
  double monthSales = 0;

  int todayTransactions = 0;
  int yesterdayTransactions = 0;
  int weekTransactions = 0;
  int monthTransactions = 0;

  DateTime? customStartDate;
  DateTime? customEndDate;

  double customSales = 0;
  int customTransactions = 0;
  double customAverageSale = 0;

  bool isCustomLoading = false;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  // ============================================================
  // LOAD SALES REPORT
  // ============================================================

  Future<void> loadReport() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final now = DateTime.now();

      final todayStart = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final tomorrowStart = todayStart.add(
        const Duration(days: 1),
      );

      final yesterdayStart = todayStart.subtract(
        const Duration(days: 1),
      );

      final weekStart = todayStart.subtract(
        Duration(days: todayStart.weekday - 1),
      );

      final monthStart = DateTime(
        now.year,
        now.month,
        1,
      );

      // ========================================================
      // TODAY
      // ========================================================

      final todayResult = await db.rawQuery(
        '''
        SELECT
          COALESCE(SUM(total), 0) AS totalSales,
          COUNT(*) AS transactions
        FROM sales
        WHERE saleDate >= ?
        AND saleDate < ?
        ''',
        [
          todayStart.toIso8601String(),
          tomorrowStart.toIso8601String(),
        ],
      );

      // ========================================================
      // YESTERDAY
      // ========================================================

      final yesterdayResult = await db.rawQuery(
        '''
        SELECT
          COALESCE(SUM(total), 0) AS totalSales,
          COUNT(*) AS transactions
        FROM sales
        WHERE saleDate >= ?
        AND saleDate < ?
        ''',
        [
          yesterdayStart.toIso8601String(),
          todayStart.toIso8601String(),
        ],
      );

      // ========================================================
      // THIS WEEK
      // ========================================================

      final weekResult = await db.rawQuery(
        '''
        SELECT
          COALESCE(SUM(total), 0) AS totalSales,
          COUNT(*) AS transactions
        FROM sales
        WHERE saleDate >= ?
        AND saleDate < ?
        ''',
        [
          weekStart.toIso8601String(),
          tomorrowStart.toIso8601String(),
        ],
      );

      // ========================================================
      // THIS MONTH
      // ========================================================

      final monthResult = await db.rawQuery(
        '''
        SELECT
          COALESCE(SUM(total), 0) AS totalSales,
          COUNT(*) AS transactions
        FROM sales
        WHERE saleDate >= ?
        AND saleDate < ?
        ''',
        [
          monthStart.toIso8601String(),
          tomorrowStart.toIso8601String(),
        ],
      );

      if (!mounted) return;

      setState(() {
        todaySales = (todayResult.first['totalSales'] as num).toDouble();

        todayTransactions = (todayResult.first['transactions'] as num).toInt();

        yesterdaySales =
            (yesterdayResult.first['totalSales'] as num).toDouble();

        yesterdayTransactions =
            (yesterdayResult.first['transactions'] as num).toInt();

        weekSales = (weekResult.first['totalSales'] as num).toDouble();

        weekTransactions = (weekResult.first['transactions'] as num).toInt();

        monthSales = (monthResult.first['totalSales'] as num).toDouble();

        monthTransactions = (monthResult.first['transactions'] as num).toInt();

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
            "Error loading sales report: $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // SELECT CUSTOM DATE RANGE
  // ============================================================

  Future<void> selectCustomDateRange() async {
    final now = DateTime.now();

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: customStartDate != null && customEndDate != null
          ? DateTimeRange(
              start: customStartDate!,
              end: customEndDate!,
            )
          : DateTimeRange(
              start: DateTime(
                now.year,
                now.month,
                now.day,
              ),
              end: DateTime(
                now.year,
                now.month,
                now.day,
              ),
            ),
    );

    if (pickedRange == null) return;

    setState(() {
      customStartDate = pickedRange.start;
      customEndDate = pickedRange.end;
      isCustomLoading = true;
    });

    await loadCustomReport(
      pickedRange.start,
      pickedRange.end,
    );
  }

  // ============================================================
  // LOAD CUSTOM REPORT
  // ============================================================

  Future<void> loadCustomReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final start = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      final end = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      ).add(
        const Duration(days: 1),
      );

      final result = await db.rawQuery(
        '''
        SELECT
          COALESCE(SUM(total), 0) AS totalSales,
          COUNT(*) AS transactions,
          COALESCE(AVG(total), 0) AS averageSale
        FROM sales
        WHERE saleDate >= ?
        AND saleDate < ?
        ''',
        [
          start.toIso8601String(),
          end.toIso8601String(),
        ],
      );

      if (!mounted) return;

      setState(() {
        customSales = (result.first['totalSales'] as num).toDouble();

        customTransactions = (result.first['transactions'] as num).toInt();

        customAverageSale = (result.first['averageSale'] as num).toDouble();

        isCustomLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCustomLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error loading custom report: $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return "$day/$month/$year";
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

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
                  fontSize: 20,
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

  // ============================================================
  // SALES CARD
  // ============================================================

  Widget buildSalesCard(
    String title,
    double sales,
    int transactions,
    Color color,
  ) {
    final double average = transactions > 0 ? sales / transactions : 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(
                  Icons.payments,
                  color: color,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  "R${sales.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  "$transactions transaction"
                  "${transactions == 1 ? '' : 's'}",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.analytics,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  "Average: R${average.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CUSTOM REPORT
  // ============================================================

  Widget buildCustomReport() {
    if (customStartDate == null || customEndDate == null) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.date_range,
                size: 50,
                color: Colors.grey,
              ),
              const SizedBox(height: 10),
              const Text(
                "Select a date range",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose the dates you want to analyze.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: selectCustomDateRange,
                icon: const Icon(
                  Icons.calendar_month,
                ),
                label: const Text(
                  "Choose Dates",
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Custom Date Range",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${formatDate(customStartDate!)}"
                    " - "
                    "${formatDate(customEndDate!)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: selectCustomDateRange,
                  icon: const Icon(
                    Icons.edit_calendar,
                  ),
                  tooltip: "Change dates",
                ),
              ],
            ),
            const Divider(
              height: 24,
            ),
            if (isCustomLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Sales",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "R${customSales.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Transactions",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          customTransactions.toString(),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Average Sale",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "R${customAverageSale.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sales Report",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadReport,
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
              onRefresh: loadReport,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Sales Overview",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Monitor your sales performance.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // TODAY SUMMARY
                  // ==================================================

                  Row(
                    children: [
                      buildSummaryCard(
                        "Today's Sales",
                        "R${todaySales.toStringAsFixed(2)}",
                        Icons.today,
                        Colors.green,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Transactions",
                        todayTransactions.toString(),
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // WEEK SUMMARY
                  // ==================================================

                  Row(
                    children: [
                      buildSummaryCard(
                        "This Week",
                        "R${weekSales.toStringAsFixed(2)}",
                        Icons.date_range,
                        Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Transactions",
                        weekTransactions.toString(),
                        Icons.receipt,
                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // SALES BREAKDOWN
                  // ==================================================

                  buildSalesCard(
                    "Today",
                    todaySales,
                    todayTransactions,
                    Colors.green,
                  ),

                  buildSalesCard(
                    "Yesterday",
                    yesterdaySales,
                    yesterdayTransactions,
                    Colors.blue,
                  ),

                  buildSalesCard(
                    "This Week",
                    weekSales,
                    weekTransactions,
                    Colors.orange,
                  ),

                  buildSalesCard(
                    "This Month",
                    monthSales,
                    monthTransactions,
                    Colors.purple,
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // CUSTOM REPORT
                  // ==================================================

                  const Text(
                    "Custom Report",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  buildCustomReport(),
                ],
              ),
            ),
    );
  }
}
