// views/admin_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasitest1/controllers/order_controller.dart';
import 'package:aplikasitest1/models/order.dart';
import 'package:aplikasitest1/utils/debug_helper.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String selectedStatusFilter = 'semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    
      context.read<OrderController>().loadAllOrdersForAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderController>().loadAllOrdersForAdmin();
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Orders'),
                  content:
                      const Text('Hapus semua data pesanan? (Untuk testing)'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<OrderController>().clearAllOrders();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Semua pesanan dihapus')),
                        );
                      },
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<OrderController>(
        builder: (context, orderController, child) {
          if (orderController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final orders = orderController.orders;
          final filteredOrders = _filterOrders(orders);

          return Column(
            children: [
              _buildStatusFilter(),
              _buildOrderStats(orders),
              Expanded(
                child: filteredOrders.isEmpty
                    ? const Center(
                        child: Text('Tidak ada pesanan'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return _buildAdminOrderCard(order, orderController);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDebugMenu(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),
    );
  }

  void _showDebugMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Debug Menu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print All Data'),
              onTap: () async {
                Navigator.pop(context);
                await DebugHelper.printAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Check console for debug info')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Dummy Order'),
              onTap: () async {
                Navigator.pop(context);
                await DebugHelper.addDummyOrder();
                context.read<OrderController>().loadAllOrdersForAdmin();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dummy order added')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Clear All Data'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Warning'),
                    content: const Text(
                        'This will delete ALL data including users and orders!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await DebugHelper.clearAllData();
                          context
                              .read<OrderController>()
                              .loadAllOrdersForAdmin();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All data cleared')),
                          );
                        },
                        child: const Text('Delete All'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('semua', 'Semua'),
            ...OrderStatus.values.map(
                (status) => _buildFilterChip(status.name, status.displayName)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedStatusFilter == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedStatusFilter = value;
          });
        },
        selectedColor: Colors.indigo.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? Colors.indigo : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
    );
  }

  Widget _buildOrderStats(List<Order> orders) {
    final stats = _calculateStats(orders);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistik Pesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child:
                        _buildStatItem('Total', stats['total']!, Colors.blue),
                  ),
                  Expanded(
                    child: _buildStatItem(
                        'Menunggu', stats['menunggu']!, Colors.orange),
                  ),
                  Expanded(
                    child: _buildStatItem(
                        'Proses', stats['proses']!, Colors.purple),
                  ),
                  Expanded(
                    child: _buildStatItem(
                        'Selesai', stats['selesai']!, Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminOrderCard(Order order, OrderController orderController) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '#${order.id.substring(0, 8)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusColor(order.status)),
              ),
              child: Text(
                order.status.displayName,
                style: TextStyle(
                  color: _getStatusColor(order.status),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${order.service.name} • ${order.totalItems} item'),
            Text('Rp ${order.totalPrice.toInt()}'),
            Text('${_formatDateTime(order.createdAt)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pesanan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.displayName} x${item.quantity}'),
                          Text('Rp ${item.totalPrice.toInt()}'),
                        ],
                      ),
                    )),
                const Divider(),
                const Text(
                  'Alamat Pickup:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(order.pickupInfo.address),
                Text('Tel: ${order.pickupInfo.phoneNumber}'),
                const SizedBox(height: 12),
                const Text(
                  'Ubah Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _getAvailableNextStatuses(order.status)
                      .map(
                        (status) => ElevatedButton(
                          onPressed: () => _updateOrderStatus(
                              order, status, orderController),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getStatusColor(status),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                          ),
                          child: Text(
                            status.displayName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Order> _filterOrders(List<Order> orders) {
    if (selectedStatusFilter == 'semua') {
      return orders;
    }
    return orders
        .where((order) => order.status.name == selectedStatusFilter)
        .toList();
  }

  Map<String, int> _calculateStats(List<Order> orders) {
    return {
      'total': orders.length,
      'menunggu': orders
          .where((o) =>
              o.status == OrderStatus.menunggu ||
              o.status == OrderStatus.dikonfirmasi)
          .length,
      'proses': orders
          .where((o) =>
              o.status == OrderStatus.dijemput ||
              o.status == OrderStatus.diproses)
          .length,
      'selesai': orders
          .where((o) =>
              o.status == OrderStatus.selesai ||
              o.status == OrderStatus.diterima)
          .length,
    };
  }

  List<OrderStatus> _getAvailableNextStatuses(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.menunggu:
        return [OrderStatus.dikonfirmasi, OrderStatus.dibatalkan];
      case OrderStatus.dikonfirmasi:
        return [OrderStatus.dijemput, OrderStatus.dibatalkan];
      case OrderStatus.dijemput:
        return [OrderStatus.diproses];
      case OrderStatus.diproses:
        return [OrderStatus.selesai];
      case OrderStatus.selesai:
        return [OrderStatus.dikirim];
      case OrderStatus.dikirim:
        return [OrderStatus.diterima];
      default:
        return [];
    }
  }

  void _updateOrderStatus(
      Order order, OrderStatus newStatus, OrderController orderController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(
          'Ubah status pesanan #${order.id.substring(0, 8)} menjadi ${newStatus.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await orderController.updateOrderStatus(order.id, newStatus);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Status berhasil diubah menjadi ${newStatus.displayName}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal mengubah status: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.menunggu:
        return Colors.orange;
      case OrderStatus.dikonfirmasi:
        return Colors.blue;
      case OrderStatus.dijemput:
        return Colors.purple;
      case OrderStatus.diproses:
        return Colors.indigo;
      case OrderStatus.selesai:
        return Colors.green;
      case OrderStatus.dikirim:
        return Colors.teal;
      case OrderStatus.diterima:
        return Colors.green[700]!;
      case OrderStatus.dibatalkan:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
