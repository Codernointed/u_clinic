import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/chat/chat_bloc.dart';
import '../../providers/chat/chat_event.dart';
import '../../providers/chat/chat_state.dart';
import '../../providers/auth/auth_bloc.dart';
import '../../providers/auth/auth_state.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/enums/user_role.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasTriedReload = false;

  @override
  void initState() {
    super.initState();
    // Load chat messages
    context.read<ChatBloc>().add(LoadChatMessages(widget.chat.id));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _buildAppBarTitle(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickFile),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptions,
          ),
        ],
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildChatHeader(),
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    // Get current user role to show appropriate information
    final authState = context.read<AuthBloc>().state;
    bool isStaff = false;

    if (authState is AuthAuthenticated) {
      isStaff =
          authState.user.role == UserRole.staff ||
          authState.user.role == UserRole.admin;
    }

    final displayName = isStaff
        ? widget.chat.patientName
        : (widget.chat.staffName ?? 'Healthcare Staff');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.chat.subject ?? 'No Subject',
          style: AppTypography.heading5.copyWith(color: Colors.white),
        ),
        Text(
          '$displayName • ${widget.chat.chatType}',
          style: AppTypography.caption.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildChatHeader() {
    // Get current user role to show appropriate information
    final authState = context.read<AuthBloc>().state;
    bool isStaff = false;

    if (authState is AuthAuthenticated) {
      isStaff =
          authState.user.role == UserRole.staff ||
          authState.user.role == UserRole.admin;
    }

    final displayName = isStaff
        ? widget.chat.patientName
        : (widget.chat.staffName ?? 'Healthcare Staff');

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dr. $displayName", style: AppTypography.heading5),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(widget.chat.chatType, style: AppTypography.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingS,
              vertical: AppDimensions.spacingXS,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.chat.status),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              widget.chat.status,
              style: AppTypography.caption.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        // Only reload once if we get an error or empty list
        if ((state is ChatError ||
                (state is MessagesLoaded && state.messages.isEmpty)) &&
            !_hasTriedReload) {
          print('🔄 Force reloading messages once');
          _hasTriedReload = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.read<ChatBloc>().add(LoadChatMessages(widget.chat.id));
            }
          });
        }

        // Debug real-time message updates
        if (state is MessagesLoaded) {
          print(
            '📱 DEBUG: MessagesLoaded state with ${state.messages.length} messages',
          );
          for (var msg in state.messages) {
            print('📱 DEBUG MSG: ${msg.id} | ${msg.senderId} | ${msg.content}');
          }
        }
      },
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use the actual messages only
        if (state is MessagesLoaded) {
          print('📱 Displaying ${state.messages.length} messages in UI');
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return _buildMessageItem(message);
            },
          );
        }
        // Check for error state
        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'Error loading messages',
                  style: AppTypography.heading5.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                ElevatedButton(
                  onPressed: () {
                    context.read<ChatBloc>().add(
                      LoadChatMessages(widget.chat.id),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty state
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                'No messages yet',
                style: AppTypography.heading5.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                'Start the conversation by sending a message',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    // Get current user info to determine if this is their message
    final authState = context.read<AuthBloc>().state;
    String currentUserId = 'unknown';

    if (authState is AuthAuthenticated) {
      currentUserId = authState.user.id;
    }

    final isMyMessage = message.senderId == currentUserId;

    // Get display name for the sender
    String senderDisplayName = 'Unknown';
    String senderInitial = 'U';

    if (isMyMessage) {
      // Current user's message
      if (authState is AuthAuthenticated) {
        senderDisplayName =
            '${authState.user.firstName} ${authState.user.lastName}';
        senderInitial = authState.user.firstName.isNotEmpty
            ? authState.user.firstName.substring(0, 1).toUpperCase()
            : 'U';
      }
    } else {
      // Other user's message - get name from chat
      final authState = context.read<AuthBloc>().state;
      bool isStaff = false;

      if (authState is AuthAuthenticated) {
        isStaff =
            authState.user.role == UserRole.staff ||
            authState.user.role == UserRole.admin;
      }

      if (isStaff) {
        // Current user is staff, so sender is patient
        senderDisplayName = widget.chat.patientName;
        senderInitial = widget.chat.patientName.isNotEmpty
            ? widget.chat.patientName.substring(0, 1).toUpperCase()
            : 'P';
      } else {
        // Current user is patient, so sender is staff
        senderDisplayName = widget.chat.staffName ?? 'Healthcare Staff';
        senderInitial = senderDisplayName.isNotEmpty
            ? senderDisplayName.substring(0, 1).toUpperCase()
            : 'H';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        mainAxisAlignment: isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMyMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                senderInitial,
                style: AppTypography.bodySmall.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: isMyMessage ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: isMyMessage
                    ? null
                    : Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMyMessage) ...[
                    Text(
                      senderDisplayName,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                  ],
                  Text(
                    message.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isMyMessage ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    _formatTime(message.createdAt),
                    style: AppTypography.caption.copyWith(
                      color: isMyMessage
                          ? Colors.white70
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMyMessage) ...[
            const SizedBox(width: AppDimensions.spacingS),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                senderInitial,
                style: AppTypography.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingS,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Get current user info from auth state
    final authState = context.read<AuthBloc>().state;
    String senderId = 'unknown-user';

    if (authState is AuthAuthenticated) {
      senderId = authState.user.id;
    }

    // Get sender name
    String senderName = 'User';
    if (authState is AuthAuthenticated) {
      senderName = '${authState.user.firstName} ${authState.user.lastName}';
    }

    final message = ChatMessage(
      id: '', // Will be set by the server
      chatId: widget.chat.id,
      senderId: senderId,
      senderName: senderName,
      messageType: 'text',
      content: content,
      isRead: false,
      createdAt: DateTime.now(),
    );

    context.read<ChatBloc>().add(SendMessage(message));
    _messageController.clear();

    // Add a local copy of the message to display immediately
    setState(() {
      // Reset reload flag to allow one more reload after sending
      _hasTriedReload = false;
    });

    // Listen for message sent confirmation then reload
    final subscription = context.read<ChatBloc>().stream.listen((state) {
      if (state is MessageSent) {
        // Reload messages to ensure they display
        context.read<ChatBloc>().add(LoadChatMessages(widget.chat.id));
        _scrollToBottom();
      }
    });

    // Cancel subscription after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      subscription.cancel();
    });
  }

  void _pickFile() {
    // TODO: Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File attachment coming soon!')),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Close Chat'),
              onTap: _closeChat,
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Chat'),
              onTap: _deleteChat,
            ),
          ],
        ),
      ),
    );
  }

  void _closeChat() {
    // TODO: Implement close chat
    Navigator.of(context).pop();
  }

  void _deleteChat() {
    // TODO: Implement delete chat
    Navigator.of(context).pop();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'closed':
        return AppColors.textTertiary;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textTertiary;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
