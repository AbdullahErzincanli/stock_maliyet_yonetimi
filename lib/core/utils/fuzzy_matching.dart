import 'package:string_similarity/string_similarity.dart';

class FuzzyMatching {
  /// Listenin içinde hedefe (target) en benzeyen metni bulur.
  /// threshold: 0.0 (hiç benzemiyor) ile 1.0 (aynı) arasında bir değer. 
  /// Eğer en yüksek benzerlik threshold'un altındaysa null döner.
  static String? findBestMatch(String target, List<String> list, {double threshold = 0.4}) {
    if (target.isEmpty || list.isEmpty) return null;
    
    // Aramayı küçük harf ve boşlukları kırparak yapalım
    final cleanTarget = target.toLowerCase().trim();
    final cleanList = list.map((e) => e.toLowerCase().trim()).toList();
    
    var match = cleanTarget.bestMatch(cleanList);
    
    if (match.bestMatch.rating! >= threshold) {
      // Orijinal listeden karşılığını bul (index üzerinden)
      return list[match.bestMatchIndex];
    }
    
    return null;
  }
}
