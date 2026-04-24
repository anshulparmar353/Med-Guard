import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med_guard/core/routes/app_go_router.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isScanned = false;
  bool _isTorchOn = false;

  final ImagePicker _picker = ImagePicker();
  final MobileScannerController _controller = MobileScannerController();

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gallery image selected")));
    }
  }

  void _resetScanner() {
    setState(() => _isScanned = false);
    _controller.start();
  }

  void _toggleFlash() {
    _controller.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Prescription"), centerTitle: true),

      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (barcodeCapture) {
              if (_isScanned) return;

              final code = barcodeCapture.barcodes.first.rawValue;

              if (code != null) {
                _isScanned = true;
                _controller.stop();
                context.go(AppRoutes.addMedicine, extra: code);
              }
            },
          ),

          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 300,
                    height: 330,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Center(
            child: SizedBox(
              width: 300,
              height: 330,
              child: Stack(
                children: [
                  _corner(top: 0, left: 0),
                  _corner(top: 0, right: 0),
                  _corner(bottom: 0, left: 0),
                  _corner(bottom: 0, right: 0),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(AppRoutes.dashboardScreen),
                  ),
                ),

                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: _isTorchOn ? Colors.yellow : Colors.white,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 20,
                    child: _bottomButton(
                      icon: Icons.photo_library,
                      label: "Gallery",
                      onTap: _pickFromGallery,
                    ),
                  ),

                  _bottomButton(
                    icon: Icons.camera_alt,
                    label: "Scan",
                    onTap: _resetScanner,
                    isMain: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? const BorderSide(color: Colors.blue, width: 4)
                : BorderSide.none,
            left: left != null
                ? const BorderSide(color: Colors.blue, width: 4)
                : BorderSide.none,
            right: right != null
                ? const BorderSide(color: Colors.blue, width: 4)
                : BorderSide.none,
            bottom: bottom != null
                ? const BorderSide(color: Colors.blue, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _bottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isMain = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(isMain ? 18 : 14),
            decoration: BoxDecoration(
              color: isMain ? Colors.white : Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isMain ? Colors.black : Colors.white,
              size: isMain ? 32 : 26,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
