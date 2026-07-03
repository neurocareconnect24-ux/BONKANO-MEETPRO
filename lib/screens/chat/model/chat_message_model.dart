import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final int appointmentId;
  final int senderId;     // The id of the person who sent it (Doctor or Patient)
  final int receiverId;   // The id of the person receiving it
  final String text;
  final String? imageUrl;
  final String? documentUrl;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.appointmentId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.imageUrl,
    this.documentUrl,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      appointmentId: map['appointmentId'] ?? 0,
      senderId: map['senderId'] ?? 0,
      receiverId: map['receiverId'] ?? 0,
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      documentUrl: map['documentUrl'],
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
