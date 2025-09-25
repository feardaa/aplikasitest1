import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasitest1/models/laundry_service.dart';
import 'package:aplikasitest1/models/laundry_item.dart';
import 'package:aplikasitest1/controllers/order_controller.dart';
import 'package:aplikasitest1/view/order_category_page.dart';

class ServiceDetailPage extends StatefulWidget {
  final LaundryService service;
  final String userId;

  const ServiceDetailPage({
    super.key,
    required this.service,
    required this.userId,
  });

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<ItemType> _availableItems;
  final Map<ItemType, int> _selectedItems = {};
  final Map<ItemType, double> _selectedWeights = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAvailableItems();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _loadAvailableItems() {
    _availableItems = LaundryItem.getItemsByCategory(widget.service.category);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  void _addToSelection(ItemType itemType) {
    setState(() {
      if (itemType.isPerKg) {
        
        _selectedWeights[itemType] = (_selectedWeights[itemType] ?? 0.0) + 0.5;
      } else {
       
        _selectedItems[itemType] = (_selectedItems[itemType] ?? 0) + 1;
      }
    });
  }

  void _removeFromSelection(ItemType itemType) {
    setState(() {
      if (itemType.isPerKg) {
        final currentWeight = _selectedWeights[itemType] ?? 0.0;
        if (currentWeight > 0.5) {
          _selectedWeights[itemType] = currentWeight - 0.5;
        } else {
          _selectedWeights.remove(itemType);
        }
      } else {
        final currentQty = _selectedItems[itemType] ?? 0;
        if (currentQty > 0) {
          if (currentQty == 1) {
            _selectedItems.remove(itemType);
          } else {
            _selectedItems[itemType] = currentQty - 1;
          }
        }
      }
    });
  }

  int get _totalItems {
    int total = _selectedItems.values.fold(0, (sum, qty) => sum + qty);
    total += _selectedWeights.keys.length; 
    return total;
  }

  double get _totalPrice {
    double total = 0;
    

    _selectedItems.forEach((itemType, qty) {
      total += itemType.basePrice * qty;
    });
    
    _selectedWeights.forEach((itemType, weight) {
      total += itemType.basePrice * weight;
    });
    
    return total * widget.service.multiplier;
  }

  void _proceedToOrder() {
    if (_selectedItems.isEmpty && _selectedWeights.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu item untuk melanjutkan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

  
    final orderController = Provider.of<OrderController>(context, listen: false);
    orderController.setSelectedService(widget.service);

    orderController.clearCurrentOrder();

    _selectedItems.forEach((itemType, quantity) {
      orderController.addItem(
        itemType, 
        quantity: quantity,
        weight: 0.0,
      );
    });

  
    _selectedWeights.forEach((itemType, weight) {
      orderController.addItem(
        itemType, 
        quantity: 1,
        weight: weight,
      );
    });

  
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryOrderPage(
          userId: widget.userId,
          category: widget.service.category,
        ),
      ),
    );
  }


  String _getFormattedUnitPrice(ItemType itemType) {
    final unitLabel = itemType.isPerKg ? 'per kg' : 'per item';
    return 'Rp ${itemType.basePrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (match) => '${match[1]}.'
    )}/$unitLabel';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildServiceHeader(),
            Expanded(child: _buildItemsList()),
            if (_selectedItems.isNotEmpty || _selectedWeights.isNotEmpty) 
              _buildBottomSummary(),
          ],
        ),
      ),
    );
  }


  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.service.name),
      backgroundColor: widget.service.color,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.service.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                widget.service.icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.service.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip("${widget.service.getEstimatedDays()} hari", Icons.access_time),
              const SizedBox(width: 16),
              _buildInfoChip("${(widget.service.multiplier * 100).toInt()}%", Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableItems.length,
      itemBuilder: (context, index) {
        final item = _availableItems[index];
        final quantity = _selectedItems[item] ?? 0;
        final weight = _selectedWeights[item] ?? 0.0;
        
        return _buildItemCard(item, quantity, weight);
      },
    );
  }


  Widget _buildItemCard(ItemType item, int quantity, double weight) {
    final bool hasSelection = item.isPerKg ? weight > 0 : quantity > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFormattedUnitPrice(item), // PERBAIKAN: Gunakan helper method
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.service.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (hasSelection) ...[
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: () => _removeFromSelection(item),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        item.isPerKg 
                          ? _formatWeight(weight)
                          : quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: () => _addToSelection(item),
                    ),
                  ],
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => _addToSelection(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.service.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: Text(item.isPerKg ? '+0.5kg' : 'Tambah'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: widget.service.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: widget.service.color),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total $_totalItems item(s)",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatCurrency(_totalPrice),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.service.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _proceedToOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.service.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "Lanjut Pesan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  String _formatCurrency(double amount) {
    return "Rp ${amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (match) => '${match[1]}.'
    )}";
  }
}