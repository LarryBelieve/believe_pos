import 'package:flutter/material.dart';

import 'sales_report_screen.dart';
import 'profit_report_screen.dart';
import 'inventory_report_screen.dart';
import 'product_report_screen.dart';
import 'payment_report_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Business Reports",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "View your sales, profit, inventory, products and payment performance.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          // SALES REPORT
          _buildReportCard(
            context,
            icon: Icons.point_of_sale,
            title: "Sales Report",
            subtitle: "View daily, weekly and monthly sales.",
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SalesReportScreen(),
                ),
              );
            },
          ),

          // PROFIT REPORT
          _buildReportCard(
            context,
            icon: Icons.trending_up,
            title: "Profit Report",
            subtitle: "Track revenue, costs and gross profit.",
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfitReportScreen(),
                ),
              );
            },
          ),

          // INVENTORY REPORT
          _buildReportCard(
            context,
            icon: Icons.inventory_2,
            title: "Inventory Report",
            subtitle: "View current stock, stock value and low-stock products.",
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventoryReportScreen(),
                ),
              );
            },
          ),

          // PRODUCT REPORT
          _buildReportCard(
            context,
            icon: Icons.inventory,
            title: "Product Report",
            subtitle: "Review products, pricing and profit per unit.",
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductReportScreen(),
                ),
              );
            },
          ),

          // PAYMENT REPORT
          _buildReportCard(
            context,
            icon: Icons.payments,
            title: "Payment Report",
            subtitle: "Analyze sales by payment method.",
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentReportScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
