import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasitest1/models/order.dart';
import 'package:aplikasitest1/controllers/order_controller.dart';
import 'package:aplikasitest1/utils/validator.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final Order order;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    required this.order,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Order? _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _order == null ? _buildErrorState() : _buildContent(),
      bottomNavigationBar: _order != null ? _buildBottomActions() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Detail Pesanan #${widget.orderId.substring(0, 8)}'),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (_order != null && _order!.canBeCancelled)
          IconButton(
            icon: const Icon(Icons.cancel_outlined),
            onPressed: _showCancelOrderDialog,
            tooltip: 'Batalkan Pesanan',
          ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: _shareOrder,
          tooltip: 'Bagikan',
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Pesanan tidak ditemukan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pesanan dengan ID ${widget.orderId.substring(0, 8)} tidak ditemukan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatusHeader(),
          _buildOrderProgress(),
          _buildServiceInfo(),
          _buildItemsList(),
          _buildPickupInfo(),
          _buildPricingBreakdown(),
          _buildOrderTimeline(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(_order!.status).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(_order!.status),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _order!.status.displayName,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _order!.status.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Estimasi selesai: ${_formatDateTime(_order!.estimatedCompletionDate)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProgress() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Pesanan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressSteps(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    final steps = [
      ('Menunggu', OrderStatus.menunggu),
      ('Dikonfirmasi', OrderStatus.dikonfirmasi),
      ('Dijemput', OrderStatus.dijemput),
      ('Diproses', OrderStatus.diproses),
      ('Selesai', OrderStatus.selesai),
      ('Dikirim', OrderStatus.dikirim),
      ('Diterima', OrderStatus.diterima),
    ];

    return Column(
      children: steps.map((step) {
        final isActive = _isStatusActive(step.$2);
        final isCompleted = _isStatusCompleted(step.$2);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted 
                      ? Colors.green 
                      : isActive 
                          ? Colors.blue 
                          : Colors.grey[300],
                ),
                child: isCompleted 
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : isActive
                        ? const Icon(Icons.radio_button_checked, size: 14, color: Colors.white)
                        : null,
              ),
              const SizedBox(width: 12),
              Text(
                step.$1,
                style: TextStyle(
                  color: isCompleted || isActive ? Colors.black : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _isStatusActive(OrderStatus status) {
    return _order!.status == status;
  }

  bool _isStatusCompleted(OrderStatus status) {
    final statusOrder = [
      OrderStatus.menunggu,
      OrderStatus.dikonfirmasi,
      OrderStatus.dijemput,
      OrderStatus.diproses,
      OrderStatus.selesai,
      OrderStatus.dikirim,
      OrderStatus.diterima,
    ];
    
    final currentIndex = statusOrder.indexOf(_order!.status);
    final targetIndex = statusOrder.indexOf(status);
    
    return currentIndex > targetIndex;
  }

  Widget _buildServiceInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _order!.service.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _order!.service.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _order!.service.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _order!.service.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Estimasi: ${_order!.estimatedDays} hari kerja',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _order!.service.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item Laundry',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_order!.totalItems} item',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_order!.items.map((item) => _buildItemRow(item)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Rp ${item.unitPrice.toInt()} x ${item.quantity}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (item.hasNotes)
                  Text(
                    'Catatan: ${item.notes}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            AppValidators.formatCurrency(item.totalPrice),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Pickup & Delivery',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.location_on_outlined,
              'Alamat',
              _order!.pickupInfo.address,
            ),
            _buildInfoRow(
              Icons.phone_outlined,
              'Telepon',
              AppValidators.formatPhoneNumber(_order!.pickupInfo.phoneNumber),
            ),
            _buildInfoRow(
              Icons.schedule_outlined,
              'Waktu Pickup',
              _formatDateTime(_order!.pickupInfo.scheduledTime),
            ),
            if (_order!.pickupInfo.notes.isNotEmpty)
              _buildInfoRow(
                Icons.note_outlined,
                'Catatan',
                _order!.pickupInfo.notes,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingBreakdown() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rincian Harga',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Subtotal Item', _order!.itemsPrice),
            _buildPriceRow('Biaya Pickup', _order!.pickupFee),
            _buildPriceRow('Biaya Delivery', _order!.deliveryFee),
            const Divider(),
            _buildPriceRow(
              'Total',
              _order!.totalPrice,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            AppValidators.formatCurrency(amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline Pesanan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Pesanan Dibuat',
              _order!.createdAt,
              Icons.shopping_cart_outlined,
            ),
            if (_order!.updatedAt != null)
              _buildTimelineItem(
                'Terakhir Diupdate',
                _order!.updatedAt!,
                Icons.update_outlined,
              ),
            if (_order!.completedAt != null)
              _buildTimelineItem(
                'Pesanan Selesai',
                _order!.completedAt!,
                Icons.check_circle_outlined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime dateTime, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDateTime(dateTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_order!.canBeCancelled) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _showCancelOrderDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Batalkan'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: _contactSupport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Hubungi CS'),
              ),
            ),
          ],
        ),
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
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showCancelOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pesanan ini? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _cancelOrder();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder() async {
    try {
      final orderController = context.read<OrderController>();
      await orderController.cancelOrder(_order!.id);
      
      if (mounted) {
        _showSuccessSnackBar('Pesanan berhasil dibatalkan');
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackBar('Gagal membatalkan pesanan: $e');
    }
  }

  void _shareOrder() {
    _showInfoSnackBar('Fitur share akan segera tersedia');
  }

  void _contactSupport() {
    _showInfoSnackBar('Menghubungi customer service...');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}