import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/expense_model.dart';
import '../widgets/product_row.dart';
import '../database/database_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/openai_vision_receipt_parser_service.dart';
import '../widgets/receipt_import_dialog.dart';
import '../widgets/manage_participants_dialog.dart';
import '../services/image_compression_service.dart';
import 'dart:convert';

class ExpenseScreen extends StatefulWidget {
  final int expenseId;

  const ExpenseScreen({super.key, required this.expenseId});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  ExpenseModel? expense;

  List<ProductModel> products = [];

  bool isEditingTitle = false;

  late final TextEditingController titleController;

  final TextEditingController totalController = TextEditingController();

  final imagePicker = ImagePicker();

  final visionParser = OpenAiVisionReceiptParserService();

  bool isImportingReceipt = false;

  Future<void> importReceipt() async {
    setState(() {
      isImportingReceipt = true;
    });

    try {
      final image = await imagePicker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        return;
      }

      final compressor = ImageCompressionService();

      final compressedImage = await compressor.compress(image.path);
      print(compressedImage.path);

      final result = await visionParser.parseImage(compressedImage.path);

      final List<dynamic> jsonProducts = jsonDecode(result);

      final parsedProducts = jsonProducts.map((jsonProduct) {
        return ProductModel(
          expenseId: widget.expenseId,
          name: jsonProduct['name'],
          quantity: jsonProduct['quantity'],
          price: (jsonProduct['unitPrice'] as num).toDouble(),
        );
      }).toList();

      if (!mounted) return;

      final shouldImport = await showDialog<bool>(
        context: context,
        builder: (_) => ReceiptImportDialog(products: parsedProducts),
      );
      if (shouldImport == true) {
        for (final product in parsedProducts) {
          await database.insertProduct(product.toCompanion());
        }

        await loadProducts();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${parsedProducts.length} products imported')),
        );
      }

      await loadProducts();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e.toString()')));
    } finally {
      if (mounted) {
        setState(() {
          isImportingReceipt = false;
        });
      }
    }
  }

  Future<void> loadExpense() async {
    final dbExpense = await database.getExpenseById(widget.expenseId);

    if (dbExpense == null) {
      return;
    }

    setState(() {
      expense = ExpenseModel.fromDb(dbExpense);
      titleController.text = expense!.title;
      totalController.text = expense!.total.toString();
    });
  }

  Future<void> loadProducts() async {
    final dbProducts = await database.getProductsForExpense(widget.expenseId);

    final loadedProducts = dbProducts
        .map((p) => ProductModel.fromDb(p))
        .toList();

    setState(() {
      products = loadedProducts;
    });
  }

  Future<void> addProduct() async {
    final product = ProductModel(
      expenseId: widget.expenseId,
      name: "",
      price: 0,
      quantity: 1,
    );

    final productId = await database.insertProduct(product.toCompanion());

    product.id = productId;

    await loadProducts();
  }

  Future<void> removeProduct(int index) async {
    final product = products[index];

    if (product.id == null) {
      return;
    }

    await database.deleteProduct(product.id!);
    await loadProducts();
  }

  Future<void> updateProduct(ProductModel product) async {
    await database.updateProduct(product.toCompanion());
    await loadProducts();
  }

  double get productsTotal {
    return products.fold(
      0.0,
      (sum, product) => sum + product.price * product.quantity,
    );
  }

  double get remaining {
    return expense!.total - productsTotal;
  }

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController();

    loadExpense();
    loadProducts();
  }

  @override
  void dispose() {
    titleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (expense == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentExpense = expense!;

    return PopScope(
      canPop: !isImportingReceipt,

      child: Scaffold(
        appBar: AppBar(
          title: const Text("Expense"),
          actions: [
            IconButton(
              icon: const Icon(Icons.document_scanner),
              onPressed: importReceipt,
            ),
          ],
        ),

        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        Flexible(
                          child: isEditingTitle
                              ? SizedBox(
                                  width: 250,

                                  child: TextField(
                                    controller: titleController,
                                    autofocus: true,
                                    onChanged: (value) async {
                                      currentExpense.title = value;
                                      await database.updateExpense(
                                        currentExpense.toCompanion(),
                                      );
                                    },

                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )
                              : Text(
                                  titleController.text,

                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),

                        const SizedBox(width: 10),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              isEditingTitle = !isEditingTitle;
                            });
                          },

                          icon: Icon(isEditingTitle ? Icons.check : Icons.edit),
                        ),
                      ],
                    ),
                  ),

                  Card(
                    margin: const EdgeInsets.all(12),

                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              SizedBox(
                                width: 100,

                                child: TextField(
                                  controller: totalController,
                                  keyboardType: TextInputType.number,

                                  textAlign: TextAlign.center,

                                  onChanged: (value) async {
                                    final total = double.tryParse(value);

                                    if (total == null || total <= 0) {
                                      return;
                                    }

                                    expense!.total = total;

                                    setState(() {});

                                    await database.updateExpense(
                                      expense!.toCompanion(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          if (products.isNotEmpty) ...[
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                const Text(
                                  "Products",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                Text("${productsTotal.toStringAsFixed(2)} RON"),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                const Text(
                                  "Remaining",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                Text(
                                  "${remaining.toStringAsFixed(2)} RON",
                                  style: TextStyle(
                                    color: remaining < 0
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text(
                                "Participants number",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              SizedBox(
                                width: 60,

                                child: TextField(
                                  controller: peopleController,
                                  keyboardType: TextInputType.number,

                                  textAlign: TextAlign.center,

                                  onChanged: (value) async {
                                    final people = int.tryParse(value);

                                    if (people == null || people <= 0) {
                                      return;
                                    }

                                    expense!.peopleCount = people;

                                    setState(() {});

                                    await database.updateExpense(
                                      expense!.toCompanion(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                context: context,

                                builder: (_) => ManageParticipantsDialog(
                                  expenseId: widget.expenseId,
                                  groupId: expense!.groupId,
                                ),
                              );
                            },

                            child: const Text('Manage Participants'),
                          ),

                          const Divider(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text(
                                "Per Person",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              Text(
                                "${expense!.splitAmount.toStringAsFixed(2)} RON",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),

                    child: Row(
                      children: [
                        Text(
                          "De plată: 120 RON",

                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Text(
                          "De primit: 50 RON",

                          style: TextStyle(
                            color: Colors.green.shade400,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),

                                const SizedBox(height: 16),

                                const Text(
                                  'No products yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'Tap Add Product or scan a receipt',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: products.length,

                            itemBuilder: (context, index) {
                              return ProductRow(
                                key: ValueKey(products[index].id),
                                product: products[index],

                                onDelete: () {
                                  removeProduct(index);
                                },

                                onChanged: () async {
                                  await updateProduct(products[index]);
                                },
                              );
                            },
                          ),
                  ),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: addProduct,
                      child: const Text("Add Product"),
                    ),
                  ),
                ],
              ),
            ),
            if (isImportingReceipt)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "Analyzing receipt...",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
