import 'dart:convert';
import 'base_model.dart';

/// Enum untuk kategori item laundry
enum LaundryCategory {
  pakaian('Cuci Pakaian', '👕'),
  tas('Cuci Tas', '🎒'),
  sepatu('Cuci Sepatu', '👟'),
  kering('Cuci Kering', '🤵'),
  setrika('Setrika Saja', '🔥'),
  karpet('Cuci Karpet', '🏠');

  const LaundryCategory(this.displayName, this.icon);
  final String displayName;
  final String icon;
}

/// Enum untuk jenis item berdasarkan kategori
/// Harga sudah disesuaikan untuk sistem per KG = 5000
enum ItemType {
  // Pakaian - semua kategori pakaian menggunakan harga yang sama per kg
  baju('Baju', LaundryCategory.pakaian, 5000),
  celana('Celana', LaundryCategory.pakaian, 5000),
  rok('Rok', LaundryCategory.pakaian, 5000),
  kaos('Kaos', LaundryCategory.pakaian, 5000),
  kemeja('Kemeja', LaundryCategory.pakaian, 5000),
  jaket('Jaket', LaundryCategory.pakaian, 5000),
  underwear('Underwear', LaundryCategory.pakaian, 5000),

  // Tas
  tasRansel('Tas Ransel', LaundryCategory.tas, 15000),
  tasTangan('Tas Tangan', LaundryCategory.tas, 12000),
  tasLaptop('Tas Laptop', LaundryCategory.tas, 18000),
  tasOlahraga('Tas Olahraga', LaundryCategory.tas, 13000),

  // Sepatu
  sepatuSneaker('Sepatu Sneaker', LaundryCategory.sepatu, 20000),
  sepatuFormal('Sepatu Formal', LaundryCategory.sepatu, 25000),
  sandal('Sandal', LaundryCategory.sepatu, 15000),
  sepatuOlahraga('Sepatu Olahraga', LaundryCategory.sepatu, 22000),

  // Cuci Kering
  jas('Jas', LaundryCategory.kering, 30000),
  gaun('Gaun', LaundryCategory.kering, 25000),
  pakaianPremium('Pakaian Premium', LaundryCategory.kering, 20000),

  // Setrika
  kemejaSetrika('Kemeja', LaundryCategory.setrika, 5000),
  celanaFormal('Celana Formal', LaundryCategory.setrika, 6000),
  rokSetrika('Rok', LaundryCategory.setrika, 5000),

  // Karpet
  karpetKecil('Karpet Kecil', LaundryCategory.karpet, 25000),
  karpetSedang('Karpet Sedang', LaundryCategory.karpet, 40000),
  karpetBesar('Karpet Besar', LaundryCategory.karpet, 60000),
  korden('Gorden', LaundryCategory.karpet, 35000);

  const ItemType(this.displayName, this.category, this.basePrice);
  final String displayName;
  final LaundryCategory category;
  final double basePrice;

  /// Apakah item ini menggunakan sistem per kg
  bool get isPerKg {
    return category == LaundryCategory.pakaian || 
           category == LaundryCategory.setrika ||
           category == LaundryCategory.kering;
  }

  /// Get unit label untuk display
  String get unitLabel {
    return isPerKg ? 'per kg' : 'per item';
  }
}

/// Model untuk item laundry individual dengan support berat
class LaundryItem extends BaseModel implements Identifiable {
  final String _id;
  final ItemType _itemType;
  final int _quantity; // untuk item non-kg
  final double _weight; // untuk item per kg (dalam kg)
  final String? _notes;
  final double _customPrice;

  LaundryItem({
    required String id,
    required ItemType itemType,
    int quantity = 1,
    double weight = 0.0,
    String? notes,
    double? customPrice,
  })  : _id = id,
        _itemType = itemType,
        _quantity = quantity,
        _weight = weight,
        _notes = notes,
        _customPrice = customPrice ?? itemType.basePrice;

  // Getters - Encapsulation
  @override
  String get id => _id;

  ItemType get itemType => _itemType;
  int get quantity => _quantity;
  double get weight => _weight;
  String? get notes => _notes;
  double get unitPrice => _customPrice;
  LaundryCategory get category => _itemType.category;
  String get displayName => _itemType.displayName;

  // Calculated properties
  double get totalPrice {
    if (_itemType.isPerKg) {
      return _customPrice * _weight; // harga per kg x berat
    } else {
      return _customPrice * _quantity; // harga per item x quantity
    }
  }

  /// Display quantity/weight untuk UI
  String get displayQuantity {
    if (_itemType.isPerKg) {
      return '${_weight.toStringAsFixed(_weight == _weight.roundToDouble() ? 0 : 1)} kg';
    } else {
      return '$_quantity pcs';
    }
  }

  /// Display unit price dengan format yang tepat
  String get formattedUnitPrice {
    return 'Rp ${_customPrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (match) => '${match[1]}.'
    )}/${_itemType.unitLabel}';
  }

  bool get hasNotes => _notes?.isNotEmpty ?? false;

  // Static method untuk mendapatkan items berdasarkan kategori
  static List<ItemType> getItemsByCategory(LaundryCategory category) {
    return ItemType.values.where((item) => item.category == category).toList();
  }

  // Factory constructors
  factory LaundryItem.fromMap(Map<String, dynamic> map) {
    return LaundryItem(
      id: map['id'] ?? '',
      itemType: ItemType.values.firstWhere(
        (type) => type.name == map['itemType'],
        orElse: () => ItemType.baju,
      ),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'],
      customPrice: (map['customPrice'] as num?)?.toDouble(),
    );
  }

  factory LaundryItem.fromJson(String source) =>
      LaundryItem.fromMap(json.decode(source));

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'itemType': _itemType.name,
      'quantity': _quantity,
      'weight': _weight,
      'notes': _notes,
      'customPrice': _customPrice,
    };
  }

  @override
  String toJson() => json.encode(toMap());

  @override
  LaundryItem copyWith({
    String? id,
    ItemType? itemType,
    int? quantity,
    double? weight,
    String? notes,
    double? customPrice,
  }) {
    return LaundryItem(
      id: id ?? _id,
      itemType: itemType ?? _itemType,
      quantity: quantity ?? _quantity,
      weight: weight ?? _weight,
      notes: notes ?? _notes,
      customPrice: customPrice ?? _customPrice,
    );
  }

  /// Copy dengan update quantity saja (untuk item non-kg)
  LaundryItem copyWithQuantity(int newQuantity) {
    return copyWith(quantity: newQuantity);
  }

  /// Copy dengan update weight saja (untuk item per kg)
  LaundryItem copyWithWeight(double newWeight) {
    return copyWith(weight: newWeight);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LaundryItem && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    if (_itemType.isPerKg) {
      return 'LaundryItem(id: $_id, type: ${_itemType.name}, weight: ${_weight}kg, price: $_customPrice)';
    } else {
      return 'LaundryItem(id: $_id, type: ${_itemType.name}, qty: $_quantity, price: $_customPrice)';
    }
  }
}