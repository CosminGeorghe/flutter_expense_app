import '../database/app_database.dart';
import 'package:drift/drift.dart';

class ProductModel {
  int? id;

  int? expenseId;

  String name;

  double price;

  int quantity;

  ProductModel({
    this.id,
    this.expenseId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_id': expenseId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      expenseId: map['expense_id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  factory ProductModel.fromDb(Product dbProduct) {
    return ProductModel(
      id: dbProduct.id,
      expenseId: dbProduct.expenseId,
      name: dbProduct.name,
      price: dbProduct.price,
      quantity: dbProduct.quantity,
    );
  }

  ProductsCompanion toCompanion() {
    return ProductsCompanion(
      id: id == null ? const Value.absent() : Value(id!),

      expenseId: expenseId == null ? const Value.absent() : Value(expenseId!),

      name: Value(name),
      price: Value(price),
      quantity: Value(quantity),
    );
  }
}
