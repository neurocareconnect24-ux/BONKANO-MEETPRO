import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import 'package:bonkano_meet_pro/components/app_scaffold.dart';
import 'package:bonkano_meet_pro/utils/app_common.dart';
import 'chat_controller.dart';
import 'model/chat_message_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: "Discussion Patient",
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (chatController.messages.isEmpty) {
                return const Center(child: Text('Aucun message. Commencez la discussion !'));
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(chatController.messages[index]);
                },
              );
            }),
          ),
          Obx(() => chatController.isUploadingImage.value
              ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
              : const Offstage()),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    bool isMe = message.senderId == loginUserData.value.id;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: boxDecorationDefault(
          color: isMe ? appColorPrimary : Colors.grey.shade200,
          borderRadius: radius(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null)
              Image.network(message.imageUrl!, width: 200, height: 200, fit: BoxFit.cover).paddingBottom(8),
            if (message.documentUrl != null)
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse(message.documentUrl!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    toast("Impossible d'ouvrir le fichier");
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.insert_drive_file, color: isMe ? Colors.white : Colors.black87),
                      8.width,
                      Flexible(
                        child: Text(
                          message.text.replaceAll("📄 Fichier joint : ", ""),
                          style: primaryTextStyle(color: isMe ? Colors.white : Colors.black87, decoration: TextDecoration.underline),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ).paddingBottom(8),
            if (message.text.isNotEmpty && message.text != "📷 Image" && !message.text.startsWith("📄 Fichier joint : "))
              Text(
                message.text,
                style: primaryTextStyle(color: isMe ? Colors.white : Colors.black87),
              ),
            4.height,
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: secondaryTextStyle(size: 10, color: isMe ? Colors.white70 : Colors.black54),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: appColorPrimary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                builder: (BuildContext context) {
                  return SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_camera, color: appColorPrimary),
                          title: const Text('Image (Galerie/Caméra)'),
                          onTap: () {
                            Navigator.pop(context);
                            chatController.sendImage();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.insert_drive_file, color: appColorPrimary),
                          title: const Text('Document (PDF, Word, etc.)'),
                          onTap: () {
                            Navigator.pop(context);
                            chatController.sendDocument();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: chatController.messageController,
              decoration: InputDecoration(
                hintText: "Saisissez un message...",
                border: OutlineInputBorder(borderRadius: radius(20), borderSide: BorderSide.none),
                fillColor: Colors.grey.shade200,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          Obx(() => IconButton(
                icon: chatController.isSendingMessage.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send, color: appColorPrimary),
                onPressed: chatController.isSendingMessage.value ? null : () => chatController.sendMessage(),
              )),
        ],
      ),
    );
  }
}
