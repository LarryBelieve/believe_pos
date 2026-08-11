import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class ProfitReportScreen extends StatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  State<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends State<ProfitReportScreen> {
  bool isLoading = true;

  double todayRevenue = 0;
  double todayCost = 0;
  double todayProfit = 0;

  double weekRevenue = 0;
  double weekCost = 0;
  double weekProfit = 0;

  double monthRevenue = 0;
  double monthCost = 0;
  double monthProfit = 0;

  @override
  void initState() {
    super.initState();
    loadProfitReport();
  }

  Future<void> loadProfitReport() async {
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

      final weekStart = todayStart.subtract(
        Duration(days: todayStart.weekday - 1),
      );

      final monthStart = DateTime(
        now.year,
        now.month,
        1,
      );

      // =========================
      // TODAY
      // =========================

      final todayResult = await db.rawQuery(
        '''
        SELECT
          COALESCE(SUM(si.quantity * si.price), 0) AS revenue,
          COALESCE(
            SUM(
              si.quantity *
              COALESCE(p.costPrice, 0)
            ),
            0
          ) AS cost
        FROM sale_items si
        INNER JOIN sales s
          ON si.saleId = s.id
        INNER JOIN products p
          ON si.productId = p.id
        WHERE s.saleDate >= ?
        AND s.saleDate < ?
        ''',
        [
          todayStart.toIso8601String(),
          tomorrowStart.toIso8601String(),
        ],
      );

      // =========================
      // THIS WEEK
      // =========================

      final weekResult = await db.rawQuery(
        '''
        SELECT
          COALESCE(SUM(si.quantity * si.price), 0) AS revenue,
          COALESCE(
            SUM(
              si.quantity *
              COALESCE(p.costPrice, 0)
            ),
            0
          ) AS cost
        FROM sale_items si
        INNER JOIN sales s
          ON si.saleId = s.id
        INNER JOIN products p
          ON si.productId = p.id
        WHERE s.saleDate >= ?
        AND s.saleDate < ?
        ''',
        [
          weekStart.toIso8601String(),
          tomorrowStart.toIso8601String(),
        ],
      );

      // =========================
      // THIS MONTH
      // =========================

      final monthResult = await db.rawQuery(
        '''
        SELECT
          COALESCE(SUM(si.quantity * si.price), 0) AS revenue,
          COALESCE(
            SUM(
              si.quantity *
              COALESCE(p.costPrice, 0)
            ),
            0
          ) AS cost
        FROM sale_items si
        INNER JOIN sales s
          ON si.saleId = s.id
        INNER JOIN products p
          ON si.productId = p.id
        WHERE s.saleDate >= ?
        AND s.saleDate < ?
        ''',
        [
          monthStart.toIso8601String(),
          tomorrowStart.toIso8601String(),
        ],
      );

      final todayRevenueValue =
          (todayResult.first['revenue'] as num).toDouble();

      final todayCostValue = (todayResult.first['cost'] as num).toDouble();

      final weekRevenueValue = (weekResult.first['revenue'] as num).toDouble();

      final weekCostValue = (weekResult.first['cost'] as num).toDouble();

      final monthRevenueValue =
          (monthResult.first['revenue'] as num).toDouble();

      final monthCostValue = (monthResult.first['cost'] as num).toDouble();

      if (!mounted) return;

      setState(() {
        todayRevenue = todayRevenueValue;
        todayCost = todayCostValue;
        todayProfit = todayRevenueValue - todayCostValue;

        weekRevenue = weekRevenueValue;
        weekCost = weekCostValue;
        weekProfit = weekRevenueValue - weekCostValue;

        monthRevenue = monthRevenueValue;
        monthCost = monthCostValue;
        monthProfit = monthRevenueValue - monthCostValue;

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
            "Error loading profit report: $e",
          ),
        ),
      );
    }
  }

  double calculateMargin(
    double revenue,
    double profit,
  ) {
    if (revenue <= 0) {
      return 0;
    }

    return (profit / revenue) * 100;
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

  Widget buildPeriodCard(
    String title,
    double revenue,
    double cost,
    double profit,
  ) {
    final margin = calculateMargin(
      revenue,
      profit,
    );

    final profitColor = profit >= 0 ? Colors.green : Colors.red;

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
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Revenue",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "R${revenue.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Cost",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "R${cost.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gross Profit",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "R${profit.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: profitColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: profitColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Margin",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${margin.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: profitColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profit Report",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadProfitReport,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadProfitReport,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Profit Overview",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Track revenue, product costs and gross profit.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TODAY SUMMARY
                  Row(
                    children: [
                      buildSummaryCard(
                        "Today's Profit",
                        "R${todayProfit.toStringAsFixed(2)}",
                        Icons.trending_up,
                        todayProfit >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Today's Cost",
                        "R${todayCost.toStringAsFixed(2)}",
                        Icons.shopping_cart,
                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  buildPeriodCard(
                    "Today",
                    todayRevenue,
                    todayCost,
                    todayProfit,
                  ),

                  buildPeriodCard(
                    "This Week",
                    weekRevenue,
                    weekCost,
                    weekProfit,
                  ),

                  buildPeriodCard(
                    "This Month",
                    monthRevenue,
                    monthCost,
                    monthProfit,
                  ),
                ],
              ),
            ),
    );
  }
}
