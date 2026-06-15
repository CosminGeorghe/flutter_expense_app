import '../database/app_database.dart';
import 'package:drift/drift.dart';

class PersonModel {
  int? id;

  int groupId;

  String name;

  PersonModel({
    this.id,
    required this.groupId,
    required this.name,
  });

  factory PersonModel.fromDb(Person dbPerson) {
    return PersonModel(
      id: dbPerson.id,
      groupId: dbPerson.groupId,
      name: dbPerson.name,
    );
  }

  PersonsCompanion toCompanion() {
    return PersonsCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      groupId: Value(groupId),
      name: Value(name),
    );
  }
}