import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ingredient.dart';
import '../core/utils/fuzzy_matching.dart';

class OcrParsedItem {
  final String rawText;
  Ingredient? matchedIngredient;
  double quantity;
  String unit;
  double price; 
  String suggestedName; // Eşleşmezse fişteki ismi öneri olarak gösteririz
  
  OcrParsedItem({
    required this.rawText,
    this.matchedIngredient,
    this.quantity = 1.0,
    this.unit = 'adet',
    this.price = 0.0,
    this.suggestedName = '',
  });
}

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageAndRecognizeText({bool fromCamera = true}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    
    if (image == null) return null;

    final inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    return recognizedText.text;
  }

  List<OcrParsedItem> processReceiptText(String text, List<Ingredient> availableIngredients) {
    if (text.isEmpty) return [];

    final List<OcrParsedItem> result = [];
    final lines = text.split('\n');

    for (var line in lines) {
      line = line.trim();
      // Çok kısa veya sadece sayılardan oluşan, tarih/saat olan satırları filtreliyoruz
      if (line.length < 3) continue;
      if (RegExp(r'^\d+$').hasMatch(line)) continue; 

      // Fişlerdeki olası "TOPLAM", "KDV" gibi satırları yoksayıyoruz
      final lowerCaseLine = line.toLowerCase();
      if (lowerCaseLine.contains('toplam') || 
          lowerCaseLine.contains('nakit') || 
          lowerCaseLine.contains('kredi kart') || 
          lowerCaseLine.contains('kdv') ||
          lowerCaseLine.contains('teşekkür')) {
        continue;
      }

      // String'i analiz edip olası harfleri isim, rakamları tutar ve miktar olarak ayıklama
      // Örnek basit bir mantık (Gerçek hayat fişleri için NLP/Regex modüle edilir):
      String candidateName = line.replaceAll(RegExp(r'[0-9.,]'), '').trim();
      double parsedPrice = _extractLargestNumber(line);

      // Veritabanı içindeki ürün isimleriyle bulanık (fuzzy) eşleştirme aranır
      // Aliases öğrenme verisini de dahil ediyoruz
      // Her ingredient için [isim, alias1, alias2...] → aynı ingredient'e map'lenir
      final Map<String, Ingredient> nameToIngredient = {};
      for (var ing in availableIngredients) {
        nameToIngredient[ing.name] = ing;
        if (ing.aliases != null && ing.aliases!.isNotEmpty) {
          for (var alias in ing.aliases!.split(',')) {
            final trimmed = alias.trim();
            if (trimmed.isNotEmpty) {
              nameToIngredient[trimmed] = ing;
            }
          }
        }
      }
      final allNames = nameToIngredient.keys.toList();
      final matchedName = FuzzyMatching.findBestMatch(candidateName, allNames, threshold: 0.35);
      
      Ingredient? ingredient;
      if (matchedName != null) {
        ingredient = nameToIngredient[matchedName];
      }

      result.add(OcrParsedItem(
        rawText: line,
        matchedIngredient: ingredient,
        suggestedName: candidateName,
        price: parsedPrice,
        // TODO: Miktar/Birim ayrıştırma daha akıllıca yapılabilir (şimdilik 1 kabul ettik)
      ));
    }
    return result;
  }

  /// Verilen satırdaki en büyük sayıyı (genelde fiyat olur) bulur
  double _extractLargestNumber(String line) {
    // Sayıları (örn: 12.50, 45, 9,99) Regex ile çek
    final matches = RegExp(r'\d+[.,]\d+|\d+').allMatches(line);
    double maxNum = 0.0;
    
    for (var match in matches) {
      var numStr = match.group(0)!.replaceAll(',', '.');
      var number = double.tryParse(numStr);
      if (number != null && number > maxNum) {
        maxNum = number;
      }
    }
    return maxNum;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
