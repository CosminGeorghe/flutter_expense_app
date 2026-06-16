import 'package:flutter/material.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';
import '../models/person_model.dart';

class ManageParticipantsDialog extends StatefulWidget {
  final int expenseId;
  final int groupId;

  const ManageParticipantsDialog({
    super.key,
    required this.expenseId,
    required this.groupId,
  });

  @override
  State<ManageParticipantsDialog> createState() =>
      _ManageParticipantsDialogState();
}

class _ManageParticipantsDialogState extends State<ManageParticipantsDialog> {
  List<PersonModel> persons = [];
  Set<int> selectedPersonIds = {};
  Set<int> originalPersonIds = {};

  Future<void> loadData() async {
    final dbPersons = await database.getPersonsForGroup(widget.groupId);

    final dbParticipants = await database.getParticipantsForExpense(
      widget.expenseId,
    );

    setState(() {
      persons = dbPersons.map(PersonModel.fromDb).toList();

      selectedPersonIds = dbParticipants.map((p) => p.personId).toSet();
      originalPersonIds = Set.from(selectedPersonIds);
    });
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Participants'),

      content: SizedBox(
        width: double.maxFinite,

        child: ListView(
          shrinkWrap: true,

          children: persons.map((person) {
            return CheckboxListTile(
              value: selectedPersonIds.contains(person.id),

              title: Text(person.name),

              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selectedPersonIds.add(person.id!);
                  } else {
                    selectedPersonIds.remove(person.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },

          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final toDelete = originalPersonIds.difference(selectedPersonIds);

            final toInsert = selectedPersonIds.difference(originalPersonIds);

            for (final personId in toDelete) {
              await database.deleteExpenseParticipant(
                expenseId: widget.expenseId,
                personId: personId,
              );
            }

            for (final personId in toInsert) {
              await database.insertExpenseParticipant(
                ExpenseParticipantsCompanion.insert(
                  expenseId: widget.expenseId,
                  personId: personId,
                ),
              );
            }

            if (!context.mounted) return;

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
