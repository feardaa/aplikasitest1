import 'dart:convert';
import 'package:flutter/material.dart';
import 'base_model.dart';
import 'laundry_item.dart';

abstract class LaundryServiceBase extends BaseModel {
  String get name;
  String get description;
  String get icon;
  Color get color;
  LaundryCategory get category;
  
  double calculatePrice(List<LaundryItem> items);
  
    int getEstimatedDays();
}


class LaundryService extends LaundryServiceBase implements Identifiable {
  final String _id;
  final String _name;
  final String _description;
  final String _icon;
  final Color _color;
  final LaundryCategory _category;
  final double _multiplier;
  final int _estimatedDays;
  final bool _isActive;

  LaundryService({
    required String id,
    required String name,
    required String description,
    required String icon,
    required Color color,
    required LaundryCategory category,
    double multiplier = 1.0,
    int estimatedDays = 3,
    bool isActive = true,
  }) : _id = id,
       _name = name,
       _description = description,
       _icon = icon,
       _color = color,
       _category = category,
       _multiplier = multiplier,
       _estimatedDays = estimatedDays,
       _isActive = isActive;

  @override
  String get id => _id;
  
  @override
  String get name => _name;
  
  @override
  String get description => _description;
  
  @override
  String get icon => _icon;
  
  @override
  Color get color => _color;
  
  @override
  LaundryCategory get category => _category;
  
  double get multiplier => _multiplier;
  
  bool get isActive => _isActive;

 
  @override
  double calculatePrice(List<LaundryItem> items) {
    double totalPrice = 0;
    for (var item in items) {
      if (item.category == _category) {
        totalPrice += item.totalPrice * _multiplier;
      }
    }
    return totalPrice;
  }

  @override
  int getEstimatedDays() => _estimatedDays;

  static List<LaundryService> getDefaultServices() {
    return [
      LaundryService(
        id: 'cuci-kering',
        name: 'Cuci Kering',
        description: 'Cuci bersih dan pengeringan sempurna',
        icon: '👕',
        color: Colors.blue,
        category: LaundryCategory.pakaian,
        multiplier: 1.0,
        estimatedDays: 2,
      ),
      LaundryService(
        id: 'cuci-setrika',
        name: 'Cuci Setrika',
        description: 'Cuci bersih + setrika rapi',
        icon: '👔',
        color: Colors.indigo,
        category: LaundryCategory.pakaian,
        multiplier: 1.5,
        estimatedDays: 3,
      ),
      LaundryService( 
      id: 'cuci-tas',
      name: 'Cuci Tas', 
      description: 'Layanan Cuci Tas', 
      icon: '🎒', 
      color: Colors.deepPurple, 
      category: LaundryCategory.tas,
      multiplier: 1.5,
      estimatedDays:6,
      ),
      LaundryService(
        id: 'setrika-saja',
        name: 'Setrika Saja',
        description: 'Khusus layanan setrika',
        icon: '🔥',
        color: Colors.orange,
        category: LaundryCategory.setrika,
        multiplier: 0.8,
        estimatedDays: 1,
      ),
      LaundryService(
        id: 'cuci-sepatu',
        name: 'Cuci Sepatu',
        description: 'Pembersihan sepatu profesional',
        icon: '👟',
        color: Colors.green,
        category: LaundryCategory.sepatu,
        multiplier: 1.2,
        estimatedDays: 2,
      ),
      LaundryService(
        id: 'dry-clean',
        name: 'Dry Clean',
        description: 'Perawatan khusus pakaian premium',
        icon: '🤵',
        color: Colors.purple,
        category: LaundryCategory.kering,
        multiplier: 2.0,
        estimatedDays: 5,
      ),
      LaundryService(
        id: 'cuci-karpet',
        name: 'Cuci Karpet',
        description: 'Pembersihan mendalam karpet & korden',
        icon: '🏠',
        color: Colors.teal,
        category: LaundryCategory.karpet,
        multiplier: 1.3,
        estimatedDays: 4,
      ),
    ];
  }

  
  factory LaundryService.fromMap(Map<String, dynamic> map) {
    return LaundryService(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '👕',
      color: Color(map['color'] ?? Colors.blue.value),
      category: LaundryCategory.values.firstWhere(
        (cat) => cat.name == map['category'],
        orElse: () => LaundryCategory.pakaian,
      ),
      multiplier: map['multiplier']?.toDouble() ?? 1.0,
      estimatedDays: map['estimatedDays']?.toInt() ?? 3,
      isActive: map['isActive'] ?? true,
    );
  }

  factory LaundryService.fromJson(String source) => 
      LaundryService.fromMap(json.decode(source));

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'description': _description,
      'icon': _icon,
      'color': _color.value,
      'category': _category.name,
      'multiplier': _multiplier,
      'estimatedDays': _estimatedDays,
      'isActive': _isActive,
    };
  }

  @override
  LaundryService copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    Color? color,
    LaundryCategory? category,
    double? multiplier,
    int? estimatedDays,
    bool? isActive,
  }) {
    return LaundryService(
      id: id ?? _id,
      name: name ?? _name,
      description: description ?? _description,
      icon: icon ?? _icon,
      color: color ?? _color,
      category: category ?? _category,
      multiplier: multiplier ?? _multiplier,
      estimatedDays: estimatedDays ?? _estimatedDays,
      isActive: isActive ?? _isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LaundryService && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;
}
