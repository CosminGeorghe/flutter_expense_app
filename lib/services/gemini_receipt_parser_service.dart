import 'package:google_generative_ai/google_generative_ai.dart';

import 'receipt_parser_service.dart';

class GeminiReceiptParserService
    implements ReceiptParserService {

  final model = GenerativeModel(
    model: 'gemini-3.5-flash',
    apiKey: '',
  );

  @override
  Future<String> parse(String ocrText) async {

    final prompt = '''
You are a receipt parser.

Extract products from the OCR text.

Return ONLY valid JSON.

Format:

[
  {
    "name": "Product Name",
    "quantity": 1,
    "unitPrice": 10.50
  }
]

Ignore:
- totals
- VAT
- payment information
- cashier information
- dates
- store information

OCR Text:

$ocrText
''';

    final response = await model.generateContent(
      [Content.text(prompt)],
    );
    return response.text ?? '';
  }
}