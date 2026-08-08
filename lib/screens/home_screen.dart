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

      final lowStockProducts = await ProductService.getLowStockProducts();

      if (!mounted) return;

      setState(() {
        todaySales = sales;
        totalTransactions = transactions;
        averageSale = average;
        lowStockCount = lowStockProducts.length;
      });
    } catch (e) {
      if (!mounted) return;

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
              horizontal: 16,
              vertical: 22,
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Today's Sales + Transactions
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

            // Average Sale + Low Stock
            Row(
              children: [
                buildInfoCard(
                  "Average Sale",
                  "R${averageSale.toStringAsFixed(2)}",
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                buildInfoCard(
                  "Low Stock",
                  lowStockCount.toString(),
                  Colors.red,
                  onTap: openLowStock,
                ),
              ],
            ),

            const SizedBox(height: 20),

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

                // Reports
                buildCard(
                  context,
                  Icons.bar_chart,
                  "Reports",
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Reports module coming soon",
                        ),
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

                // Stock History
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
