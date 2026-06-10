import 'package:flutter/material.dart';
import '../models/group_model.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameContoller = TextEditingController();

  @override
  void dispose() {
    nameContoller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Group"),

      content: SingleChildScrollView(
        child: SizedBox(
          width: 300,

          child: Form(
            key: _formKey,

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextFormField(
                  controller: nameContoller,

                  decoration: const InputDecoration(
                    labelText: "Group name",
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a title";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },

          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.pop(
              context,

              GroupModel(
                name: nameContoller.text.trim(),
              ),
            );
          },

          child: const Text("Create"),
        ),
      ],
    );
  }
}
