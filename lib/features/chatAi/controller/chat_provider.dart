import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_error.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../data/model/message_model.dart';

class ChatProvider with ChangeNotifier {
  static const apiKey = "AIzaSyCpmd8S2iciacCZUBsSj9spvxEESoLVirc";
  final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);

  final TextEditingController userMessage = TextEditingController();
  final List<Message> messages = [];
  File? image;

  late stt.SpeechToText speech;
  bool isListening = false;
  bool isLoading = false;
  String lastWords = '';

  StreamController<String>? botResponseController;
  String streamedText = '';

  final Map<String, String> errorMessages = {
    'NETWORK_ERROR': 'لا يوجد اتصال بالإنترنت، تحقق من الشبكة',
    'API_LIMIT_ERROR': 'تم تجاوز الحد المسموح به، حاول لاحقاً',
    'MIC_PERMISSION_DENIED': 'تم رفض إذن المايكروفون، فعّله من الإعدادات',
    'UNKNOWN_ERROR': 'حدث خطأ غير متوقع، حاول مرة أخرى',
    'speech_not_available': 'ميزة التعرف على الصوت غير متاحة على هذا الجهاز',
    'permission_denied': 'تم رفض إذن المايكروفون',
  };

  ChatProvider() {
    initSpeech();
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

    messages.add(
      Message(isUser: false, message: message, date: DateTime.now()),
    );
    notifyListeners();
  }

  void handleSpeechError(stt.SpeechRecognitionError error) {
    String message;
    switch (error.errorMsg) {
      case 'not_available':
        message = 'ميزة التعرف على الصوت غير متاحة على هذا الجهاز';
        break;
      case 'service_not_ready':
        message = 'خدمة التعرف على الصوت غير جاهزة';
        break;
      case 'permission_denied':
        message = 'تم رفض إذن المايكروفون';
        break;
      default:
        message = 'حدث خطأ غير معروف في التعرف على الصوت';
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
        if (status == 'done') {
          await stopListening();
          sendMessage();
        }
      },
      onError: (error) => handleSpeechError(error),
    );
    if (!available) {
      showSnackBar(errorMessages['speech_not_available']!);
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
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (status) async {
          if (status == 'done') {
            await stopListening();
            sendMessage();
          }
        },
        onError: (error) {
          handleSpeechError(error);
        },
      );
      if (available) {
        isListening = true;
        notifyListeners();
        speech.listen(
          onResult: (result) {
            lastWords = result.recognizedWords;
            userMessage.text = lastWords;
            notifyListeners();
          },
          localeId: 'ar-SA',
          listenFor: const Duration(seconds: 10),
          cancelOnError: true,
          partialResults: true,
        );
      } else {
        showSnackBar(errorMessages['speech_not_available']!);
      }
    }
  }

  Future<void> stopListening() async {
    await speech.stop();
    isListening = false;
    notifyListeners();
  }

  void showSnackBar(String message) {
    // This would be handled by the UI layer
  }

  Future<void> sendMessage({String? imageBase64}) async {
    if (isLoading) return;
    final message = userMessage.text.trim();
    if (message.isEmpty && imageBase64 == null) return;

    userMessage.clear();
    initBotResponse();

    messages.add(
      Message(
        isUser: true,
        message: message,
        image: image,
        date: DateTime.now(),
      ),
    );

    isLoading = true;
    notifyListeners();

    try {
      final List<Content> content = [];
      if (message.isNotEmpty) content.add(Content.text(message));
      if (imageBase64 != null) {
        content.add(Content.data('image/jpeg', base64Decode(imageBase64)));
      }

      final response = await model.generateContent(content);
      final botMessage = response.text ?? "لم يتم استلام رد";

      for (var char in botMessage.characters) {
        streamedText += char;
        botResponseController?.add(streamedText);
        await Future.delayed(const Duration(milliseconds: 30));
      }

      messages.add(
        Message(isUser: false, message: streamedText, date: DateTime.now()),
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;
    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    image = File(pickedFile.path);
    notifyListeners();
    await sendMessage(imageBase64: base64Image);
  }

  @override
  void dispose() {
    botResponseController?.close();
    speech.stop();
    super.dispose();
  }
}