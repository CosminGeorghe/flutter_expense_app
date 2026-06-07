import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductRow extends StatefulWidget {
  final ProductModel product;

  final VoidCallback onDelete;

  final VoidCallback onChanged;

  const ProductRow({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<ProductRow> {
  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController quantityController;

  late final FocusNode nameFocusNode;
  late final FocusNode priceFocusNode;
  late final FocusNode quantityFocusNode;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product.name);

    priceController = TextEditingController(
      text: widget.product.price.toString(),
    );

    quantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );

    nameFocusNode = FocusNode();
    priceFocusNode = FocusNode();
    quantityFocusNode = FocusNode();

    nameFocusNode.addListener(() {
      if (!nameFocusNode.hasFocus) {
        widget.onChanged();
      }
    });

    priceFocusNode.addListener(() {
      if (!priceFocusNode.hasFocus) {
        widget.onChanged();
      }
    });

    quantityFocusNode.addListener(() {
      if (!quantityFocusNode.hasFocus) {
        widget.onChanged();
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    nameFocusNode.dispose();
    priceFocusNode.dispose();
    quantityFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: nameController,
              focusNode: nameFocusNode,
              onChanged: (value) {
                widget.product.name = value;
                widget.onChanged();
              },
              decoration: const InputDecoration(
                labelText: "Product",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            flex: 2,
            child: TextField(
              controller: priceController,
              focusNode: priceFocusNode,
              onChanged: (value) {
                widget.product.price = double.tryParse(value) ?? 0;
                setState(() {});
                widget.onChanged();
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            flex: 2,
            child: TextField(
              controller: quantityController,
              focusNode: quantityFocusNode,
              onChanged: (value) {
                widget.product.quantity = int.tryParse(value) ?? 1;
                widget.onChanged();
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Qty",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          IconButton(
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
