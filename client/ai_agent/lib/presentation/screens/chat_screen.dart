import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import '../../core/di/injection.dart';
import '../../data/models/chat_message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load existing messages when chat opens
    context.read<ChatBloc>().add(const LoadExistingMessages());

    // Add listener to update send button state
    _messageController.addListener(() {
      setState(() {});
    });

    // Scroll to bottom after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatBloc>().add(SendMessage(message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (!mounted) return;

    // Try immediate scroll first
    if (_scrollController.hasClients) {
      try {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        return;
      } catch (e) {
        // If immediate scroll fails, try delayed scroll
      }
    }

    // Fallback to delayed scroll with multiple attempts
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients && mounted) {
        try {
          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        } catch (e) {
          // Try one more time with a longer delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_scrollController.hasClients && mounted) {
              try {
                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
              } catch (e) {
                // Silent fail - scroll controller not ready
              }
            }
          });
        }
      }
    });
  }

  String _formatMessageContent(String content) {
    // Remove surrounding quotes if present
    String formatted = content.trim();
    if (formatted.startsWith('"') && formatted.endsWith('"')) {
      formatted = formatted.substring(1, formatted.length - 1);
    }

    // Replace escaped newlines with actual newlines
    formatted = formatted.replaceAll('\\n', '\n');

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        // Close keyboard when background is tapped
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface)),
          title: Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withAlpha(200)]), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('AI Lead Assistant', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)), Text('Online', style: theme.textTheme.bodySmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w500))])),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<ChatBloc>().add(const StartNewConversation());
              },
              icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurfaceVariant),
              tooltip: 'New Chat',
            ),
          ],
        ),
        body: Column(
          children: [
            // Chat messages
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) {
                    // Always scroll to bottom when chat is loaded (including initial load)
                    _scrollToBottom();
                  } else if (state is ChatError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}'), backgroundColor: colorScheme.error, behavior: SnackBarBehavior.floating));
                  }
                },
                builder: (context, state) {
                  if (state is ChatInitial) {
                    return _buildWelcomeMessage(context);
                  } else if (state is ChatLoaded || state is ChatError) {
                    final messages = state is ChatLoaded ? state.messages : (state as ChatError).messages;

                    if (messages.isEmpty) {
                      return _buildWelcomeMessage(context);
                    }

                    return _buildMessagesList(context, messages);
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            // Input field
            _buildInputField(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: LinearGradient(colors: [colorScheme.primary.withAlpha(40), colorScheme.primary.withAlpha(15)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: colorScheme.primary.withAlpha(20), blurRadius: 16, offset: const Offset(0, 6))]), child: Icon(Icons.smart_toy_rounded, size: 56, color: colorScheme.primary)),
            const SizedBox(height: 24),
            Text('AI Lead Assistant', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 22)),
            const SizedBox(height: 12),
            Text('Ask me to help you manage your leads!\nI can show, add, update, or delete leads for you.', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5, fontSize: 15), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, List<ChatMessage> messages) {
    // Ensure scroll to bottom after ListView is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(context, messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(width: 36, height: 36, decoration: BoxDecoration(gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withAlpha(200)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: colorScheme.primary.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2))]), child: Icon(Icons.smart_toy_rounded, size: 20, color: Colors.white)),
            const SizedBox(width: 12),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: message.isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4), bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 3))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isLoading)
                    Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary))), const SizedBox(width: 12), Text(message.content, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface))])
                  else if (!message.isUser)
                    // Use markdown for AI responses
                    MarkdownBody(
                      data: _formatMessageContent(message.content),
                      styleSheet: MarkdownStyleSheet(
                        p: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, height: 1.5, fontSize: 15),
                        h1: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                        h2: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                        h3: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                        strong: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15),
                        em: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontStyle: FontStyle.italic, fontSize: 15),
                        code: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary, backgroundColor: colorScheme.surfaceContainerHigh, fontFamily: 'monospace', fontSize: 14),
                        codeblockDecoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(8), border: Border.all(color: colorScheme.outline.withAlpha(50))),
                        blockquote: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic, fontSize: 15),
                        blockquoteDecoration: BoxDecoration(color: colorScheme.surfaceContainerHigh.withAlpha(50), border: Border(left: BorderSide(color: colorScheme.primary, width: 3))),
                        listBullet: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontSize: 15),
                      ),
                      selectable: true,
                    )
                  else
                    // Use regular text for user messages
                    Text(_formatMessageContent(message.content), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, height: 1.5, fontSize: 15)),

                  const SizedBox(height: 8),

                  Text(DateFormat('HH:mm').format(message.timestamp), style: theme.textTheme.labelSmall?.copyWith(color: message.isUser ? Colors.white.withAlpha(180) : colorScheme.onSurfaceVariant.withAlpha(180), fontSize: 11)),
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(width: 36, height: 36, decoration: BoxDecoration(gradient: LinearGradient(colors: [colorScheme.secondary, colorScheme.secondary.withAlpha(200)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: colorScheme.secondary.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2))]), child: Icon(Icons.person_rounded, size: 20, color: Colors.white)),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colorScheme.surface, border: Border(top: BorderSide(color: colorScheme.outline.withAlpha(30), width: 0.5))),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input
            Expanded(child: Container(decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(28), border: Border.all(color: colorScheme.outline.withAlpha(40), width: 0.5), boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8, offset: const Offset(0, 2))]), child: TextField(controller: _messageController, focusNode: _focusNode, decoration: InputDecoration(hintText: 'Type your message...', border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withAlpha(150), fontSize: 16)), maxLines: 5, minLines: 1, textInputAction: TextInputAction.send, onSubmitted: (_) => _sendMessage(), style: TextStyle(color: colorScheme.onSurface, fontSize: 16, height: 1.4)))),

            const SizedBox(width: 12),

            // Mic button - Primary action (replaces send button)
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final isLoading = state is ChatLoaded && state.isLoading;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withAlpha(200)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: colorScheme.primary.withAlpha(30), blurRadius: 12, offset: const Offset(0, 4)), BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 8))]),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap:
                          isLoading
                              ? null
                              : () {
                                HapticFeedback.mediumImpact();
                                // TODO: Implement voice input
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Icon(Icons.mic_rounded, color: Colors.white, size: 20), const SizedBox(width: 8), const Text('🎤 Voice input coming soon!')]), backgroundColor: colorScheme.primary, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                              },
                      child: Container(width: 56, height: 56, alignment: Alignment.center, child: isLoading ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Icon(Icons.mic_rounded, color: Colors.white, size: 28)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
