import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool taxEnabled = false;
  bool lowStockAlerts = true;

  double taxRate = 15.0;
  int lowStockLimit = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Business Settings",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Manage your Believe POS configuration.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          // =====================================================
          // BUSINESS INFORMATION
          // =====================================================

          _buildSectionTitle(
            "Business Information",
            Icons.business,
          ),

          _buildSettingsCard(
            icon: Icons.store,
            title: "Business Details",
            subtitle: "Set your business name, phone, email and address.",
            onTap: () {
              _showComingSoon("Business Details");
            },
          ),

          // =====================================================
          // CURRENCY & TAX
          // =====================================================

          _buildSectionTitle(
            "Currency & Tax",
            Icons.payments,
          ),

          Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.currency_exchange),
                  ),
                  title: const Text(
                    "Currency",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    "South African Rand (ZAR)",
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.percent,
                  ),
                  title: const Text(
                    "Enable Tax / VAT",
                  ),
                  subtitle: Text(
                    taxEnabled
                        ? "VAT enabled at ${taxRate.toStringAsFixed(1)}%"
                        : "VAT is currently disabled",
                  ),
                  value: taxEnabled,
                  onChanged: (value) {
                    setState(() {
                      taxEnabled = value;
                    });
                  },
                ),
                if (taxEnabled)
                  ListTile(
                    leading: const Icon(
                      Icons.percent,
                    ),
                    title: const Text(
                      "VAT Rate",
                    ),
                    subtitle: Text(
                      "${taxRate.toStringAsFixed(1)}%",
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: _showTaxRateDialog,
                  ),
              ],
            ),
          ),

          // =====================================================
          // INVENTORY
          // =====================================================

          _buildSectionTitle(
            "Inventory",
            Icons.inventory_2,
          ),

          Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(
                    Icons.warning_amber,
                  ),
                  title: const Text(
                    "Low Stock Alerts",
                  ),
                  subtitle: Text(
                    lowStockAlerts
                        ? "Alerts are enabled"
                        : "Alerts are disabled",
                  ),
                  value: lowStockAlerts,
                  onChanged: (value) {
                    setState(() {
                      lowStockAlerts = value;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.inventory,
                  ),
                  title: const Text(
                    "Low Stock Limit",
                  ),
                  subtitle: Text(
                    "Products at or below $lowStockLimit units "
                    "are considered low stock.",
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: _showLowStockLimitDialog,
                ),
              ],
            ),
          ),

          // =====================================================
          // RECEIPTS
          // =====================================================

          _buildSectionTitle(
            "Receipts",
            Icons.receipt_long,
          ),

          _buildSettingsCard(
            icon: Icons.receipt,
            title: "Receipt Settings",
            subtitle: "Configure receipt information and footer.",
            onTap: () {
              _showComingSoon("Receipt Settings");
            },
          ),

          // =====================================================
          // STAFF
          // =====================================================

          _buildSectionTitle(
            "Staff & Users",
            Icons.people,
          ),

          _buildSettingsCard(
            icon: Icons.person,
            title: "Staff Management",
            subtitle: "Manage cashiers and staff accounts.",
            onTap: () {
              _showComingSoon("Staff Management");
            },
          ),

          // =====================================================
          // DATABASE
          // =====================================================

          _buildSectionTitle(
            "Data Management",
            Icons.storage,
          ),

          _buildSettingsCard(
            icon: Icons.backup,
            title: "Backup & Restore",
            subtitle: "Back up or restore your Believe POS data.",
            onTap: () {
              _showComingSoon("Backup & Restore");
            },
          ),

          // =====================================================
          // ABOUT
          // =====================================================

          _buildSectionTitle(
            "About",
            Icons.info_outline,
          ),

          Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const ListTile(
              leading: CircleAvatar(
                child: Icon(
                  Icons.point_of_sale,
                ),
              ),
              title: Text(
                "Believe POS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Point of Sale System",
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              "Believe POS",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // VAT RATE
  // ============================================================

  Future<void> _showTaxRateDialog() async {
    final controller = TextEditingController(
      text: taxRate.toString(),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "VAT Rate",
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: "VAT percentage",
              suffixText: "%",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(
                  controller.text.trim(),
                );

                if (value == null || value < 0 || value > 100) {
                  return;
                }

                Navigator.pop(
                  context,
                  value,
                );
              },
              child: const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    setState(() {
      taxRate = result;
    });
  }

  // ============================================================
  // LOW STOCK LIMIT
  // ============================================================

  Future<void> _showLowStockLimitDialog() async {
    final controller = TextEditingController(
      text: lowStockLimit.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Low Stock Limit",
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Number of units",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(
                  controller.text.trim(),
                );

                if (value == null || value < 0) {
                  return;
                }

                Navigator.pop(
                  context,
                  value,
                );
              },
              child: const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    setState(() {
      lowStockLimit = result;
    });
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$feature module coming next.",
        ),
      ),
    );
  }
}
