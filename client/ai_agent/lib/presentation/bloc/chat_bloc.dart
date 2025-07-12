import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  ChatBloc(this._chatRepository) : super(const ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
    on<StartNewConversation>(_onStartNewConversation);
    on<LoadExistingMessages>(_onLoadExistingMessages);
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    final currentState = state;
    List<ChatMessage> currentMessages = [];

    if (currentState is ChatLoaded) {
      currentMessages = List.from(currentState.messages);
    }

    final currentThreadId = _chatRepository.getCurrentThreadId();

    // Add user message
    final userMessage = ChatMessage(id: DateTime.now().millisecondsSinceEpoch.toString(), content: event.message, isUser: true, timestamp: DateTime.now(), threadId: currentThreadId);

    currentMessages.add(userMessage);

    // Save user message to storage
    try {
      await _chatRepository.saveMessage(userMessage);
    } catch (e) {
      print('Warning: Failed to save user message to storage: $e');
      // Continue execution even if storage fails
    }

    // Add loading message for agent response
    final loadingMessage = ChatMessage(id: '${DateTime.now().millisecondsSinceEpoch}_loading', content: 'Thinking...', isUser: false, timestamp: DateTime.now(), isLoading: true, threadId: currentThreadId);

    currentMessages.add(loadingMessage);

    emit(ChatLoaded(messages: currentMessages, isLoading: true));

    try {
      // Send message to agent
      final response = await _chatRepository.sendMessage(event.message);

      // Remove loading message and add actual response
      currentMessages.removeLast();

      final agentMessage = ChatMessage(id: DateTime.now().millisecondsSinceEpoch.toString(), content: response, isUser: false, timestamp: DateTime.now(), threadId: currentThreadId);

      currentMessages.add(agentMessage);

      // Save agent message to storage
      try {
        await _chatRepository.saveMessage(agentMessage);
      } catch (e) {
        print('Warning: Failed to save agent message to storage: $e');
        // Continue execution even if storage fails
      }

      emit(ChatLoaded(messages: currentMessages, isLoading: false));
    } catch (e) {
      // Remove loading message
      currentMessages.removeLast();

      emit(ChatError(message: e.toString(), messages: currentMessages));
    }
  }

  Future<void> _onClearChat(ClearChat event, Emitter<ChatState> emit) async {
    // Start a new conversation with a new thread ID
    await _chatRepository.startNewConversation();
    emit(const ChatLoaded(messages: []));
  }

  Future<void> _onStartNewConversation(StartNewConversation event, Emitter<ChatState> emit) async {
    // Start a completely new conversation with new thread ID
    await _chatRepository.startNewConversation();
    emit(const ChatLoaded(messages: []));
  }

  Future<void> _onLoadExistingMessages(LoadExistingMessages event, Emitter<ChatState> emit) async {
    try {
      // Load existing messages for current thread
      final existingMessages = _chatRepository.getMessages();
      print('Loaded ${existingMessages.length} existing messages for current thread');
      for (final message in existingMessages) {
        print('Message: ${message.content.substring(0, message.content.length > 30 ? 30 : message.content.length)}... (Thread: ${message.threadId})');
      }
      emit(ChatLoaded(messages: existingMessages));
    } catch (e) {
      print('Error loading existing messages: $e');
      emit(const ChatLoaded(messages: []));
    }
  }
}
