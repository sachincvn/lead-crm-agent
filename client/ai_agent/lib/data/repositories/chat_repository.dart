import 'package:dio/dio.dart';
import '../services/agent_api_service.dart';
import '../services/chat_storage_service.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final AgentApiService _apiService;
  final ChatStorageService _storageService;

  ChatRepository(this._apiService, this._storageService);

  Future<String> sendMessage(String prompt) async {
    try {
      final currentThreadId = _storageService.getCurrentThreadId();

      final response = await _apiService.generateResponse({'prompt': prompt, 'thread_id': currentThreadId});

      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
        return 'I apologize, but the connection timed out. Please check your internet connection and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        return 'I\'m currently unable to connect to the AI service. Please ensure the server is running and try again.';
      } else if (e.response?.statusCode == 404) {
        return 'The AI agent service endpoint was not found. Please check the server configuration.';
      } else if (e.response?.statusCode == 500) {
        return 'The server encountered an error. Please try again in a moment.';
      } else {
        return 'I encountered a network error: ${e.message ?? "Unknown error"}. Please try again.';
      }
    } catch (e) {
      return 'I\'m sorry, but I encountered an unexpected error. Please try again later.';
    }
  }

  Future<void> saveMessage(ChatMessage message) async {
    await _storageService.saveMessage(message);
  }

  List<ChatMessage> getMessages() {
    print('ChatRepository: Getting messages...');
    final messages = _storageService.getAllMessages();
    print('ChatRepository: Retrieved ${messages.length} messages');
    return messages;
  }

  Future<void> clearCurrentThread() async {
    final currentThreadId = _storageService.getCurrentThreadId();
    await _storageService.clearThread(currentThreadId);
  }

  Future<int> startNewConversation() async {
    return await _storageService.startNewConversation();
  }

  int getCurrentThreadId() {
    return _storageService.getCurrentThreadId();
  }

  Map<String, dynamic> getThreadStats() {
    return _storageService.getThreadStats();
  }
}
