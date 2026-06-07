import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAiReceiptParserService {
  static const String _apiKey = '';

  Future<String> parse(String ocrText) async {
    final prompt = '''
You are a receipt parser.

Your task is to extract purchased products from OCR text generated from Romanian receipts.

Rules:

- Return ONLY valid JSON.
- Do not use markdown.
- Do not wrap the JSON in code blocks.
- Do not include explanations.
- Ignore store information.
- Ignore VAT information.
- Ignore fiscal information.
- Ignore cashier information.
- Ignore dates.
- Ignore totals, subtotals and payment information.

- Reconstruct product names when OCR has minor errors.
- If quantity cannot be determined, use 1.
- Prices must be numeric values.
- Keep in mind that the price for the products can appear above the product name. if products name and pricing doessn't make sense maybe the price is before the product.
- Some receipts might have abreviations for quantity (e.g BUC in Romania for "bucatai") keep the language in mind.
- You can use total for checks but don't overexert yourself trying to make the total of all products equal the receipt total. The app can tolerate mistakes and they can be fixed manually
- Some products may appear multiple times on the receipt. If that's the case then keep only one entry for each product and instead increment product quantity for each ocurance
- Some products are sold by weight and may appear in the format:
  0.596 x 11.99 = 7.15
- For products sold by weight, do NOT use the weight as quantity.
- Instead, set quantity to 1 and use the final paid amount as unitPrice.
- Example:
  0.596 x 11.99 = 7.15

  becomes

  {
    "name": "Apples",
    "quantity": 1,
    "unitPrice": 7.15
  }

- Quantity must always be a whole number.
- Never return decimal quantities.
- If a quantity contains decimals, convert it to quantity = 1 and use the final paid amount as unitPrice.
- Product discounts should be applied to the final product price whenever possible.
- If a receipt contains a discount line immediately after a product, subtract the discount from that product's price.
- For some discounts the product name might appear twice but "discount" word will be presetn after second occurance. In this situation subract the price of the second occurance from the first one
- Ignore standalone discount entries and do not return them as products.
Return a JSON array in the following format:

[
  {
    "name": "Product Name",
    "quantity": 1,
    "unitPrice": 10.50
  }
]

OCR text:

$ocrText
''';

    final response = await http.post(
      Uri.parse(
        'https://api.openai.com/v1/chat/completions',
      ),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4.1-mini",
        "messages": [
          {
            "role": "user",
            "content": prompt,
          }
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