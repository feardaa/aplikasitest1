import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DebugHelper {
  
  static Future<void> printAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      print('=== SHARED PREFERENCES DEBUG ===');
      print('Total keys: ${keys.length}');
      
      for (final key in keys) {
        final value = prefs.getString(key);
        print('Key: $key');
        
        if (key == 'all_orders' && value != null) {
          try {
            final orders = json.decode(value) as List;
            print('Orders count: ${orders.length}');
            for (int i = 0; i < orders.length; i++) {
              final order = orders[i];
              print('  Order $i: ${order['id']} - ${order['service']['name']} - ${order['status']}');
            }
          } catch (e) {
            print('Error parsing orders: $e');
            print('Raw value: $value');
          }
        } else if (key == 'registered_users' && value != null) {
          try {
            final users = json.decode(value) as List;
            print('Users count: ${users.length}');
            for (int i = 0; i < users.length; i++) {
              final user = users[i];
              print('  User $i: ${user['username']} - ${user['email']}');
            }
          } catch (e) {
            print('Error parsing users: $e');
          }
        } else {
          print('Value: ${value?.substring(0, value.length > 100 ? 100 : value.length)}');
        }
        print('---');
      }
      print('===============================');
    } catch (e) {
      print('Error in printAllData: $e');
    }
  }

 
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('All SharedPreferences data cleared');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  static Future<void> addDummyOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('all_orders') ?? '[]';
      List<dynamic> ordersList = json.decode(ordersJson);
      
      final dummyOrder = {
        'id': 'dummy_${DateTime.now().millisecondsSinceEpoch}',
        'userId': 'test_user',
        'service': {
          'id': 'cuci-kering',
          'name': 'Cuci Kering',
          'description': 'Cuci bersih dan pengeringan sempurna',
          'icon': '👕',
          'color': 4280391411, 
          'category': 'pakaian',
          'multiplier': 1.0,
          'estimatedDays': 2,
          'isActive': true,
        },
        'items': [
          {
            'id': 'item_1',
            'itemType': 'baju',
            'quantity': 5,
            'notes': null,
            'customPrice': 3000.0,
          }
        ],
        'status': 'menunggu',
        'pickupInfo': {
          'address': 'Jl. Test No. 123',
          'phoneNumber': '081234567890',
          'notes': 'Test order from debug',
          'scheduledTime': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          'isPickupRequested': true,
          'isDeliveryRequested': true,
        },
        'totalPrice': 25000.0,
        'pickupFee': 5000.0,
        'deliveryFee': 5000.0,
        'specialNotes': 'Dummy order for testing',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': null,
        'completedAt': null,
      };
      
      ordersList.add(dummyOrder);
      await prefs.setString('all_orders', json.encode(ordersList));
      
      print('Dummy order added: ${dummyOrder['id']}');
    } catch (e) {
      print('Error adding dummy order: $e');
    }
  }
}