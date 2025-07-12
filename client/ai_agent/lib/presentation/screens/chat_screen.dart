import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  // Speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;

  // Text to speech
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  String? _currentSpeakingMessageId;
  bool _autoSpeakEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();

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

  // Initialize speech to text
  void _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status'); // Debug log
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        } else if (status == 'listening') {
          setState(() {
            _isListening = true;
          });
        }
      },
      onError: (error) {
        print('Speech error: ${error.errorMsg}'); // Debug log
        setState(() {
          _isListening = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Speech recognition error: ${error.errorMsg}'), backgroundColor: Theme.of(context).colorScheme.error));
        }
      },
      debugLogging: true, // Enable debug logging
    );
  }

  // Start listening for speech
  void _startListening() async {
    // Stop any current TTS playback when starting voice input
    if (_isSpeaking) {
      _stopSpeaking();
    }

    // Check microphone permission
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Microphone permission is required for voice input'), backgroundColor: Theme.of(context).colorScheme.error));
      }
      return;
    }

    if (_speechEnabled && !_isListening) {
      setState(() {
        _isListening = true;
        _messageController.clear(); // Clear previous text
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });

          // Only send when we get the final result
          if (result.finalResult) {
            setState(() {
              _isListening = false;
            });
            // Auto-send the message after speech recognition
            if (result.recognizedWords.trim().isNotEmpty) {
              _sendMessage();
            }
          }
        },
        listenFor: const Duration(seconds: 60), // Extended listening time
        pauseFor: const Duration(seconds: 6), // Longer pause to handle natural speech patterns
        listenOptions: stt.SpeechListenOptions(
          partialResults: true, // Enable real-time transcription
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation, // Better for natural speech
          autoPunctuation: true, // Better sentence handling
          enableHapticFeedback: true, // Feedback when listening
        ),
        localeId: 'en_US',
      );
    }
  }

  // Stop listening for speech
  void _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  // Initialize text to speech
  void _initTts() async {
    _flutterTts = FlutterTts();

    // Set language to Hindi for better Indian accent
    await _flutterTts.setLanguage("hi-IN");
    // Fallback to English if Hindi not available
    List<dynamic> languages = await _flutterTts.getLanguages;
    if (!languages.contains("hi-IN")) {
      await _flutterTts.setLanguage("en-IN"); // Indian English
    }

    await _flutterTts.setSpeechRate(0.6); // Slightly faster for better flow
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.1); // Slightly higher pitch for clarity

    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _currentSpeakingMessageId = null;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
        _currentSpeakingMessageId = null;
      });
    });
  }

  // Speak the AI response
  void _speakText(String text, String messageId) async {
    // Stop any current speech first (only one audio at a time)
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
        _currentSpeakingMessageId = null;
      });
      // Small delay to ensure stop is processed
      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      _currentSpeakingMessageId = messageId;
    });

    // Clean the text for better speech - comprehensive markdown removal
    String cleanText = _formatMessageContent(text);

    // Remove all markdown formatting for clean speech
    cleanText = cleanText.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1'); // Bold **text**
    cleanText = cleanText.replaceAll(RegExp(r'\*(.*?)\*'), r'$1'); // Italic *text*
    cleanText = cleanText.replaceAll(RegExp(r'`(.*?)`'), r'$1'); // Inline code `text`
    cleanText = cleanText.replaceAll(RegExp(r'```[\s\S]*?```'), ''); // Code blocks
    cleanText = cleanText.replaceAll(RegExp(r'#{1,6}\s*'), ''); // Headers # ## ###
    cleanText = cleanText.replaceAll(RegExp(r'[-*+]\s*'), ''); // List items - * +
    cleanText = cleanText.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1'); // Links [text](url)
    cleanText = cleanText.replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]+\)'), r'$1'); // Images ![alt](url)
    cleanText = cleanText.replaceAll(RegExp(r'>\s*'), ''); // Blockquotes >
    cleanText = cleanText.replaceAll(RegExp(r'\|[^|\n]*\|'), ''); // Tables |col1|col2|
    cleanText = cleanText.replaceAll(RegExp(r'---+'), ''); // Horizontal rules ---
    cleanText = cleanText.replaceAll(RegExp(r'\n\s*\n'), '. '); // Multiple newlines to period
    cleanText = cleanText.replaceAll(RegExp(r'\n'), ' '); // Single newlines to space
    cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' '); // Multiple spaces to single space

    // Replace common English words with Hindi equivalents for better pronunciation
    cleanText = cleanText.replaceAll(RegExp(r'\blead\b', caseSensitive: false), 'लीड');
    cleanText = cleanText.replaceAll(RegExp(r'\bmeeting\b', caseSensitive: false), 'मीटिंग');
    cleanText = cleanText.replaceAll(RegExp(r'\bsite visit\b', caseSensitive: false), 'साइट विजिट');
    cleanText = cleanText.replaceAll(RegExp(r'\bphone\b', caseSensitive: false), 'फोन');
    cleanText = cleanText.replaceAll(RegExp(r'\bstatus\b', caseSensitive: false), 'स्टेटस');
    cleanText = cleanText.replaceAll(RegExp(r'\bname\b', caseSensitive: false), 'नाम');

    // Final cleanup
    cleanText = cleanText.trim();

    if (cleanText.isNotEmpty) {
      await _flutterTts.speak(cleanText);
    }
  }

  // Stop speaking
  void _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
      _currentSpeakingMessageId = null;
    });
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
            // Auto-speak toggle button
            Tooltip(
              message: _autoSpeakEnabled ? 'Auto-speak ON' : 'Auto-speak OFF',
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _autoSpeakEnabled = !_autoSpeakEnabled;
                  });
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Icon(_autoSpeakEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded, color: Colors.white, size: 20), const SizedBox(width: 8), Text(_autoSpeakEnabled ? 'Auto-speak enabled' : 'Auto-speak disabled')]), backgroundColor: _autoSpeakEnabled ? Colors.green : colorScheme.primary, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                },
                icon: Icon(_autoSpeakEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded, color: _autoSpeakEnabled ? Colors.green : colorScheme.onSurfaceVariant),
              ),
            ),
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

                    // Auto-speak the latest AI response if auto-speak is enabled
                    if (_autoSpeakEnabled && state.messages.isNotEmpty) {
                      final lastMessage = state.messages.last;
                      if (!lastMessage.isUser && !lastMessage.isLoading) {
                        // Small delay to ensure the message is displayed first
                        Future.delayed(const Duration(milliseconds: 500), () {
                          final messageId = lastMessage.timestamp.millisecondsSinceEpoch.toString();
                          _speakText(lastMessage.content, messageId);
                        });
                      }
                    }
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('HH:mm').format(message.timestamp), style: theme.textTheme.labelSmall?.copyWith(color: message.isUser ? Colors.white.withAlpha(180) : colorScheme.onSurfaceVariant.withAlpha(180), fontSize: 11)),

                      // Speaker button for AI responses only
                      if (!message.isUser && !message.isLoading)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            final messageId = message.timestamp.millisecondsSinceEpoch.toString();
                            if (_isSpeaking && _currentSpeakingMessageId == messageId) {
                              // Stop current speech if this message is speaking
                              _stopSpeaking();
                            } else {
                              // Start speaking this message (will stop any other speech first)
                              _speakText(message.content, messageId);
                            }
                          },
                          child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: (_isSpeaking && _currentSpeakingMessageId == message.timestamp.millisecondsSinceEpoch.toString()) ? colorScheme.primary.withAlpha(40) : colorScheme.primary.withAlpha(20), borderRadius: BorderRadius.circular(12)), child: Icon((_isSpeaking && _currentSpeakingMessageId == message.timestamp.millisecondsSinceEpoch.toString()) ? Icons.stop_rounded : Icons.volume_up_rounded, size: 16, color: colorScheme.primary)),
                        ),
                    ],
                  ),
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
                                if (_isListening) {
                                  _stopListening();
                                } else {
                                  // Stop any TTS before starting voice input
                                  if (_isSpeaking) {
                                    _stopSpeaking();
                                  }
                                  _startListening();
                                }
                              },
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: _isListening ? BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.red.withAlpha(100), blurRadius: 10, spreadRadius: 2)]) : null,
                        child:
                            isLoading
                                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : _isListening
                                ? Icon(Icons.stop_rounded, color: Colors.white, size: 28)
                                : Icon(Icons.mic_rounded, color: Colors.white, size: 28),
                      ),
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
