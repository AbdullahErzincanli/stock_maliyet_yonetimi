import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ocr_provider.dart';
import '../../providers/stock_provider.dart';
import 'ocr_review_screen.dart';

class OcrScanScreen extends ConsumerStatefulWidget {
  const OcrScanScreen({super.key});

  @override
  ConsumerState<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends ConsumerState<OcrScanScreen> {
  bool _isLoading = false;

  void _scan(bool fromCamera) async {
    setState(() => _isLoading = true);
    try {
      final ocrService = ref.read(ocrServiceProvider);
      final text = await ocrService.pickImageAndRecognizeText(fromCamera: fromCamera);

      if (text != null && text.isNotEmpty) {
        final ingredients = await ref.read(ingredientsProvider.future);
        final parsedItems = ocrService.processReceiptText(text, ingredients);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OcrReviewScreen(parsedItems: parsedItems)),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Metin algılanamadı veya işlem iptal edildi.')));
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fiş Tara')),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fiş analiz ediliyor, lütfen bekleyin...'),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  const SizedBox(height: 24),
                  const Text('Bir alışveriş fişini kamerayla çekin veya galeriden seçin.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _scan(true),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamerayla Çek'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _scan(false),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeriden Seç'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(200, 56)),
                  ),
                ],
              ),
      ),
    );
  }
}
