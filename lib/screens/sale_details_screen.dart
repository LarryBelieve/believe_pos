import 'package:flutter/material.dart';

import '../models/sale.dart';

class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailsScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sale Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sale #${sale.id ?? '-'}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Date: ${sale.saleDate}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Payment: ${sale.paymentMethod}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Total: R${sale.total.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
