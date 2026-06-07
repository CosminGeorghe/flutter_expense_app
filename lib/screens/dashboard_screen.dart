import 'package:flutter/material.dart';
import '../widgets/create_expense_dialog.dart';
import '../models/expense_model.dart';
import 'expense_screen.dart';
import '../database/database_provider.dart';
import '../widgets/custom_confirmation_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ExpenseModel> expenses = [];

  final Set<int> expandedExpenses = {};

  Future<void> loadExpenses() async {
    final dbExpenses = await database.getAllExpenses();

    final loadedExpenses = dbExpenses.map((dbExpense) {
      return ExpenseModel.fromDb(dbExpense);
    }).toList();

    setState(() {
      expenses = loadedExpenses;
    });
  }

  @override
  void initState() {
    super.initState();

    loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Groups")),

      body: Column(
        children: [
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

                    builder: (_) => const CreateExpenseDialog(),
                  );

                  if (result == null) {
                    return;
                  }

                  final ExpenseModel expense = result;

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
