import 'package:flutter/material.dart';
import '../widgets/create_expense_dialog.dart';
import '../models/expense_model.dart';
import '../models/person_model.dart';
import 'expense_screen.dart';
import '../database/database_provider.dart';
import '../widgets/custom_confirmation_dialog.dart';
import '../widgets/create_person_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  final int groupId;

  const ExpensesScreen({super.key, required this.groupId});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<ExpenseModel> expenses = [];

  List<PersonModel> persons = [];

  final Set<int> expandedExpenses = {};

  Future<void> loadExpenses() async {
    final dbExpenses = await database.getExpensesForGroup(widget.groupId);

    final loadedExpenses = dbExpenses.map((dbExpense) {
      return ExpenseModel.fromDb(dbExpense);
    }).toList();

    setState(() {
      expenses = loadedExpenses;
    });
  }

  Future<void> loadPersons() async {
    final dbPersons = await database.getPersonsForGroup(widget.groupId);

    final loadedPersons = dbPersons.map(PersonModel.fromDb).toList();

    setState(() {
      persons = loadedPersons;
    });
  }

  @override
  void initState() {
    super.initState();

    loadExpenses();
    loadPersons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),

      body: Column(
        children: [
          const Text('People', style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 8),

          Column(
            children: persons.map((person) {
              final controller = TextEditingController(text: person.name);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),

                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,

                        onChanged: (value) async {
                          person.name = value;

                          await database.updatePerson(person.toCompanion());
                        },

                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      icon: const Icon(Icons.delete),

                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,

                          builder: (_) => CustomConfirmationDialog(
                            title: 'Delete Person',
                            message:
                                'Are you sure you want to delete "${person.name}"?',
                          ),
                        );

                        if (confirmed == true) {
                          await database.deletePerson(person.id!);

                          await loadPersons();
                        }
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          ElevatedButton(
            onPressed: () async {
              final PersonModel? result = await showDialog<PersonModel>(
                context: context,
                builder: (_) => CreatePersonDialog(groupId: widget.groupId),
              );

              if (result == null) {
                return;
              }

              await database.insertPerson(result.toCompanion());

              await loadPersons();
            },
            child: const Text('Add Person'),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,

              itemBuilder: (context, index) {
                final expense = expenses[index];

                return Card(
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: ValueKey(expense.id),

                      initiallyExpanded: expandedExpenses.contains(expense.id),

                      onExpansionChanged: (expanded) {
                        setState(() {
                          if (expanded) {
                            expandedExpenses.add(expense.id!);
                          } else {
                            expandedExpenses.remove(expense.id);
                          }
                        });
                      },

                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Expanded(
                            child: Text(
                              expense.title,

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),

                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "${expense.total.toStringAsFixed(2)} RON",

                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text("People: ${expense.peopleCount}"),

                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => CustomConfirmationDialog(
                                          title: 'Delete Expense',
                                          message:
                                              'Are you sure you want to delete "${expense.title}"?',
                                        ),
                                      );
                                      if (confirmed == true) {
                                        expandedExpenses.remove(expense.id);
                                        await database.deleteExpense(
                                          expense.id!,
                                        );
                                        await loadExpenses();
                                      }
                                    },

                                    child: const Text("Delete Expense"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder: (_) => ExpenseScreen(
                                            expenseId: expense.id!,
                                          ),
                                        ),
                                      );
                                      await loadExpenses();
                                    },

                                    child: const Text("Open Expense"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () async {
                  final ExpenseModel? result = await showDialog<ExpenseModel>(
                    context: context,

                    builder: (_) =>
                        CreateExpenseDialog(groupId: widget.groupId),
                  );

                  if (result == null) {
                    return;
                  }

                  final ExpenseModel expense = result;
                  expense.groupId = widget.groupId;

                  await database.insertExpense(expense.toCompanion());

                  await loadExpenses();
                },

                child: const Text("Create Expense"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
