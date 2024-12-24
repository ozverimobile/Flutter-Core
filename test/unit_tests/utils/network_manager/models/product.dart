import 'package:flutter_core/flutter_core.dart';
import 'package:meta/meta.dart';

@immutable
final class Product extends BaseModel<Product> {
  const Product({
    this.id,
    this.name,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  final int? id;
  final String? name;

  @override
  Product fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
