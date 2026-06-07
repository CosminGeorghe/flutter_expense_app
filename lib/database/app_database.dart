import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get groupId => integer().nullable()();

  TextColumn get title => text()();

  IntColumn get peopleCount => integer()();

  RealColumn get total => real().withDefault(const Constant(0))();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get expenseId => integer().references(Expenses, #id)();

  TextColumn get name => text()();

  RealColumn get price => real()();

  IntColumn get quantity => integer()();
}

class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();
}

class Persons extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get groupId => integer().nullable().references(Groups, #id)();

  TextColumn get name => text()();
}

@DriftDatabase(tables: [Expenses, Products, Groups, Persons])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(expenses, expenses.total);
      }
      if (from < 3) {
        await m.addColumn(expenses, expenses.groupId);

        await m.createTable(groups);
        await m.createTable(persons);
      }
    },
  );

  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  Future<List<Expense>> getAllExpenses() async {
    return (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.id)])).get();
  }

  Future<bool> updateExpense(ExpensesCompanion expense) {
    return update(expenses).replace(expense);
  }

  Future<Expense?> getExpenseById(int expenseId) {
    return (select(
      expenses,
    )..where((e) => e.id.equals(expenseId))).getSingleOrNull();
  }

  Future<int> deleteExpense(int expenseId) async {
    await deleteProductsForExpense(expenseId);
    return (delete(expenses)..where((e) => e.id.equals(expenseId))).go();
  }

  Future<int> insertProduct(ProductsCompanion product) {
    return into(products).insert(product);
  }

  Future<List<Product>> getProductsForExpense(int expenseId) {
    return (select(
      products,
    )..where((p) => p.expenseId.equals(expenseId))).get();
  }

  Future<bool> updateProduct(ProductsCompanion product) {
    return update(products).replace(product);
  }

  Future<int> deleteProduct(int productId) {
    return (delete(products)..where((p) => p.id.equals(productId))).go();
  }

  Future<int> deleteProductsForExpense(int expenseId) {
    return (delete(products)..where((p) => p.expenseId.equals(expenseId))).go();
  }
}

// LazyDatabase _openConnection() {
//   return LazyDatabase(() async {
//     final dbFolder = await getApplicationDocumentsDirectory();

//     final file = File(p.join(dbFolder.path, 'app.sqlite'));

//     return NativeDatabase(file);
//   });
// }

QueryExecutor _openConnection() {
  return driftDatabase(name: 'app_database');
}
