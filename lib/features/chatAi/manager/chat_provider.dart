import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_hub_app/features/chatAi/data/datasource/local_databaseMessage.dart';
import 'package:speech_to_text/speech_recognition_error.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../core/errors/error_message.dart';
import '../data/datasource/firebase_service._message.dart';
import '../../../core/utils/app_strings.dart';
import '../data/model/message_model.dart';

class ChatProvider with ChangeNotifier {
  static const apiKey = AppStrings.apiKey;
  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

  final TextEditingController userMessage = TextEditingController();
  final List<Message> messages = [];

  late stt.SpeechToText speech;
  bool isListening = false;
  bool isLoading = false;
  String lastWords = '';
  Timer? _speechTimer;

  StreamController<String>? botResponseController;
  String streamedText = '';

  // User stats
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? get userStats => _userStats;


  ChatProvider() {
    initSpeech();
    loadMessages();
    loadUserStats();
  }

  Future<void> loadMessages() async {
    try {
      final firebaseMessages = await FirebaseServiceMessage.getMessages();
      for (var message in firebaseMessages) {
        if (message.hasImage && message.imageId != null) {
          final imagePath = await LocalDatabaseMessage.getImagePath(message.id);
          if (imagePath != null && File(imagePath).existsSync()) {
            message.setImageFile(File(imagePath));
          }
        }
      }

      messages.clear();
      messages.addAll(firebaseMessages);
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> loadUserStats() async {
    try {
      _userStats = await FirebaseServiceMessage.getUserChatStats();
      notifyListeners();
    } catch (e) {
      print('Error loading user stats: $e');
    }
  }

  Future<void> clearAllMessages() async {
    try {
      for (var message in messages) {
        if (message.hasImage && message.id.isNotEmpty) {
          try {
            await LocalDatabaseMessage.deleteImage(message.id);
            print('Deleted local image for message: ${message.id}');
          } catch (e) {
            print('Error deleting local image for message ${message.id}: $e');
          }
        }
      }

      await FirebaseServiceMessage.clearAllMessages();
      messages.clear();
      await loadUserStats();
      notifyListeners();

      print('All messages and images cleared successfully');
    } catch (e) {
      print('Error clearing all messages: $e');
      handleError(e);
    }
  }

  String classifyError(dynamic error) {
    if (error is SocketException) {
      return 'NETWORK_ERROR';
    } else if (error is TimeoutException) {
      return 'API_LIMIT_ERROR';
    } else if (error is PermissionStatus) {
      return 'MIC_PERMISSION_DENIED';
    } else {
      return 'UNKNOWN_ERROR';
    }
  }

  void handleError(dynamic error) {
    String errorType = classifyError(error);
    String message = errorMessages[errorType] ?? errorMessages['UNKNOWN_ERROR']!;

    final errorMessage = Message(
      isUser: false,
      message: message,
      date: DateTime.now(),
    );

    messages.add(errorMessage);
    FirebaseServiceMessage.saveMessage(errorMessage);
    notifyListeners();
  }
  void handleSpeechError(stt.SpeechRecognitionError error) {
    String message;
    switch (error.errorMsg) {
      case 'not_available':
        message = 'Speech recognition is not available on this device';
        break;
      case 'service_not_ready':
        message = 'Speech recognition service is not ready';
        break;
      case 'permission_denied':
        message = 'Microphone permission denied';
        break;
      default:
        message = 'Unknown error in speech recognition';
    }
    showSnackBar(message);
  }
  void initBotResponse() {
    botResponseController?.close();
    botResponseController = StreamController<String>();
    streamedText = '';
  }

  Future<void> initSpeech() async {
    speech = stt.SpeechToText();
    bool available = await speech.initialize(
      onStatus: (status) async {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          await _handleSpeechEnd();
        }
      },
      onError: (error) => handleSpeechError(error),
    );
    if (!available) {
      showSnackBar(errorMessages['speech_not_available']!);
    }
  }

  Future<void> _handleSpeechEnd() async {
    if (isListening) {
      await stopListening();
      if (userMessage.text.trim().isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
        await sendMessage();
      }
    }
  }
  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return status.isGranted;
  }
  Future<void> startListening() async {
    if (!await checkMicrophonePermission()) {
      showSnackBar(errorMessages['permission_denied']!);
      return;
    }

    if (!isListening && !isLoading) {
      bool available = await speech.initialize(
        onStatus: (status) async {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            await _handleSpeechEnd();
          }
        },
        onError: (error) {
          handleSpeechError(error);
          stopListening();
        },
      );

      if (available) {
        isListening = true;
        userMessage.clear();
        notifyListeners();

        _speechTimer?.cancel();

        speech.listen(
          onResult: (result) {
            lastWords = result.recognizedWords;
            userMessage.text = lastWords;
            notifyListeners();
            _speechTimer?.cancel();
            _speechTimer = Timer(const Duration(seconds: 2), () {
              if (isListening && userMessage.text.trim().isNotEmpty) {
                _handleSpeechEnd();
              }
            });
          },
          localeId: 'en-US',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 2),
          cancelOnError: true,
          partialResults: true,
        );
        Timer(const Duration(seconds: 30), () {
          if (isListening) {
            _handleSpeechEnd();
          }
        });

      } else {
        showSnackBar(errorMessages['speech_not_available']!);
      }
    }
  }

  Future<void> stopListening() async {
    if (isListening) {
      _speechTimer?.cancel();
      await speech.stop();
      isListening = false;
      notifyListeners();
    }
  }

  Future<void> manualStopListening() async {
    if (isListening) {
      await stopListening();

      if (userMessage.text.trim().isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        await sendMessage();
      }
    }
  }

  void showSnackBar(String message) {
    debugPrint(message);
  }
  Future<void> sendMessage() async {
    if (isLoading) return;
    final message = userMessage.text.trim();
    if (message.isEmpty) return;

    userMessage.clear();
    await _sendMessageInternal(message: message);
  }
  Future<void> sendImageDirectly(File imageFile) async {
    if (isLoading) return;

    await _sendMessageInternal(
      message: "What do you see in this image?",
      imageFile: imageFile,
    );
  }
  Future<void> _sendMessageInternal({
    required String message,
    File? imageFile,
  }) async {
    initBotResponse();

    final userMsg = Message(
      id: '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
      isUser: true,
      message: message,
      date: DateTime.now(),
      hasImage: imageFile != null,
      imageFile: imageFile,
    );

    if (imageFile != null) {
      try {
        final imageId = await LocalDatabaseMessage.saveImage(userMsg.id, imageFile.path);
        print('Image saved locally with ID: $imageId for message: ${userMsg.id}');

        final updatedMsg = userMsg.copyWith(imageId: imageId);

        messages.add(updatedMsg);
        notifyListeners();

        await FirebaseServiceMessage.saveMessage(updatedMsg);

      } catch (e) {
        print('Error saving image locally: $e');
        messages.add(userMsg);
        notifyListeners();
        await FirebaseServiceMessage.saveMessage(userMsg);
      }
    } else {
      messages.add(userMsg);
      notifyListeners();
      await FirebaseServiceMessage.saveMessage(userMsg);
    }

    isLoading = true;
    notifyListeners();

    try {
      final List<Content> content = [];
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        content.add(Content.data('image/jpeg', bytes));
      }

      if (message.isNotEmpty) {
        content.add(Content.text(message));
      }

      if (content.isEmpty) {
        content.add(Content.text("Hello"));
      }

      final response = await model.generateContent(content);
      final botMessage = response.text ?? "I couldn't process your request. Please try again.";

      for (var char in botMessage.characters) {
        streamedText += char;
        botResponseController?.add(streamedText);
        await Future.delayed(const Duration(milliseconds: 20));
      }

      final botMsg = Message(
        id: '${DateTime.now().millisecondsSinceEpoch}_bot_${DateTime.now().microsecond}',
        isUser: false,
        message: streamedText,
        date: DateTime.now(),
      );

      messages.add(botMsg);
      await FirebaseServiceMessage.saveMessage(botMsg);

      await loadUserStats();

    } catch (e) {
      print('Error in AI response: $e');
      handleError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      await sendImageDirectly(imageFile);

    } catch (e) {
      print('Error picking image: $e');
      showSnackBar('Failed to pick image. Please try again.');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex == -1) return;

      final message = messages[messageIndex];

      if (message.hasImage) {
        await LocalDatabaseMessage.deleteImage(messageId);
        print('Deleted local image for message: $messageId');
      }

      await FirebaseServiceMessage.deleteMessage(messageId);
      messages.removeAt(messageIndex);
      await loadUserStats();
      notifyListeners();

    } catch (e) {
      print('Error deleting message: $e');
      handleError(e);
    }
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    botResponseController?.close();
    speech.stop();
    userMessage.dispose();
    super.dispose();
  }
}
