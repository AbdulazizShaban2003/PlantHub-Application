import 'dart:io';
import 'dart:ui';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/articles/data/models/plant_model.dart';

Future<void> sharePlantDetails({required Plant? plant, required BuildContext context}) async {
  if (plant == null || plant.image == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لا تتوفر صورة للمشاركة')),
    );
    return;
  }

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final file = await DefaultCacheManager().getSingleFile(plant.image!);
    final imageBytes = await file.readAsBytes();
    final codec = await instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
    canvas.drawImage(image, Offset.zero, Paint());

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: image.height * 0.06,
      fontWeight: FontWeight.bold,
      shadows: const [
        Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2.0, 2.0)),
      ],
    );

    final textPainter = TextPainter(
      text: TextSpan(text: plant.name, style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout(maxWidth: image.width.toDouble() * 0.9);

    final offset = Offset(
      (image.width - textPainter.width) / 2,
      image.height * 0.85 - textPainter.height,
    );

    textPainter.paint(canvas, offset);

    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final imageWithText = byteData!.buffer.asUint8List();

    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/shared_plant_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(imagePath).writeAsBytes(imageWithText);

    await Share.shareXFiles(
      [
        XFile(imagePath, mimeType: 'image/png'),
      ],
      text: '🌿 ${plant.name} 🌿\n See this amazing plant in the PlantHub app.',
      subject: '${plant.name} : Share Plant',
    );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  } catch (e) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
FlushbarHelper.createError(
    message:
        '${e.toString()} Failed to share the plant',
    duration: const Duration(seconds: 2),
);
  }
}