import '../database/app_database.dart';
import 'package:drift/drift.dart';

class GroupModel {
  int? id;

  String name;

  GroupModel({
    this.id,
    required this.name,
  });

  factory GroupModel.fromDb(Group group) {
    return GroupModel(
      id: group.id,
      name: group.name,
    );
  }

  GroupsCompanion toCompanion() {
    return GroupsCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      name: Value(name),
    );
  }
}