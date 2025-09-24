// views/category_order_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/order_controller.dart';
import '../models/laundry_item.dart';
import '../models/laundry_service.dart';
import '../models/order.dart';
import 'weight_selection_page.dart';

class CategoryOrderPage extends StatefulWidget {
  final String userId;
  final LaundryCategory category;

  const CategoryOrderPage({
    super.key,
    required this.userId,
    required this.category,
  });

  @override
  State<CategoryOrderPage> createState() => _CategoryOrderPageState();
}

class _CategoryOrderPageState extends State<CategoryOrderPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  LaundryService? selectedService;
  DateTime? selectedPickupTime;
  Map<ItemType, double> selectedItemWeights = {}; // Untuk items per kg
  Map<ItemType, int> selectedItemQuantities = {}; // Untuk items per piece

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.displayName),
        backgroundColor: _getCategoryColor(),
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderController>(
        builder: (context, orderController, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryHeader(),
                const SizedBox(height: 24),
                _buildServiceSelection(orderController),
                const SizedBox(height: 24),
                if (selectedService != null) ...[
                  _buildItemSelection(),
                  const SizedBox(height: 24),
                ],
                if (_hasSelectedItems()) ...[
                  _buildOrderSummary(),
                  const SizedBox(height: 24),
                  _buildPickupInformation(),
                  const SizedBox(height: 24),
                  _buildCreateOrderButton(orderController),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.category.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getCategoryDescription(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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

  Widget _buildServiceSelection(OrderController orderController) {
    final availableServices = LaundryService.getDefaultServices()
        .where((service) => service.category == widget.category)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Jenis Layanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...availableServices.map((service) {
              final isSelected = selectedService?.id == service.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedService = service;
                      // Reset selections when service changes
                      selectedItemWeights.clear();
                      selectedItemQuantities.clear();
                    });
                    orderController.setSelectedService(service);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? _getCategoryColor()
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? _getCategoryColor().withOpacity(0.1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Text(
                          service.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                service.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Estimasi: ${service.getEstimatedDays()} hari',
                                style: TextStyle(
                                  color: _getCategoryColor(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: _getCategoryColor(),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemSelection() {
    final isPerKg = _isPerKgCategory();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPerKg ? 'Pilih Item dan Berat' : 'Pilih Item',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPerKg)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Per KG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (isPerKg) ...[
              // Untuk kategori per kg, tampilkan tombol untuk ke halaman pemilihan berat
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.scale,
                      size: 48,
                      color: _getCategoryColor(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sistem Pembayaran Per Kilogram',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih jenis pakaian dan tentukan beratnya\nHarga: Rp 5.000 per kilogram',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToWeightSelection(),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Pilih Item & Berat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getCategoryColor(),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Untuk kategori per item, tampilkan list item seperti biasa
              ..._buildItemList(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItemList() {
    final availableItems = LaundryItem.getItemsByCategory(widget.category);
    
    return availableItems.map((itemType) {
      final quantity = selectedItemQuantities[itemType] ?? 0;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemType.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Rp ${itemType.basePrice.toInt().toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                      (match) => '${match[1]}.'
                    )}/item',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (quantity > 0) ...[
              Row(
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onPressed: () => _updateItemQuantity(itemType, quantity - 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onPressed: () => _updateItemQuantity(itemType, quantity + 1),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => _updateItemQuantity(itemType, 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getCategoryColor(),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text('Tambah'),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: _getCategoryColor()),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Items per kg
            ...selectedItemWeights.entries.map((entry) {
              final itemType = entry.key;
              final weight = entry.value;
              final subtotal = itemType.basePrice * weight;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemType.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Rp ${itemType.basePrice.toInt()}/kg × ${_formatWeight(weight)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${subtotal.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            // Items per piece
            ...selectedItemQuantities.entries.map((entry) {
              final itemType = entry.key;
              final quantity = entry.value;
              final subtotal = itemType.basePrice * quantity;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemType.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Rp ${itemType.basePrice.toInt()}/item × $quantity',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${subtotal.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const Divider(),
            
            if (_isPerKgCategory()) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Berat',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _formatWeight(_getTotalWeight()),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal Item'),
                Text('Rp ${_getSubtotal().toInt()}'),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Biaya Antar Jemput'),
                Text('Rp 5000'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Rp ${(_getSubtotal() + 5000).toInt()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getCategoryColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pickup',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      selectedPickupTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule),
                    const SizedBox(width: 8),
                    Text(
                      selectedPickupTime != null
                          ? 'Pickup: ${selectedPickupTime!.day}/${selectedPickupTime!.month}/${selectedPickupTime!.year} ${selectedPickupTime!.hour}:${selectedPickupTime!.minute.toString().padLeft(2, '0')}'
                          : 'Pilih Waktu Pickup',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOrderButton(OrderController orderController) {
    final isValid = _hasSelectedItems() &&
        _addressController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        selectedPickupTime != null;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (isValid && !orderController.isLoading)
            ? () => _createOrder(orderController)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getCategoryColor(),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: orderController.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Buat Pesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // Helper methods
  bool _isPerKgCategory() {
    return widget.category == LaundryCategory.pakaian ||
           widget.category == LaundryCategory.setrika ||
           widget.category == LaundryCategory.kering;
  }

  bool _hasSelectedItems() {
    return selectedItemWeights.isNotEmpty || selectedItemQuantities.isNotEmpty;
  }

  double _getTotalWeight() {
    return selectedItemWeights.values.fold(0.0, (sum, weight) => sum + weight);
  }

  double _getSubtotal() {
    double subtotal = 0.0;
    
    // Calculate from weights
    selectedItemWeights.forEach((itemType, weight) {
      subtotal += itemType.basePrice * weight;
    });
    
    // Calculate from quantities
    selectedItemQuantities.forEach((itemType, quantity) {
      subtotal += itemType.basePrice * quantity;
    });
    
    return subtotal * (selectedService?.multiplier ?? 1.0);
  }

  String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return '${weight.round()} kg';
    }
    
    final kg = weight.floor();
    final gram = ((weight % 1) * 1000).round();
    
    if (kg == 0) {
      return '${gram}g';
    } else if (gram == 0) {
      return '${kg} kg';
    } else {
      return '${kg}kg ${gram}g';
    }
  }

  void _navigateToWeightSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WeightSelectionPage(
          category: widget.category,
          categoryName: widget.category.displayName,
          onWeightsSelected: (weights) {
            setState(() {
              selectedItemWeights = weights;
            });
          },
        ),
      ),
    );
  }

  void _updateItemQuantity(ItemType itemType, int quantity) {
    setState(() {
      if (quantity <= 0) {
        selectedItemQuantities.remove(itemType);
      } else {
        selectedItemQuantities[itemType] = quantity;
      }
    });
  }

  void _createOrder(OrderController orderController) async {
    try {
      // Create pickup info
      final pickupInfo = PickupInfo(
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        notes: _notesController.text,
        scheduledTime: selectedPickupTime!,
      );

      // Set pickup info and service
      orderController.setPickupInfo(pickupInfo);
      orderController.setSelectedService(selectedService!);

      // Clear existing items
      orderController.clearCurrentOrder();

      // Add weight-based items
      selectedItemWeights.forEach((itemType, weight) {
        orderController.addItem(
          itemType,
          quantity: 1, // Not used for weight-based
          weight: weight,
        );
      });

      // Add quantity-based items
      selectedItemQuantities.forEach((itemType, quantity) {
        orderController.addItem(
          itemType,
          quantity: quantity,
          weight: 0.0, // Not used for quantity-based
        );
      });

      // Create order
      final order = await orderController.createOrder(
        widget.userId,
        orderController.currentOrderItems,
      );

      if (order != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderController.error ?? 'Gagal membuat pesanan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getCategoryColor() {
    switch (widget.category) {
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

  String _getCategoryDescription() {
    switch (widget.category) {
      case LaundryCategory.pakaian:
        return 'Cuci bersih semua jenis pakaian dengan sistem per kilogram';
      case LaundryCategory.tas:
        return 'Pembersihan tas dan aksesoris dengan perawatan khusus';
      case LaundryCategory.sepatu:
        return 'Cuci sepatu profesional dengan teknik pembersihan mendalam';
      case LaundryCategory.kering:
        return 'Dry cleaning premium untuk pakaian berbahan delicate';
      case LaundryCategory.setrika:
        return 'Layanan setrika khusus dengan hasil rapi dan profesional';
      case LaundryCategory.karpet:
        return 'Cuci karpet dan korden dengan sistem pembersihan mendalam';
    }
  }
}