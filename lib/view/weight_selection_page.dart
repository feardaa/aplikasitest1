// views/weight_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/laundry_item.dart';

class WeightSelectionPage extends StatefulWidget {
  final LaundryCategory category;
  final Function(Map<ItemType, double>) onWeightsSelected;
  final String categoryName;

  const WeightSelectionPage({
    super.key,
    required this.category,
    required this.onWeightsSelected,
    required this.categoryName,
  });

  @override
  State<WeightSelectionPage> createState() => _WeightSelectionPageState();
}

class _WeightSelectionPageState extends State<WeightSelectionPage> {
  final Map<ItemType, double> selectedWeights = {};
  final Map<ItemType, TextEditingController> controllers = {};
  late List<ItemType> availableItems;
  
  @override
  void initState() {
    super.initState();
    availableItems = LaundryItem.getItemsByCategory(widget.category);
    
    // Initialize controllers
    for (var item in availableItems) {
      controllers[item] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get totalWeight {
    return selectedWeights.values.fold(0.0, (sum, weight) => sum + weight);
  }

  double get totalPrice {
    double total = 0.0;
    selectedWeights.forEach((item, weight) {
      total += item.basePrice * weight;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih ${widget.categoryName}'),
        backgroundColor: _getCategoryColor(),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildItemsList(),
          ),
          if (selectedWeights.isNotEmpty) _buildBottomSummary(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCategoryColor(),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.scale,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'Pilih item dan tentukan beratnya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Harga Rp 5.000 per kilogram untuk semua jenis pakaian',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableItems.length,
      itemBuilder: (context, index) {
        final item = availableItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(ItemType item) {
    final currentWeight = selectedWeights[item] ?? 0.0;
    final controller = controllers[item]!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item info
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        widget.category.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${item.basePrice.toInt().toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                            (match) => '${match[1]}.'
                          )} per kg',
                          style: TextStyle(
                            fontSize: 14,
                            color: _getCategoryColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Weight input section
              Row(
                children: [
                  // Kg input
                  Expanded(
                    flex: 2,
                    child: _buildWeightInput(
                      label: 'Kg',
                      onChanged: (value) {
                        final kg = double.tryParse(value) ?? 0.0;
                        final currentGram = _getGramFromController(item);
                        _updateWeight(item, kg + (currentGram / 1000));
                      },
                      initialValue: (currentWeight.floor()).toString(),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Gram input
                  Expanded(
                    flex: 2,
                    child: _buildWeightInput(
                      label: 'Gram',
                      maxValue: 999,
                      onChanged: (value) {
                        final gram = double.tryParse(value) ?? 0.0;
                        final currentKg = currentWeight.floor();
                        _updateWeight(item, currentKg + (gram / 1000));
                      },
                      initialValue: ((currentWeight % 1) * 1000).round().toString(),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Quick add buttons
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildQuickButton('0.5kg', () => _updateWeight(item, currentWeight + 0.5)),
                            const SizedBox(width: 4),
                            _buildQuickButton('1kg', () => _updateWeight(item, currentWeight + 1.0)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (currentWeight > 0)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _updateWeight(item, 0.0),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                minimumSize: const Size(0, 28),
                              ),
                              child: const Text('Reset', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Show subtotal if weight > 0
              if (currentWeight > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Berat: ${_formatWeight(currentWeight)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Subtotal: Rp ${(item.basePrice * currentWeight).toInt().toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                          (match) => '${match[1]}.'
                        )}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightInput({
    required String label,
    required Function(String) onChanged,
    required String initialValue,
    int? maxValue,
  }) {
    return TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (maxValue != null) _LimitingTextInputFormatter(maxValue),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        suffixText: label.toLowerCase(),
      ),
      onChanged: onChanged,
      controller: TextEditingController(text: initialValue == '0' ? '' : initialValue),
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getCategoryColor(),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 4),
          minimumSize: const Size(0, 28),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11)),
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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Berat: ${_formatWeight(totalWeight)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Rp ${totalPrice.toInt().toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                    (match) => '${match[1]}.'
                  )}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: totalWeight > 0 ? () {
                  widget.onWeightsSelected(selectedWeights);
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getCategoryColor(),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  "Lanjutkan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateWeight(ItemType item, double weight) {
    setState(() {
      if (weight <= 0) {
        selectedWeights.remove(item);
      } else {
        selectedWeights[item] = double.parse(weight.toStringAsFixed(3));
      }
    });
  }

  double _getGramFromController(ItemType item) {
    // Logic to extract gram from current weight
    final currentWeight = selectedWeights[item] ?? 0.0;
    return (currentWeight % 1) * 1000;
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
}

// Custom input formatter untuk membatasi nilai maksimum
class _LimitingTextInputFormatter extends TextInputFormatter {
  final int maxValue;

  _LimitingTextInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? value = int.tryParse(newValue.text);
    if (value == null || value > maxValue) {
      return oldValue;
    }

    return newValue;
  }
}