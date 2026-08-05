import 'package:flutter/material.dart';

import '../models/sale.dart';
import '../services/sales_history_service.dart';
import 'sale_details_screen.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late Future<List<Sale>> salesFuture;

  @override
  void initState() {
    super.initState();
    salesFuture = SalesHistoryService.getSales();
  }

  Future<void> _refreshSales() async {
    setState(() {
      salesFuture = SalesHistoryService.getSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales History"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSales,
        child: FutureBuilder<List<Sale>>(
          future: salesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                ),
              );
            }

            final sales = snapshot.data ?? [];

            if (sales.isEmpty) {
              return const Center(
                child: Text(
                  "No sales yet.",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      "Sale #${sale.id}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${sale.paymentMethod}\n${sale.saleDate}",
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "R${sale.total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SaleDetailsScreen(
                            sale: sale,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
