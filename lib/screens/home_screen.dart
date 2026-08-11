import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';
import '../services/product_service.dart';

import 'new_sale_screen.dart';
import 'products_screen.dart';
import 'sales_history_screen.dart';
import 'customers_screen.dart';
import 'suppliers_screen.dart';
import 'receive_stock_screen.dart';
import 'stock_movement_screen.dart';
import 'low_stock_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double todaySales = 0;
  int totalTransactions = 0;
  double averageSale = 0;
  int lowStockCount = 0;

  double todayProfit = 0;
  int totalProducts = 0;
  double totalStockValue = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final sales = await DashboardService.getTodaySales();
      final transactions = await DashboardService.getTotalTransactions();
      final average = await DashboardService.getAverageSale();

      final profit = await DashboardService.getTodayProfit();

      final products = await DashboardService.getTotalProducts();

      final stockValue = await DashboardService.getTotalStockValue();

      final lowStockProducts = await ProductService.getLowStockProducts();

      if (!mounted) return;

      setState(() {
        todaySales = sales;
        totalTransactions = transactions;
        averageSale = average;
        todayProfit = profit;
        totalProducts = products;
        totalStockValue = stockValue;
        lowStockCount = lowStockProducts.length;
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
            "Error loading dashboard: $e",
          ),
        ),
      );
    }
  }

  Widget buildCard(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 55,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard(
    String title,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 20,
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openLowStock() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LowStockScreen(),
      ),
    );

    await loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Believe POS"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // =========================
                  // SALES SUMMARY
                  // =========================

                  const Text(
                    "Today's Overview",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      buildInfoCard(
                        "Today's Sales",
                        "R${todaySales.toStringAsFixed(2)}",
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      buildInfoCard(
                        "Transactions",
                        totalTransactions.toString(),
                        Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      buildInfoCard(
                        "Average Sale",
                        "R${averageSale.toStringAsFixed(2)}",
                        Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      buildInfoCard(
                        "Today's Profit",
                        "R${todayProfit.toStringAsFixed(2)}",
                        todayProfit >= 0 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      buildInfoCard(
                        "Low Stock",
                        lowStockCount.toString(),
                        Colors.red,
                        onTap: openLowStock,
                      ),
                      const SizedBox(width: 12),
                      buildInfoCard(
                        "Total Products",
                        totalProducts.toString(),
                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // STOCK VALUE
                  // =========================

                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 45,
                            color: Colors.indigo,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Total Stock Value",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "R${totalStockValue.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // QUICK ACTIONS
                  // =========================

                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      // New Sale
                      buildCard(
                        context,
                        Icons.point_of_sale,
                        "New Sale",
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewSaleScreen(),
                            ),
                          );

                          await loadDashboard();
                        },
                      ),

                      // Products
                      buildCard(
                        context,
                        Icons.inventory,
                        "Products",
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductsScreen(),
                            ),
                          );

                          await loadDashboard();
                        },
                      ),

                      // Sales History
                      buildCard(
                        context,
                        Icons.receipt_long,
                        "Sales History",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SalesHistoryScreen(),
                            ),
                          );
                        },
                      ),

                      // Customers
                      buildCard(
                        context,
                        Icons.people,
                        "Customers",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomersScreen(),
                            ),
                          );
                        },
                      ),

                      // Suppliers
                      buildCard(
                        context,
                        Icons.business,
                        "Suppliers",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SuppliersScreen(),
                            ),
                          );
                        },
                      ),

                      // Receive Stock
                      buildCard(
                        context,
                        Icons.inventory_2,
                        "Receive Stock",
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReceiveStockScreen(),
                            ),
                          );

                          await loadDashboard();
                        },
                      ),

                      // Stock Movement History
                      buildCard(
                        context,
                        Icons.history,
                        "Stock Movement History",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StockMovementScreen(),
                            ),
                          );
                        },
                      ),

                      // Low Stock
                      buildCard(
                        context,
                        Icons.warning_amber,
                        "Low Stock",
                        openLowStock,
                      ),

                      // Reports
                      buildCard(
                        context,
                        Icons.bar_chart,
                        "Reports",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReportsScreen(),
                            ),
                          );
                        },
                      ),

                      // Settings
                      buildCard(
                        context,
                        Icons.settings,
                        "Settings",
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Settings module coming soon",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
