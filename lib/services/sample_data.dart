import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/gallery_image.dart';

/// Helper to generate high-resolution sample photos procedurally using Flutter Canvas.
/// Works 100% offline with zero network calls and zero CORS issues on Flutter Web.
class SampleDataHelper {
  static Future<List<GalleryImage>> generateSampleImages() async {
    final samples = [
      _SampleSpec(
        name: 'Sunset Mirage.png',
        gradientStart: const Color(0xFFFF512F),
        gradientEnd: const Color(0xFFDD2476),
        title: 'Sunset Mirage',
        subtitle: 'Golden hour twilight',
      ),
      _SampleSpec(
        name: 'Ocean Breeze.png',
        gradientStart: const Color(0xFF2193b0),
        gradientEnd: const Color(0xFF6dd5ed),
        title: 'Ocean Breeze',
        subtitle: 'Deep coastal azure',
      ),
      _SampleSpec(
        name: 'Neon Cyberpunk.png',
        gradientStart: const Color(0xFF8A2387),
        gradientEnd: const Color(0xFFE94057),
        title: 'Neon Cyberpunk',
        subtitle: 'Vibrant neon cityscapes',
      ),
      _SampleSpec(
        name: 'Emerald Forest.png',
        gradientStart: const Color(0xFF134E5E),
        gradientEnd: const Color(0xFF71B280),
        title: 'Emerald Forest',
        subtitle: 'Tranquil canopy greens',
      ),
      _SampleSpec(
        name: 'Aurora Night.png',
        gradientStart: const Color(0xFF0F2027),
        gradientEnd: const Color(0xFF2C5364),
        title: 'Aurora Night',
        subtitle: 'Northern celestial lights',
      ),
      _SampleSpec(
        name: 'Desert Dunes.png',
        gradientStart: const Color(0xFFF3904F),
        gradientEnd: const Color(0xFF3B4371),
        title: 'Desert Dunes',
        subtitle: 'Sahara starlit sands',
      ),
    ];

    List<GalleryImage> results = [];
    for (int i = 0; i < samples.length; i++) {
      final spec = samples[i];
      final bytes = await _renderArt(spec);
      results.add(
        GalleryImage(
          id: 'sample_${DateTime.now().millisecondsSinceEpoch}_$i',
          name: spec.name,
          bytes: bytes,
          sizeInBytes: bytes.lengthInBytes,
          dateAdded: DateTime.now().subtract(Duration(days: i)),
          isFavorite: i % 2 == 0,
        ),
      );
    }
    return results;
  }

  static Future<Uint8List> _renderArt(_SampleSpec spec) async {
    const width = 800.0;
    const height = 600.0;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, width, height),
    );

    // Background gradient
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(width, height),
        [spec.gradientStart, spec.gradientEnd],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Decorative geometric circles
    final decoPaint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(width * 0.75, height * 0.3), 180, decoPaint);
    canvas.drawCircle(const Offset(width * 0.25, height * 0.75), 140, decoPaint);

    // Sun/moon glowing orb
    final sunPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(width * 0.5, height * 0.4),
        130,
        [
          const Color.fromRGBO(255, 255, 255, 0.65),
          const Color.fromRGBO(255, 255, 255, 0.0),
        ],
      );
    canvas.drawCircle(const Offset(width * 0.5, height * 0.4), 130, sunPaint);

    // Horizon mountain curve
    final path = Path()
      ..moveTo(0, height)
      ..lineTo(0, height * 0.65)
      ..quadraticBezierTo(
        width * 0.25,
        height * 0.45,
        width * 0.5,
        height * 0.62,
      )
      ..quadraticBezierTo(
        width * 0.75,
        height * 0.75,
        width,
        height * 0.52,
      )
      ..lineTo(width, height)
      ..close();
    final mountainPaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.28);
    canvas.drawPath(path, mountainPaint);

    // Title text
    final textPainter = TextPainter(
      text: TextSpan(
        text: spec.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 38,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: width - 80);
    textPainter.paint(canvas, const Offset(40, height - 120));

    // Subtitle text
    final subPainter = TextPainter(
      text: TextSpan(
        text: spec.subtitle,
        style: const TextStyle(
          color: Color.fromRGBO(255, 255, 255, 0.85),
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subPainter.layout(maxWidth: width - 80);
    subPainter.paint(canvas, const Offset(40, height - 70));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

class _SampleSpec {
  final String name;
  final Color gradientStart;
  final Color gradientEnd;
  final String title;
  final String subtitle;

  _SampleSpec({
    required this.name,
    required this.gradientStart,
    required this.gradientEnd,
    required this.title,
    required this.subtitle,
  });
}
