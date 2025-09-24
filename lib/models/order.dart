// models/order.dart
import 'dart:convert';
import 'base_model.dart';
import 'laundry_item.dart';
import 'laundry_service.dart';

/// Enum untuk status pesanan
enum OrderStatus {
  menunggu('Menunggu', 'Pesanan sedang menunggu konfirmasi', 'menunggu'),
  dikonfirmasi('Dikonfirmasi', 'Pesanan telah dikonfirmasi', 'dikonfirmasi'),
  dijemput('Dijemput', 'Pakaian sedang dijemput', 'dijemput'),
  diproses('Diproses', 'Sedang dalam proses laundry', 'diproses'),
  selesai('Selesai', 'Laundry telah selesai', 'selesai'),
  dikirim('Dikirim', 'Sedang dalam pengiriman', 'dikirim'),
  diterima('Diterima', 'Pesanan telah diterima customer', 'diterima'),
  dibatalkan('Dibatalkan', 'Pesanan dibatalkan', 'dibatalkan');

  const OrderStatus(this.displayName, this.description, this.label);
  final String displayName;
  final String description;
  final String label;
}

/// Model untuk informasi pickup/delivery
/// Implementasi: Encapsulation, Composition
class PickupInfo extends BaseModel {
  final String _address;
  final String _phoneNumber;
  final String _notes;
  final DateTime _scheduledTime;
  final bool _isPickupRequested;
  final bool _isDeliveryRequested;

  PickupInfo({
    required String address,
    required String phoneNumber,
    String notes = '',
    required DateTime scheduledTime,
    bool isPickupRequested = true,
    bool isDeliveryRequested = true,
  }) : _address = address,
       _phoneNumber = phoneNumber,
       _notes = notes,
       _scheduledTime = scheduledTime,
       _isPickupRequested = isPickupRequested,
       _isDeliveryRequested = isDeliveryRequested;


  String get address => _address;
  String get phoneNumber => _phoneNumber;
  String get notes => _notes;
  DateTime get scheduledTime => _scheduledTime;
  bool get isPickupRequested => _isPickupRequested;
  bool get isDeliveryRequested => _isDeliveryRequested;

