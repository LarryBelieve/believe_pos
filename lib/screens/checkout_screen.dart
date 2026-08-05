import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/sale.dart';
import '../services/cart_service.dart';
import '../services/sales_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController amountController = TextEditingController();

  String paymentMethod = "Cash";

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<CartItem> cartItems = CartService.cartItems.value;

    final double total = cartItems.fold(
      0.0,
      (sum, item) => sum + item.total,
    );

    final double amountReceived = double.tryParse(amountController.text) ?? 0;

    final double change = amountReceived - total;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];

                  return Card(
                    child: ListTile(
                      title: Text(item.product.name),
                      subtitle: Text(
                        "Qty: ${item.quantity}",
                      ),
                      trailing: Text(
                        "R${item.total.toStringAsFixed(2)}",
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TOTAL",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "R${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: paymentMethod,
              decoration: const InputDecoration(
                labelText: "Payment Method",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Cash",
                  child: Text("Cash"),
                ),
                DropdownMenuItem(
                  value: "Card",
                  child: Text("Card"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Amount Received",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Change",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "R${change.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  "Complete Sale",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () async {
                  if (cartItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Cart is empty."),
                      ),
                    );
                    return;
                  }

                  if (paymentMethod == "Cash" && amountReceived < total) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Amount received is less than the total.",
                        ),
                      ),
                    );
                    return;
                  }

                  final sale = Sale(
                    total: total,
                    paymentMethod: paymentMethod,
                    saleDate: DateTime.now().toIso8601String(),
                  );

                  try {
                    await SalesService.saveSale(
                      sale: sale,
                      cartItems: cartItems,
                    );

                    CartService.clearCart();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Sale completed successfully!",
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Error completing sale: $e",
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
