// services/order_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderService {
  static const String _ordersKey = 'all_orders';

  /// Simpan order baru
  Future<Order> createOrder(Order order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey) ?? '[]';
      List<dynamic> ordersList = json.decode(ordersJson);
      
      // Tambahkan order baru
      ordersList.add(order.toMap());
      
      // Simpan kembali ke SharedPreferences
      await prefs.setString(_ordersKey, json.encode(ordersList));
      
      print('Order saved: ${order.id}');
      return order;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  /// Ambil semua orders (untuk admin)
  Future<List<Order>> getAllOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey) ?? '[]';
      final List<dynamic> ordersList = json.decode(ordersJson);
      
      final orders = ordersList.map((orderData) => Order.fromMap(orderData)).toList();
      
      // Urutkan berdasarkan tanggal terbaru
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('Loaded ${orders.length} orders for admin');
      return orders;
    } catch (e) {
      print('Error loading all orders: $e');
      return [];
    }
  }

  /// Ambil orders berdasarkan userId (untuk user)
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final allOrders = await getAllOrders();
      final userOrders = allOrders.where((order) => order.userId == userId).toList();
      
      print('Loaded ${userOrders.length} orders for user $userId');
      return userOrders;
    } catch (e) {
      print('Error loading user orders: $e');
      return [];
    }
  }

  /// Update status order
  Future<Order> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey) ?? '[]';
      List<dynamic> ordersList = json.decode(ordersJson);
      
      // Cari dan update order
      for (int i = 0; i < ordersList.length; i++) {
        final orderData = ordersList[i];
        if (orderData['id'] == orderId) {
          final order = Order.fromMap(orderData);
          final updatedOrder = order.updateStatus(newStatus);
          ordersList[i] = updatedOrder.toMap();
          
          // Simpan kembali
          await prefs.setString(_ordersKey, json.encode(ordersList));
          
          print('Order status updated: $orderId -> ${newStatus.displayName}');
          return updatedOrder;
        }
      }
      
      throw Exception('Order not found');
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  /// Delete order (untuk testing)
  Future<void> deleteOrder(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey) ?? '[]';
      List<dynamic> ordersList = json.decode(ordersJson);
      
      ordersList.removeWhere((orderData) => orderData['id'] == orderId);
      
      await prefs.setString(_ordersKey, json.encode(ordersList));
      print('Order deleted: $orderId');
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }

  /// Clear all orders (untuk testing)
  Future<void> clearAllOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ordersKey);
      print('All orders cleared');
    } catch (e) {
      print('Error clearing orders: $e');
    }
  }
}