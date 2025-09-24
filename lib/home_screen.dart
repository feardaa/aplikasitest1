import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasitest1/controllers/order_controller.dart';
import 'package:aplikasitest1/models/laundry_item.dart';
import 'package:aplikasitest1/view/order_category_page.dart';
import 'package:aplikasitest1/view/order_history_page.dart';
import 'package:aplikasitest1/widgets/admin_access_widget.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String username;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().loadOrders(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildQuickActions(),
              _buildCategoriesSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: const AdminAccessWidget(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            'assets/images/olaf.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.ac_unit,
                                color: Colors.lightBlueAccent,
                                size: 30,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Halo, ${widget.username}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mari mulai mencuci pakaian Anda',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.add_shopping_cart,
                  title: 'Buat Pesanan',
                  color: Colors.green,
                  onTap: () {
                    _showCategoryBottomSheet();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.history,
                  title: 'Riwayat',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderHistoryPage(userId: widget.userId),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layanan Tersedia',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: LaundryCategory.values.length,
            itemBuilder: (context, index) {
              final category = LaundryCategory.values[index];
              return _buildRectangularCategoryCard(category);
            },
          ),
        ],
      ),
    );
  }

  
  Widget _buildRectangularCategoryCard(LaundryCategory category) {
    final colors = _getCategoryColors(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryOrderPage(
                  userId: widget.userId,
                  category: category,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 80, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [colors.withOpacity(0.8), colors.withOpacity(0.6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCategoryDescription(category),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Arrow icon
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColors(LaundryCategory category) {
    switch (category) {
      case LaundryCategory.pakaian:
        return Colors.blue;
      case LaundryCategory.tas:
        return Colors.green;
      case LaundryCategory.sepatu:
        return Colors.orange;
      case LaundryCategory.kering:
        return Colors.purple;
      case LaundryCategory.setrika:
        return Colors.red;
      case LaundryCategory.karpet:
        return Colors.teal;
    }
  }

  String _getCategoryDescription(LaundryCategory category) {
    switch (category) {
      case LaundryCategory.pakaian:
        return 'Cuci bersih semua jenis pakaian';
      case LaundryCategory.tas:
        return 'Pembersihan tas dan dompet';
      case LaundryCategory.sepatu:
        return 'Cuci sepatu profesional';
      case LaundryCategory.kering:
        return 'Dry cleaning premium';
      case LaundryCategory.setrika:
        return 'Layanan setrika saja';
      case LaundryCategory.karpet:
        return 'Cuci karpet & gorden';
    }
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Kategori Laundry',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...LaundryCategory.values
                .map((category) => ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColors(category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(category.icon,
                            style: const TextStyle(fontSize: 20)),
                      ),
                      title: Text(category.displayName),
                      subtitle: Text(_getCategoryDescription(category)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryOrderPage(
                              userId: widget.userId,
                              category: category,
                            ),
                          ),
                        );
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
