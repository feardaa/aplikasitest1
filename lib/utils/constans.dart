import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'LaundryKu';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Solusi laundry terpercaya untuk kebutuhan Anda';


  static const String baseUrl = 'https://api.laundryku.com';
  static const String apiVersion = 'v1';
  static const Duration requestTimeout = Duration(seconds: 30);


  static const String userKey = 'current_user';
  static const String usersKey = 'registered_users';
  static const String ordersKey = 'orders_data';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';


  static const double defaultPickupFee = 5000.0;
  static const double defaultDeliveryFee = 5000.0;
  static const int defaultEstimatedDays = 3;
  static const int maxItemsPerOrder = 50;
  static const double maxOrderValue = 10000000.0; // 10 juta
  static const int maxAddressLength = 200;
  static const int maxNotesLength = 500;


  static const int openHour = 8;
  static const int closeHour = 20;
  static const List<int> workingDays = [1, 2, 3, 4, 5, 6]; // Monday to Saturday


  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;


  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(seconds: 5);


  static const int itemsPerPage = 20;
  static const int maxSearchResults = 100;
}

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3F51B5); // Indigo
  static const Color primaryLight = Color(0xFF7986CB);
  static const Color primaryDark = Color(0xFF303F9F);

  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF66FFF9);
  static const Color secondaryDark = Color(0xFF00A896);


  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  static const Map<String, Color> serviceColors = {
    'cuci_pakaian': Color(0xFF2196F3),
    'cuci_tas': Color(0xFF4CAF50),     
    'cuci_sepatu': Color(0xFFFF9800), 
    'cuci_kering': Color(0xFF9C27B0), 
    'setrika': Color(0xFFFF5722),     
    'cuci_karpet': Color(0xFF009688),  
  };


  static const Map<String, Color> statusColors = {
    'menunggu': Color(0xFFFF9800),    
    'dikonfirmasi': Color(0xFF2196F3),
    'dijemput': Color(0xFF9C27B0),     
    'diproses': Color(0xFF673AB7),     
    'selesai': Color(0xFF3F51B5),      
    'dikirim': Color(0xFF1976D2),      
    'diterima': Color(0xFF4CAF50),     
    'dibatalkan': Color(0xFFF44336),   
  };
}


class AppTypography {
  AppTypography._();

  
  static const String primaryFont = 'Roboto';
  static const String secondaryFont = 'Poppins';


  static const double heading1 = 32.0;
  static const double heading2 = 24.0;
  static const double heading3 = 20.0;
  static const double heading4 = 18.0;
  static const double heading5 = 16.0;
  static const double heading6 = 14.0;
  
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  
  static const double caption = 10.0;
  static const double button = 14.0;


  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

 
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

 
  static const EdgeInsets marginXS = EdgeInsets.all(xs);
  static const EdgeInsets marginSM = EdgeInsets.all(sm);
  static const EdgeInsets marginMD = EdgeInsets.all(md);
  static const EdgeInsets marginLG = EdgeInsets.all(lg);
  static const EdgeInsets marginXL = EdgeInsets.all(xl);


  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 999.0;
}


class AppSizes {
  AppSizes._();


  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

 
  static const double buttonHeightSM = 32.0;
  static const double buttonHeightMD = 40.0;
  static const double buttonHeightLG = 48.0;
  static const double buttonHeightXL = 56.0;

  
  static const double inputHeight = 48.0;
  static const double inputHeightSM = 40.0;
  static const double inputHeightLG = 56.0;


  static const double cardElevation = 2.0;
  static const double cardElevationHover = 8.0;

 
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;


  static const double bottomSheetMaxHeight = 0.9;
  static const double bottomSheetBorderRadius = 16.0;

 
  static const double appBarHeight = 56.0;
  static const double appBarExpandedHeight = 200.0;
}


class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail';
  static const String orderTracking = '/order-tracking';
  static const String laundryOrder = '/laundry-order';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';
  static const String about = '/about';
  static const String help = '/help';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
}


class AppErrorMessages {
  AppErrorMessages._();
  // Auth Errors
  static const String invalidCredentials = 'Username atau password salah';
  static const String userNotFound = 'User tidak ditemukan';
  static const String usernameAlreadyExists = 'Username sudah digunakan';
  static const String weakPassword = 'Password terlalu lemah';
  static const String invalidEmail = 'Format email tidak valid';
  static const String invalidPhone = 'Format nomor telepon tidak valid';


  static const String noInternetConnection = 'Tidak ada koneksi internet';
  static const String serverError = 'Terjadi kesalahan pada server';
  static const String requestTimeout = 'Request timeout, coba lagi';
  static const String unknownError = 'Terjadi kesalahan yang tidak diketahui';

 
  static const String fieldRequired = 'Field ini harus diisi';
  static const String passwordTooShort = 'Password minimal 6 karakter';
  static const String usernameTooShort = 'Username minimal 3 karakter';
  static const String phoneInvalid = 'Nomor telepon tidak valid';
  static const String emailInvalid = 'Format email tidak valid';

 
  static const String orderNotFound = 'Pesanan tidak ditemukan';
  static const String cannotCancelOrder = 'Pesanan tidak dapat dibatalkan';
  static const String orderAlreadyCompleted = 'Pesanan sudah selesai';
  static const String invalidOrderStatus = 'Status pesanan tidak valid';
  static const String noItemsSelected = 'Pilih minimal satu item';
  static const String addressRequired = 'Alamat harus diisi';
  static const String phoneRequired = 'Nomor telepon harus diisi';
}


class AppSuccessMessages {
  AppSuccessMessages._();

  static const String loginSuccess = 'Berhasil login';
  static const String registerSuccess = 'Registrasi berhasil';
  static const String logoutSuccess = 'Berhasil logout';
  static const String profileUpdated = 'Profil berhasil diperbarui';
  static const String passwordChanged = 'Password berhasil diubah';
  static const String orderCreated = 'Pesanan berhasil dibuat';
  static const String orderUpdated = 'Pesanan berhasil diperbarui';
  static const String orderCancelled = 'Pesanan berhasil dibatalkan';
  static const String itemAdded = 'Item berhasil ditambahkan';
  static const String itemRemoved = 'Item berhasil dihapus';
  static const String itemUpdated = 'Item berhasil diperbarui';
}