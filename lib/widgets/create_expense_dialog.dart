import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class CreateExpenseDialog extends StatefulWidget {
  const CreateExpenseDialog({super.key});

  @override
  State<CreateExpenseDialog> createState() => _CreateExpenseDialogState();
}

class _CreateExpenseDialogState extends State<CreateExpenseDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();

  final TextEditingController totalController = TextEditingController();

  final TextEditingController peopleController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    totalController.dispose();
    peopleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Expense"),

      content: SingleChildScrollView(
        child: SizedBox(
          width: 300,

          child: Form(
            key: _formKey,

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextFormField(
                  controller: titleController,

                  decoration: const InputDecoration(
                    labelText: "Expense Title",
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

                TextFormField(
                  controller: totalController,

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(
                    labelText: "Total",
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    final total = double.tryParse(value ?? "");

                    if (total == null || total <= 0) {
                      return "Enter valid total";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: peopleController,

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(
                    labelText: "Number of People",
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    final people = int.tryParse(value ?? "");

                    if (people == null || people <= 0) {
                      return "Enter valid number";
                    }

                    return null;
                  },
                ),
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

              ExpenseModel(
                title: titleController.text.trim(),

                peopleCount: int.parse(peopleController.text),

                total: double.parse(totalController.text),
              ),
            );
          },

          child: const Text("Create"),
        ),
      ],
    );
  }
}
