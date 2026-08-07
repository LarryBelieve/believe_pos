import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';
import 'add_supplier_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});
  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late Future<List<Supplier>> suppliersFuture;
  @override
  void initState() {
    super.initState();
    loadSuppliers();
  }

  void loadSuppliers() {
    setState(() {
      suppliersFuture = SupplierService.getSuppliers();
    });
  }

  Future<void> deleteSupplier(int id) async {
    await SupplierService.deleteSupplier(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Supplier deleted successfully"),
      ),
    );
    loadSuppliers();
  }

  Future<void> editSupplier(Supplier supplier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddSupplierScreen(
          supplier: supplier,
        ),
      ),
    );
    if (result == true) {
      loadSuppliers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suppliers"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_business),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddSupplierScreen(),
            ),
          );
          if (result == true) {
            loadSuppliers();
          }
        },
      ),
      body: FutureBuilder<List<Supplier>>(
        future: suppliersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          final suppliers = snapshot.data ?? [];
          if (suppliers.isEmpty) {
            return const Center(
              child: Text(
                "No suppliers yet.",
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.business),
                  ),
                  title: Text(supplier.name),
                  subtitle: Text(
                    "${supplier.phone}\n${supplier.email}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        tooltip: "Edit supplier",
                        onPressed: () {
                          editSupplier(supplier);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        tooltip: "Delete supplier",
                        onPressed: () {
                          deleteSupplier(supplier.id!);
                        },
                      ),
                    ],
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
