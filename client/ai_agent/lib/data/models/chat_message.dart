import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final bool isUser;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final bool isLoading;

  @HiveField(5)
  final int threadId;

  ChatMessage({required this.id, required this.content, required this.isUser, required this.timestamp, this.isLoading = false, required this.threadId});

  ChatMessage copyWith({String? id, String? content, bool? isUser, DateTime? timestamp, bool? isLoading, int? threadId}) {
    return ChatMessage(id: id ?? this.id, content: content ?? this.content, isUser: isUser ?? this.isUser, timestamp: timestamp ?? this.timestamp, isLoading: isLoading ?? this.isLoading, threadId: threadId ?? this.threadId);
  }
}
