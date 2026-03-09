import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../bloc/card/card_provider.dart';
import '../../core/theme/app_colors.dart';
import '../components/app_toast.dart';
import '../components/loading_view.dart';
import '../components/theme_toggle_button.dart';
import 'card_detail_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);
    
    try {
      final card = await context.read<CardProvider>().scanQr(code);
      if (!mounted) return;
      
      if (card != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CardDetailPage(card: card)),
        );
      } else {
        AppToast.show(
          context,
          "Card not found for this QR code",
          type: AppToastType.error,
        );
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          "Error scanning QR code",
          type: AppToastType.error,
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060B16) : Colors.black,
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0B1220),
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF060B16) : Colors.white,
        elevation: 0,
        surfaceTintColor: isDark ? const Color(0xFF060B16) : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          ThemeToggleButton(color: isDark ? Colors.white : Colors.black87),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.white : const Color(0xFFDBE4F5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.24),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: LoadingView(size: 96)),
            ),
        ],
      ),
    );
  }
}
