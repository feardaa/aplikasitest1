// utils/validator.dart
class AppValidators {
  // Format currency untuk display
  static String formatCurrency(double amount) {
    return 'Rp ${amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (match) => '${match[1]}.'
    )}';
  }

  // Format nomor telepon Indonesia
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Format based on Indonesian phone number patterns
    if (cleaned.startsWith('+62')) {
      return '+62 ${cleaned.substring(3, 6)}-${cleaned.substring(6, 10)}-${cleaned.substring(10)}';
    } else if (cleaned.startsWith('62')) {
      return '+62 ${cleaned.substring(2, 5)}-${cleaned.substring(5, 9)}-${cleaned.substring(9)}';
    } else if (cleaned.startsWith('0')) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    }
    
    return phone; // Return original if no pattern matches
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate Indonesian phone number
  static bool isValidPhoneNumber(String phone) {
    final cleanNumber = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return RegExp(r'^(\+62|62|0)[0-9]{9,13}$').hasMatch(cleanNumber);
  }

  // Format weight display
  static String formatWeight(double weight) {
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

  // Validate weight input
  static bool isValidWeight(double weight) {
    return weight > 0 && weight <= 50; // Max 50kg per item
  }

  // Format date display
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Format datetime display
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}