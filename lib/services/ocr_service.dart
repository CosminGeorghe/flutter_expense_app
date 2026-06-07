import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {

  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    final textRecognizer = TextRecognizer();

    final recognizedText = await textRecognizer.processImage(inputImage);

    final allLines = <TextLine>[];

    for (final block in recognizedText.blocks) {
      allLines.addAll(block.lines);
    }

    allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    final buffer = StringBuffer();

    for (final line in allLines) {
      buffer.writeln(line.text);
    }

    for (final line in allLines) {
      print("Y=${line.boundingBox.top}: ${line.text}");

      buffer.writeln("Y=${line.boundingBox.top}: ${line.text}");
    }

    await textRecognizer.close();

    return buffer.toString();
  }
}
