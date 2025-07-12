import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';
import 'dart:math';

class ChatStorageService {
  static const String _chatBoxName = 'chat_messages';
  static const String _threadIdKey = 'current_thread_id';

  late Box<ChatMessage> _chatBox;
  late Box _settingsBox;

  Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ChatMessageAdapter());
      }

      // Open boxes
      _chatBox = await Hive.openBox<ChatMessage>(_chatBoxName);
      _settingsBox = await Hive.openBox('settings');

      print('Hive initialized successfully');
    } catch (e) {
      print('Error initializing Hive: $e');
      rethrow;
    }
  }

  // Generate a new unique thread ID
  int generateNewThreadId() {
    final random = Random();
    int newThreadId;

    do {
      newThreadId = random.nextInt(999999) + 100000; // 6-digit number
    } while (_isThreadIdUsed(newThreadId));

    _settingsBox.put(_threadIdKey, newThreadId);
    return newThreadId;
  }

  // Check if thread ID is already used
  bool _isThreadIdUsed(int threadId) {
    return _chatBox.values.any((message) => message.threadId == threadId);
  }

  // Get current thread ID
  int getCurrentThreadId() {
    int? threadId = _settingsBox.get(_threadIdKey);
    if (threadId == null) {
      threadId = generateNewThreadId();
      print('Generated new thread ID: $threadId');
    } else {
      print('Using existing thread ID: $threadId');
    }
    return threadId;
  }

  // Save a message
  Future<void> saveMessage(ChatMessage message) async {
    try {
      await _chatBox.add(message);
      final contentPreview = message.content.length > 20 ? '${message.content.substring(0, 20)}...' : message.content;
      print('Message saved: $contentPreview');
    } catch (e) {
      print('Error saving message: $e');
      rethrow;
    }
  }

  // Get messages for a specific thread
  List<ChatMessage> getMessagesForThread(int threadId) {
    final allMessages = _chatBox.values.toList();
    print('Total messages in storage: ${allMessages.length}');
    for (final message in allMessages) {
      print('Message thread ID: ${message.threadId}, looking for: $threadId');
    }
    final filteredMessages = allMessages.where((message) => message.threadId == threadId).toList();
    filteredMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    print('Filtered messages for thread $threadId: ${filteredMessages.length}');
    return filteredMessages;
  }

  // Get all messages (for current thread)
  List<ChatMessage> getAllMessages() {
    final currentThreadId = getCurrentThreadId();
    final messages = getMessagesForThread(currentThreadId);
    print('Loading ${messages.length} messages for thread $currentThreadId');
    return messages;
  }

  // Clear messages for a specific thread
  Future<void> clearThread(int threadId) async {
    final keysToDelete = <dynamic>[];

    for (int i = 0; i < _chatBox.length; i++) {
      final message = _chatBox.getAt(i);
      if (message?.threadId == threadId) {
        keysToDelete.add(_chatBox.keyAt(i));
      }
    }

    await _chatBox.deleteAll(keysToDelete);
  }

  // Clear all messages
  Future<void> clearAllMessages() async {
    await _chatBox.clear();
  }

  // Start new conversation (generate new thread ID and clear current)
  Future<int> startNewConversation() async {
    final newThreadId = generateNewThreadId();
    return newThreadId;
  }

  // Get thread statistics
  Map<String, dynamic> getThreadStats() {
    final allMessages = _chatBox.values.toList();
    final threadIds = allMessages.map((m) => m.threadId).toSet();

    return {'totalThreads': threadIds.length, 'totalMessages': allMessages.length, 'currentThreadId': getCurrentThreadId(), 'currentThreadMessages': getAllMessages().length};
  }

  // Close boxes
  Future<void> close() async {
    await _chatBox.close();
    await _settingsBox.close();
  }
}
