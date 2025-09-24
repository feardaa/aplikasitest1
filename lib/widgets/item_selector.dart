// widgets/item_selector.dart
import 'package:flutter/material.dart';
import '../models/laundry_item.dart';

/// Widget untuk memilih item laundry
/// Implementasi: Composition, Encapsulation
class ItemSelector extends StatefulWidget {
  final List<ItemType> items;
  final Function(ItemType itemType, int quantity, String? notes) onItemSelected;

  const ItemSelector({
    super.key,
    required this.items,
    required this.onItemSelected,
  });

  @override
  State<ItemSelector> createState() => _ItemSelectorState();
}

class _ItemSelectorState extends State<ItemSelector> {
  ItemType? _selectedItem;
  int _quantity = 1;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildItemDropdown(),
        if (_selectedItem != null) ...[
          const SizedBox(height: 16),
          _buildQuantitySelector(),
          const SizedBox(height: 16),
          _buildNotesField(),
          const SizedBox(height: 16),
          _buildAddButton(),
        ],
      ],
    );
  }

  Widget _buildItemDropdown() {
    return DropdownButtonFormField<ItemType>(
      decoration: const InputDecoration(
        labelText: 'Pilih Item',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.checkroom),
      ),
      value: _selectedItem,
      items: widget.items.map((item) {
        return DropdownMenuItem<ItemType>(
          value: item,
          child: Row(
            children: [
              Expanded(
                child: Text(item.displayName),
              ),
              Text(
                'Rp ${item.basePrice.toInt()}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (ItemType? newValue) {
        setState(() {
          _selectedItem = newValue;
          _quantity = 1; // Reset quantity when item changes
          _notesController.clear();
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Pilih item terlebih dahulu';
        }
        return null;
      },
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('Jumlah: '),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
                icon: const Icon(Icons.remove),
                iconSize: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _quantity < 99
                    ? () => setState(() => _quantity++)
                    : null,
                icon: const Icon(Icons.add),
                iconSize: 20,
              ),
            ],
          ),
        ),
        const Spacer(),
        if (_selectedItem != null)
          Text(
            'Subtotal: Rp ${(_selectedItem!.basePrice * _quantity).toInt()}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Catatan (Opsional)',
        hintText: 'Contoh: Noda membandel di bagian lengan',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 2,
      maxLength: 100,
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _selectedItem != null ? _addItem : null,
        icon: const Icon(Icons.add_shopping_cart),
        label: Text('Tambah ${_selectedItem?.displayName ?? 'Item'}'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _addItem() {
    if (_selectedItem != null) {
      widget.onItemSelected(
        _selectedItem!,
        _quantity,
        _notesController.text.isEmpty ? null : _notesController.text,
      );

      // Reset form after adding
      setState(() {
        _selectedItem = null;
        _quantity = 1;
        _notesController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedItem!.displayName} berhasil ditambahkan'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// Widget untuk menampilkan item dalam bentuk grid
/// Alternative untuk dropdown approach
class ItemGridSelector extends StatelessWidget {
  final List<ItemType> items;
  final Function(ItemType itemType) onItemTap;
  final ItemType? selectedItem;

  const ItemGridSelector({
    super.key,
    required this.items,
    required this.onItemTap,
    this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem == item;

        return Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          child: InkWell(
            onTap: () => onItemTap(item),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checkroom, // You can customize icons per category
                    size: 24,
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${item.basePrice.toInt()}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}