  factory PickupInfo.fromMap(Map<String, dynamic> map) {
    return PickupInfo(
      address: map['address'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      notes: map['notes'] ?? '',
      scheduledTime: DateTime.parse(map['scheduledTime']),
      isPickupRequested: map['isPickupRequested'] ?? true,
      isDeliveryRequested: map['isDeliveryRequested'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'address': _address,
      'phoneNumber': _phoneNumber,
      'notes': _notes,
      'scheduledTime': _scheduledTime.toIso8601String(),
      'isPickupRequested': _isPickupRequested,
      'isDeliveryRequested': _isDeliveryRequested,
    };
  }

  @override
  PickupInfo copyWith({
    String? address,
    String? phoneNumber,
    String? notes,
    DateTime? scheduledTime,
    bool? isPickupRequested,
    bool? isDeliveryRequested,
  }) {
    return PickupInfo(
      address: address ?? _address,
      phoneNumber: phoneNumber ?? _phoneNumber,
      notes: notes ?? _notes,
      scheduledTime: scheduledTime ?? _scheduledTime,
      isPickupRequested: isPickupRequested ?? _isPickupRequested,
      isDeliveryRequested: isDeliveryRequested ?? _isDeliveryRequested,
    );
  }
}

/// Model untuk pesanan laundry
/// Implementasi: Inheritance, Encapsulation, Composition
class Order extends BaseModel implements Identifiable, Timestampable {
  final String _id;
  final String _userId;
  final LaundryService _service;
  final List<LaundryItem> _items;
  final OrderStatus _status;
  final PickupInfo _pickupInfo;
  final double _totalPrice;
  final double _pickupFee;
  final double _deliveryFee;
  final String _specialNotes;
  final DateTime _createdAt;
  final DateTime? _updatedAt;
  final DateTime? _completedAt;

  Order({
    required String id,
    required String userId,
    required LaundryService service,
    required List<LaundryItem> items,
    OrderStatus status = OrderStatus.menunggu,
    required PickupInfo pickupInfo,
    double pickupFee = 1000,
    double deliveryFee = 2000,
    String specialNotes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) : _id = id,
       _userId = userId,
       _service = service,
       _items = List.unmodifiable(items),
       _status = status,
       _pickupInfo = pickupInfo,
       _totalPrice = _calculateTotalPrice(
         service,
         items,
         pickupFee,
         deliveryFee,
       ),
       _pickupFee = pickupFee,
       _deliveryFee = deliveryFee,
       _specialNotes = specialNotes,
       _createdAt = createdAt ?? DateTime.now(),
       _updatedAt = updatedAt,
       _completedAt = completedAt;

  static double _calculateTotalPrice(
    LaundryService service,
    List<LaundryItem> items,
    double pickupFee,
    double deliveryFee,
  ) {
    double itemsPrice = service.calculatePrice(items);
    return itemsPrice + pickupFee + deliveryFee;
  }

  // Getters - Implementasi Encapsulation
  @override
  String get id => _id;

  String get userId => _userId;

  LaundryService get service => _service;

  List<LaundryItem> get items => _items;

  OrderStatus get status => _status;

  PickupInfo get pickupInfo => _pickupInfo;

  double get totalPrice => _totalPrice;

  double get pickupFee => _pickupFee;

  double get deliveryFee => _deliveryFee;

  double get itemsPrice => _service.calculatePrice(_items);

  String get specialNotes => _specialNotes;

  @override
  DateTime get createdAt => _createdAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  DateTime? get completedAt => _completedAt;

  // Added getter for date (alias for createdAt)
  DateTime get date => _createdAt;

  // Calculated properties
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  bool get isCompleted => _status == OrderStatus.diterima;

  bool get isCancelled => _status == OrderStatus.dibatalkan;

  bool get canBeCancelled =>
      _status == OrderStatus.menunggu || _status == OrderStatus.dikonfirmasi;

  int get estimatedDays => _service.getEstimatedDays();

  DateTime get estimatedCompletionDate =>
      _createdAt.add(Duration(days: estimatedDays));

  // Business logic methods
  bool canUpdateStatus(OrderStatus newStatus) {
    // Define valid status transitions
    Map<OrderStatus, List<OrderStatus>> validTransitions = {
      OrderStatus.menunggu: [OrderStatus.dikonfirmasi, OrderStatus.dibatalkan],
      OrderStatus.dikonfirmasi: [OrderStatus.dijemput, OrderStatus.dibatalkan],
      OrderStatus.dijemput: [OrderStatus.diproses],
      OrderStatus.diproses: [OrderStatus.selesai],
      OrderStatus.selesai: [OrderStatus.dikirim],
      OrderStatus.dikirim: [OrderStatus.diterima],
    };

    return validTransitions[_status]?.contains(newStatus) ?? false;
  }

  Order updateStatus(OrderStatus newStatus) {
    if (!canUpdateStatus(newStatus)) {
      throw ArgumentError(
        'Invalid status transition from $_status to $newStatus',
      );
    }

    DateTime? completed = newStatus == OrderStatus.diterima
        ? DateTime.now()
        : _completedAt;

    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      completedAt: completed,
    );
  }

  // Factory constructors
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      service: LaundryService.fromMap(map['service']),
      items: List<LaundryItem>.from(
        map['items']?.map((x) => LaundryItem.fromMap(x)) ?? [],
      ),
      status: OrderStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => OrderStatus.menunggu,
      ),
      pickupInfo: PickupInfo.fromMap(map['pickupInfo']),
      pickupFee: map['pickupFee']?.toDouble() ?? 5000,
      deliveryFee: map['deliveryFee']?.toDouble() ?? 5000,
      specialNotes: map['specialNotes'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'userId': _userId,
      'service': _service.toMap(),
      'items': _items.map((x) => x.toMap()).toList(),
      'status': _status.name,
      'pickupInfo': _pickupInfo.toMap(),
      'totalPrice': _totalPrice,
      'pickupFee': _pickupFee,
      'deliveryFee': _deliveryFee,
      'specialNotes': _specialNotes,
      'createdAt': _createdAt.toIso8601String(),
      'updatedAt': _updatedAt?.toIso8601String(),
      'completedAt': _completedAt?.toIso8601String(),
    };
  }

  @override
  Order copyWith({
    String? id,
    String? userId,
    LaundryService? service,
    List<LaundryItem>? items,
    OrderStatus? status,
    PickupInfo? pickupInfo,
    double? pickupFee,
    double? deliveryFee,
    String? specialNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? _id,
      userId: userId ?? _userId,
      service: service ?? _service,
      items: items ?? _items,
      status: status ?? _status,
      pickupInfo: pickupInfo ?? _pickupInfo,
      pickupFee: pickupFee ?? _pickupFee,
      deliveryFee: deliveryFee ?? _deliveryFee,
      specialNotes: specialNotes ?? _specialNotes,
      createdAt: createdAt ?? _createdAt,
      updatedAt: updatedAt ?? _updatedAt,
      completedAt: completedAt ?? _completedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;
}