import 'package:flutter/material.dart';
import '../models/person_model.dart';

class CreatePersonDialog extends StatefulWidget {
  final int groupId;

  const CreatePersonDialog({super.key, required this.groupId});

  @override
  State<CreatePersonDialog> createState() => _CreatePersonDialogState();
}

class _CreatePersonDialogState extends State<CreatePersonDialog> {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Person'),

      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Name'),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty) {
              return;
            }

            Navigator.pop(
              context,
              PersonModel(
                groupId: widget.groupId,
                name: nameController.text.trim(),
              ),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
