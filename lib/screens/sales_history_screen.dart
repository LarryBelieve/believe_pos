import 'package:flutter/material.dart';

import '../models/sale.dart';
import '../services/sales_history_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales History"),
      ),
      body: FutureBuilder<List<Sale>>(
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
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.receipt_long,
                    color: Colors.green,
                  ),
                  title: Text(
                    "Sale #${sale.id}",
                  ),
                  subtitle: Text(
                    "${sale.paymentMethod}\n${sale.saleDate}",
                  ),
                  trailing: Text(
                    "R${sale.total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
