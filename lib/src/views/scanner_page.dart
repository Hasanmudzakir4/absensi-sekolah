import 'package:absensi/src/controllers/scanner_controller.dart';
import 'package:flutter/material.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<StatefulWidget> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late QRScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = QRScannerController(context: context)
      ..onUpdate = () {
        if (mounted) setState(() {});
      };
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          controller.buildQRView(),
          const _ScannerOverlay(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: controller.buildOverlay(),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final scanSize = width * 0.8;
        final left = (width - scanSize) / 2;
        final top = (height - scanSize) / 2;

        return Stack(
          children: [
            CustomPaint(
              size: Size(width, height),
              painter: _ScannerOverlayPainter(),
            ),
            Positioned(
              top: top - 60,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  "Cari kode QR",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Garis pojok
            Positioned(
              left: left,
              top: top,
              child: _CornerDecoration(corner: Corner.topLeft),
            ),
            Positioned(
              right: left,
              top: top,
              child: _CornerDecoration(corner: Corner.topRight),
            ),
            Positioned(
              left: left,
              bottom: top,
              child: _CornerDecoration(corner: Corner.bottomLeft),
            ),
            Positioned(
              right: left,
              bottom: top,
              child: _CornerDecoration(corner: Corner.bottomRight),
            ),
          ],
        );
      },
    );
  }
}

enum Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerDecoration extends StatelessWidget {
  final Corner corner;
  const _CornerDecoration({required this.corner});

  @override
  Widget build(BuildContext context) {
    const lineLength = 30.0;
    const lineWidth = 4.0;
    final color = Colors.greenAccent;

    return SizedBox(
      width: lineLength,
      height: lineLength,
      child: Stack(
        children: [
          if (corner == Corner.topLeft || corner == Corner.bottomLeft)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: lineWidth,
                height: lineLength,
                color: color,
              ),
            ),
          if (corner == Corner.topLeft || corner == Corner.topRight)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: lineLength,
                height: lineWidth,
                color: color,
              ),
            ),
          if (corner == Corner.topRight || corner == Corner.bottomRight)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: lineWidth,
                height: lineLength,
                color: color,
              ),
            ),
          if (corner == Corner.bottomLeft || corner == Corner.bottomRight)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: lineLength,
                height: lineWidth,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromRGBO(0, 0, 0, 0.4)
          ..style = PaintingStyle.fill;

    final scanSize = size.width * 0.8;
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanSize,
      height: scanSize,
    );

    final backgroundPath =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRRect(RRect.fromRectXY(scanRect, 16, 16));
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
