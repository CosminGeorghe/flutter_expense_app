import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class OpenAiVisionReceiptParserService {
  static const String _apiKey =
      '';

  Future<String> parseImage(String imagePath) async {
    final imageBytes = await File(imagePath).readAsBytes();

    final base64Image = base64Encode(imageBytes);

    const prompt = '''
You are a receipt parser.

Extract purchased products from this receipt image.

Rules:

- Return ONLY valid JSON.
- Do not use markdown.
- Do not wrap JSON in code blocks.
- Ignore store information.
- Ignore VAT information.
- Ignore dates.
- Ignore payment information.
- Include SGR and guarantee products.
- Apply discounts when possible.
- Discounts wont always be typed as discount but instead have the equivalent word in native language present.
- If the first line of the receipt is price x amount then prices for all products are present one line above the products names
- If the first line of the receipt is a product name then prices for all products are present one line bellow the products names
- "discount" equivalent name for each country might be present bellow or above the discounted item name.
- if 2 similarly named products are close to each other but the price is different look for "discount" equivalent name for each country near those products as that might be the discount that must be applied
- if two products are the same but one has discount above or udner it that is the price amount that must be subtracter from the not discount price of the product
- some items might be part of a combined package
- combined package name might appear for each item in the package
- don't take combined package names into consideration if individual items with separates prices appear on top or under combined package names
- discount might be applied to each item in the combo separately
- Merge duplicate products by increasing quantity.
- Quantity must always be an integer.

Format:

[
  {
    "name": "Product Name",
    "quantity": 1,
    "unitPrice": 10.50
  }
]
''';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-5.4",
        "messages": [
          {
            "role": "user",
            "content": [
              {"type": "text", "text": prompt},
              {
                "type": "image_url",
                "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
              },
            ],
          },
        ],
        "temperature": 0,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    return data["choices"][0]["message"]["content"];
  }
}
