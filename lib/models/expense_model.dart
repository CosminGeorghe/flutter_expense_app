import '../database/app_database.dart';
import 'package:drift/drift.dart';

class ExpenseModel {
  int? id;

  int groupId;

  String title;

  int peopleCount;

  double total;

  double get splitAmount {
    if (peopleCount == 0) {
      return 0;
    }

    return total / peopleCount;
  }

  ExpenseModel({
    this.id,
    required this.groupId,
    required this.title,
    required this.peopleCount,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'people_count': peopleCount,
      'total': total,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      groupId: map['groupId'],
      title: map['title'],
      peopleCount: map['people_count'],
      total: map['total'],
    );
  }

  factory ExpenseModel.fromDb(Expense dbExpense) {
    return ExpenseModel(
      id: dbExpense.id,
      groupId: dbExpense.groupId!,
      title: dbExpense.title,
      peopleCount: dbExpense.peopleCount,
      total: dbExpense.total,
    );
  }

  ExpensesCompanion toCompanion() {
    return ExpensesCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      
      groupId: Value(groupId),

      title: Value(title),

      peopleCount: Value(peopleCount),

      total: Value(total),
    );
  }
}
