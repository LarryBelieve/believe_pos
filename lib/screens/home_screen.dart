import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';
import 'new_sale_screen.dart';
import 'products_screen.dart';
import 'sales_history_screen.dart';
import 'customers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double todaySales = 0;
  int totalTransactions = 0;
  double averageSale = 0;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final sales = await DashboardService.getTodaySales();
    final transactions = await DashboardService.getTotalTransactions();
    final average = await DashboardService.getAverageSale();

    if (!mounted) return;

    setState(() {
      todaySales = sales;
      totalTransactions = transactions;
      averageSale = average;
    });
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
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
    );
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

                    loadDashboard();
                  },
                ),
                buildCard(
                  context,
                  Icons.inventory,
                  "Products",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductsScreen(),
                      ),
                    );
                  },
                ),
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
