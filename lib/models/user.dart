import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:aplikasitest1/models/base_model.dart';

/// User model dengan implementasi OOP dan  Implementasi: Encapsulation, Inheritance, Polymorphism

class User extends BaseModel implements Identifiable, Timestampable {
  final String _id;
  final String _username;
  final String _email;
  final String _phone;
  final String _password;
  final DateTime _createdAt;
  final DateTime? _updatedAt;

  User({
    required String id,
    required String username,
    required String email,
    required String phone,
    required String password,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : _id = id,
        _username = username,
        _email = email,
        _phone = phone,
        _password = password,
        _createdAt = createdAt ?? DateTime.now(),
        _updatedAt = updatedAt;

  
  @override
  String get id => _id;

  String get username => _username;

  String get email => _email;

  String get phone => _phone;

 
  String get _encryptedPassword => _password;

  @override
  DateTime get createdAt => _createdAt;

  @override
  DateTime? get updatedAt => _updatedAt;

 
  bool validatePassword(String inputPassword) {
    return _password == inputPassword;
  }

  /// Validasi password dengan hashing SHA256 (opsional)
  bool validateHashedPassword(String inputPassword) {
    final hashedInput = sha256.convert(utf8.encode(inputPassword)).toString();
    return _password == hashedInput;
  }

  /// Initial huruf dari username
  String get nameInitial {
    return _username.isNotEmpty ? _username[0].toUpperCase() : 'U';
  }

  /// Validasi format email
  bool get isEmailValid {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email);
  }

  /// Validasi format nomor telepon Indonesia
  bool get isPhoneValid {
    return RegExp(r'^(\+62|62|0)[0-9]{9,13}$').hasMatch(_phone.replaceAll(RegExp(r'[^\d+]'), ''));
  }

  /// Factory constructor dari Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      password: map['password'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  /// Factory constructor dari JSON string
  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  /// Konversi ke Map - Override dari BaseModel
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'username': _username,
      'email': _email,
      'phone': _phone,
      'password': _password,
      'createdAt': _createdAt.toIso8601String(),
      'updatedAt': _updatedAt?.toIso8601String(),
    };
  }

  /// Konversi ke JSON string
  String toJson() => json.encode(toMap());

  /// Implementasi copyWith - Immutable object pattern
  @override
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? _id,
      username: username ?? _username,
      email: email ?? _email,
      phone: phone ?? _phone,
      password: password ?? _password,
      createdAt: createdAt ?? _createdAt,
      updatedAt: updatedAt ?? _updatedAt,
    );
  }

  /// Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;
}