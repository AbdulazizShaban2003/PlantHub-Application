import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_hub_app/core/cache/local_databaseMessage.dart';
import 'package:speech_to_text/speech_recognition_error.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../core/service/firebase_service._message.dart';
import '../data/model/message_model.dart';

class ChatProvider with ChangeNotifier {
  static const apiKey = "AIzaSyCpmd8S2iciacCZUBsSj9spvxEESoLVirc";
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

  final Map<String, String> errorMessages = {
    'NETWORK_ERROR': 'No internet connection, please check your network',
    'API_LIMIT_ERROR': 'API limit exceeded, please try again later',
    'MIC_PERMISSION_DENIED': 'Microphone permission denied, enable it in settings',
    'UNKNOWN_ERROR': 'An unexpected error occurred, please try again',
    'speech_not_available': 'Speech recognition is not available on this device',
    'permission_denied': 'Microphone permission denied',
  };

  ChatProvider() {
    initSpeech();
    loadMessages();
    loadUserStats();
  }

  Future<void> loadMessages() async {
    try {
      final firebaseMessages = await FirebaseServiceMessage.getMessages();

      // Load images for messages that have them
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
      // First, delete all local images before clearing messages
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

      // Clear Firebase messages
      await FirebaseServiceMessage.clearAllMessages();

      // Clear local messages list
      messages.clear();

      // Reload user stats
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

      // Send message automatically when speech is done
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

        // Cancel any existing timer
        _speechTimer?.cancel();

        // Start listening
        speech.listen(
          onResult: (result) {
            lastWords = result.recognizedWords;
            userMessage.text = lastWords;
            notifyListeners();

            // Reset timer on each result
            _speechTimer?.cancel();
            _speechTimer = Timer(const Duration(seconds: 2), () {
              // Auto-stop after 2 seconds of silence
              if (isListening && userMessage.text.trim().isNotEmpty) {
                _handleSpeechEnd();
              }
            });
          },
          localeId: 'en-US',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 2), // Shorter pause detection
          cancelOnError: true,
          partialResults: true,
        );

        // Auto-stop after maximum time
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

  // Manual stop for button release
  Future<void> manualStopListening() async {
    if (isListening) {
      await stopListening();

      // Send message if there's text
      if (userMessage.text.trim().isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        await sendMessage();
      }
    }
  }

  void showSnackBar(String message) {
    debugPrint(message);
  }

  // Regular text message sending
  Future<void> sendMessage() async {
    if (isLoading) return;
    final message = userMessage.text.trim();
    if (message.isEmpty) return;

    userMessage.clear();
    await _sendMessageInternal(message: message);
  }

  // Send image directly without dialog
  Future<void> sendImageDirectly(File imageFile) async {
    if (isLoading) return;

    await _sendMessageInternal(
      message: "What do you see in this image?", // Default question
      imageFile: imageFile,
    );
  }

  // Internal method to handle actual message sending
  Future<void> _sendMessageInternal({
    required String message,
    File? imageFile,
  }) async {
    initBotResponse();

    // Create user message with unique ID
    final userMsg = Message(
      id: '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
      isUser: true,
      message: message,
      date: DateTime.now(),
      hasImage: imageFile != null,
      imageFile: imageFile,
    );

    // Save image locally if provided
    if (imageFile != null) {
      try {
        final imageId = await LocalDatabaseMessage.saveImage(userMsg.id, imageFile.path);
        print('Image saved locally with ID: $imageId for message: ${userMsg.id}');

        // Update message with imageId
        final updatedMsg = userMsg.copyWith(imageId: imageId);

        // Add updated message to list
        messages.add(updatedMsg);
        notifyListeners();

        // Save to Firebase with imageId
        await FirebaseServiceMessage.saveMessage(updatedMsg);

      } catch (e) {
        print('Error saving image locally: $e');
        // Still add message without image if image save fails
        messages.add(userMsg);
        notifyListeners();
        await FirebaseServiceMessage.saveMessage(userMsg);
      }
    } else {
      // Add message to list and notify (no image)
      messages.add(userMsg);
      notifyListeners();
      // Save to Firebase
      await FirebaseServiceMessage.saveMessage(userMsg);
    }

    // Start loading for bot response
    isLoading = true;
    notifyListeners();

    try {
      final List<Content> content = [];

      // Add image content first if provided
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        content.add(Content.data('image/jpeg', bytes));
      }

      // Add text content
      if (message.isNotEmpty) {
        content.add(Content.text(message));
      }

      // If no content, add a default message
      if (content.isEmpty) {
        content.add(Content.text("Hello"));
      }

      final response = await model.generateContent(content);
      final botMessage = response.text ?? "I couldn't process your request. Please try again.";

      // Stream the response character by character
      for (var char in botMessage.characters) {
        streamedText += char;
        botResponseController?.add(streamedText);
        await Future.delayed(const Duration(milliseconds: 20));
      }

      // Add the complete bot message with unique ID
      final botMsg = Message(
        id: '${DateTime.now().millisecondsSinceEpoch}_bot_${DateTime.now().microsecond}',
        isUser: false,
        message: streamedText,
        date: DateTime.now(),
      );

      messages.add(botMsg);
      await FirebaseServiceMessage.saveMessage(botMsg);

      // Update user stats
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

      // Send image directly without dialog
      await sendImageDirectly(imageFile);

    } catch (e) {
      print('Error picking image: $e');
      showSnackBar('Failed to pick image. Please try again.');
    }
  }

  // Delete single message
  Future<void> deleteMessage(String messageId) async {
    try {
      // Find the message
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex == -1) return;

      final message = messages[messageIndex];

      // Delete local image if exists
      if (message.hasImage) {
        await LocalDatabaseMessage.deleteImage(messageId);
        print('Deleted local image for message: $messageId');
      }

      // Delete from Firebase
      await FirebaseServiceMessage.deleteMessage(messageId);

      // Remove from local list
      messages.removeAt(messageIndex);

      // Update user stats
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
