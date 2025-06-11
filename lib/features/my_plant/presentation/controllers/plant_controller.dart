import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/notification_model.dart';

class PlantController {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      return await _picker.pickImage(source: source);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<List<XFile>> pickMultipleImages() async {
    try {
      return await _picker.pickMultiImage();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  List<PlantAction> createActionsList(
      Map<ActionType, bool> selectedActions,
      Map<ActionType, Reminder?> actionReminders,
      String uuid,
      ) {
    return selectedActions.entries
        .where((entry) => entry.value)
        .map((entry) => PlantAction(
      id: uuid,
      type: entry.key,
      isEnabled: true,
      reminder: actionReminders[entry.key],
    ))
        .toList();
  }
}