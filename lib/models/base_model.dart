import 'dart:convert';

abstract class BaseModel {
  Map<String, dynamic> toMap();
  
  String toJson() => json.encode(toMap());
  
  @override
  String toString() => toJson();
  
  BaseModel copyWith();
}

abstract class Identifiable {
  String get id;
}

abstract class Timestampable {
  DateTime get createdAt;
  DateTime? get updatedAt;
}