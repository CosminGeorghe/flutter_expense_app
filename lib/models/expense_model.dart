import '../database/app_database.dart';
import 'package:drift/drift.dart';

class ExpenseModel {
  int? id;

  int groupId;

  String title;

  double total;

  ExpenseModel({
    this.id,
    required this.groupId,
    required this.title,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'total': total,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      groupId: map['groupId'],
      title: map['title'],
      total: map['total'],
    );
  }

  factory ExpenseModel.fromDb(Expense dbExpense) {
    return ExpenseModel(
      id: dbExpense.id,
      groupId: dbExpense.groupId,
      title: dbExpense.title,
      total: dbExpense.total,
    );
  }

  ExpensesCompanion toCompanion() {
    return ExpensesCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      
      groupId: Value(groupId),

      title: Value(title),

      total: Value(total),
    );
  }
}
