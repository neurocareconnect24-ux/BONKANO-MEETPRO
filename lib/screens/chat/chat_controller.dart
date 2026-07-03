import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'model/chat_message_model.dart';
import 'services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final TextEditingController messageController = TextEditingController();
  
  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  RxBool isSendingMessage = false.obs;
  RxBool isUploadingImage = false.obs;

  late int appointmentId;
  late int receiverId; // ID of the Patient

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      appointmentId = Get.arguments['appointment_id'];
      receiverId = Get.arguments['receiver_id'];
      _listenToMessages();
    }
  }

  void _listenToMessages() {
    _chatService.getMessages(appointmentId).listen((messageList) {
      messages.value = messageList;
    });
  }

  Future<void> sendMessage() async {
    String text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    isSendingMessage(true);

    try {
      await _chatService.sendMessage(appointmentId, text, receiverId);
    } catch (e) {
      Get.snackbar("Erreur", "Impossible d'envoyer le message : $e",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSendingMessage(false);
    }
  }

  Future<void> sendImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      isUploadingImage(true);
      try {
        await _chatService.sendImageMessage(appointmentId, File(image.path), receiverId);
      } catch (e) {
        Get.snackbar("Erreur", "Impossible d'envoyer l'image : $e",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      } finally {
        isUploadingImage(false);
      }
    }
  }

  Future<void> sendDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      isUploadingImage(true);
      try {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        await _chatService.sendDocumentMessage(appointmentId, file, receiverId, fileName);
      } catch (e) {
        Get.snackbar("Erreur", "Impossible d'envoyer le document : $e",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      } finally {
        isUploadingImage(false);
      }
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
