import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ReceiptImportDialog extends StatelessWidget {
  final List<ProductModel> products;

  const ReceiptImportDialog({
    super.key,
    required this.products,
  });

  double get total {
    return products.fold(
      0,
      (sum, product) =>
          sum + (product.price * product.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Receipt"),

      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: products.length,

                itemBuilder: (context, index) {
                  final product = products[index];

                  return ListTile(
                    title: Text(product.name),

                    subtitle: Text(
                      "Qty: ${product.quantity}",
                    ),

                    trailing: Text(
                      "${product.price.toStringAsFixed(2)} RON",
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            Text(
              "Products: ${products.length}",
            ),

            Text(
              "Total: ${total.toStringAsFixed(2)} RON",
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },

          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },

          child: const Text("Import"),
        ),
      ],
    );
  }
}