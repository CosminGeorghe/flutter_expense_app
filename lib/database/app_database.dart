import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text()();

  RealColumn get total => real().withDefault(const Constant(0))();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get expenseId =>
      integer().references(Expenses, #id, onDelete: KeyAction.cascade)();

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

  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();
}

class ExpenseParticipants extends Table {
  IntColumn get expenseId =>
      integer().references(Expenses, #id, onDelete: KeyAction.cascade)();

  IntColumn get personId =>
      integer().references(Persons, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {expenseId, personId};
}

@DriftDatabase(
  tables: [Expenses, Products, Groups, Persons, ExpenseParticipants],
)
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
    return (delete(expenses)..where((e) => e.id.equals(expenseId))).go();
  }

  Future<List<Expense>> getExpensesForGroup(int groupId) {
    return (select(expenses)..where((e) => e.groupId.equals(groupId))).get();
  }

  Future<int> deleteExpensesForGroup(int groupId) {
    return (delete(expenses)..where((e) => e.groupId.equals(groupId))).go();
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

  Future<int> insertGroup(GroupsCompanion group) {
    return into(groups).insert(group);
  }

  Future<List<Group>> getAllGroups() async {
    return (select(groups)..orderBy([(g) => OrderingTerm.desc(g.id)])).get();
  }

  Future<int> deleteGroup(int groupId) {
    return (delete(groups)..where((g) => g.id.equals(groupId))).go();
  }

  Future<bool> updateGroup(GroupsCompanion group) {
    return update(groups).replace(group);
  }

  Future<Group?> getGroupById(int groupId) {
    return (select(
      groups,
    )..where((g) => g.id.equals(groupId))).getSingleOrNull();
  }

  Future<int> insertPerson(PersonsCompanion person) {
    return into(persons).insert(person);
  }

  Future<List<Person>> getPersonsForGroup(int groupId) {
    return (select(persons)..where((p) => p.groupId.equals(groupId))).get();
  }

  Future<Person?> getPersonById(int personId) {
    return (select(
      persons,
    )..where((p) => p.id.equals(personId))).getSingleOrNull();
  }

  Future<bool> updatePerson(PersonsCompanion person) {
    return update(persons).replace(person);
  }

  Future<int> deletePerson(int personId) {
    return (delete(persons)..where((p) => p.id.equals(personId))).go();
  }

  Future<int> deletePersonsForGroup(int groupId) {
    return (delete(persons)..where((p) => p.groupId.equals(groupId))).go();
  }

  Future<int> insertExpenseParticipant(
    ExpenseParticipantsCompanion participant,
  ) {
    return into(expenseParticipants).insert(participant);
  }

  Future<List<ExpenseParticipant>> getParticipantsForExpense(int expenseId) {
    return (select(
      expenseParticipants,
    )..where((p) => p.expenseId.equals(expenseId))).get();
  }

  Future<int> deleteExpenseParticipant({
    required int expenseId,
    required int personId,
  }) {
    return (delete(expenseParticipants)..where(
          (p) => p.expenseId.equals(expenseId) & p.personId.equals(personId),
        ))
        .go();
  }

  Future<int> deleteParticipantsForExpense(int expenseId) {
    return (delete(
      expenseParticipants,
    )..where((p) => p.expenseId.equals(expenseId))).go();
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
