import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/video_call_service.dart';
import '../../../presentation/providers/auth/auth_bloc.dart';
import '../../../presentation/providers/auth/auth_state.dart';
import '../../../data/repositories/supabase_chat_repository.dart';
import '../../../domain/entities/chat_message.dart';

class ConsultationRoomScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const ConsultationRoomScreen({super.key, this.arguments});

  @override
  State<ConsultationRoomScreen> createState() => _ConsultationRoomScreenState();
}

class _ConsultationRoomScreenState extends State<ConsultationRoomScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isScreenShared = false;
  bool _isConnecting = false;
  bool _isPatientJoined = false;

  // Video call service
  final VideoCallService _videoService = videoCallService;
  StreamSubscription<bool>? _isJoinedSubscription;
  StreamSubscription<int?>? _remoteUidSubscription;

  // Chat variables
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  late SupabaseChatRepository _chatRepository;
  String? _currentChatId;

  // Appointment data
  late String _patientName;
  late String _appointmentTime;
  late String? _reason;
  late String? _symptoms;
  late dynamic _appointment;
  late String _channelName;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _tabController = TabController(length: 3, vsync: this);
    _chatRepository = context.read<SupabaseChatRepository>();
    _initializeVideoCall();
    _initializeChat();
  }

  void _initializeData() {
    final args = widget.arguments;
    if (args != null) {
      _appointment = args['appointment'];
      _patientName = args['patientName'] ?? 'Patient';
      _appointmentTime = args['appointmentTime'] ?? 'Unknown';
      _reason = args['reason'];
      _symptoms = args['symptoms'];
      _channelName =
          'consultation_${_appointment?.id ?? DateTime.now().millisecondsSinceEpoch}';
    } else {
      _patientName = 'Patient';
      _appointmentTime = 'Unknown';
      _channelName = 'consultation_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _initializeVideoCall() async {
    try {
      setState(() {
        _isConnecting = true;
      });

      await _videoService.initialize();

      // Listen to video call events
      _isJoinedSubscription = _videoService.isJoinedStream.listen((isJoined) {
        setState(() {
          _isConnecting = false;
        });
      });

      _remoteUidSubscription = _videoService.remoteUidStream.listen((
        remoteUid,
      ) {
        setState(() {
          _isPatientJoined = remoteUid != null;
        });
      });

      // Join the channel
      await _videoService.joinChannel(_channelName);

      print('✅ Video call initialized for channel: $_channelName');
    } catch (e) {
      print('❌ Failed to initialize video call: $e');
      setState(() {
        _isConnecting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize video call: $e')),
      );
    }
  }

  void _initializeChat() {
    _createConsultationChat();
  }

  Future<void> _createConsultationChat() async {
    try {
      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        final result = await _chatRepository.searchChats(
          state.user.id,
          'consultation_${_appointment?.id ?? DateTime.now().millisecondsSinceEpoch}',
        );

        result.fold(
          (failure) {
            print('❌ Failed to search chats: ${failure.message}');
          },
          (chats) {
            if (chats.isNotEmpty) {
              _currentChatId = chats.first.id;
              _loadChatMessages();
            } else {
              _createNewConsultationChat();
            }
          },
        );
      }
    } catch (e) {
      print('❌ Error initializing chat: $e');
    }
  }

  Future<void> _createNewConsultationChat() async {
    try {
      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        _currentChatId =
            'consultation_${DateTime.now().millisecondsSinceEpoch}';
        _loadChatMessages();
      }
    } catch (e) {
      print('❌ Error creating consultation chat: $e');
    }
  }

  Future<void> _loadChatMessages() async {
    if (_currentChatId == null) return;

    try {
      final result = await _chatRepository.getChatMessages(_currentChatId!);
      result.fold(
        (failure) {
          print('❌ Failed to load chat messages: ${failure.message}');
        },
        (messages) {
          setState(() {
            _chatMessages.clear();
            _chatMessages.addAll(messages);
          });
          _scrollToBottom();
        },
      );
    } catch (e) {
      print('❌ Error loading chat messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentChatId == null)
      return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        final chatMessage = ChatMessage(
          id: '',
          chatId: _currentChatId!,
          senderId: state.user.id,
          messageType: 'text',
          content: message,
          isRead: false,
          createdAt: DateTime.now(),
        );

        final result = await _chatRepository.sendMessage(chatMessage);

        result.fold(
          (failure) {
            print('❌ Failed to send message: ${failure.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send message: ${failure.message}'),
              ),
            );
          },
          (sentMessage) {
            setState(() {
              _chatMessages.add(sentMessage);
            });
            _scrollToBottom();
          },
        );
      }
    } catch (e) {
      print('❌ Error sending message: $e');
    }
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

  Future<void> _toggleMute() async {
    await _videoService.enableLocalAudio(!_isMuted);
    setState(() {
      _isMuted = !_isMuted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMuted ? 'Microphone muted' : 'Microphone unmuted'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _toggleVideo() async {
    await _videoService.enableLocalVideo(!_isVideoEnabled);
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isVideoEnabled ? 'Video enabled' : 'Video disabled'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleScreenShare() {
    setState(() {
      _isScreenShared = !_isScreenShared;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isScreenShared ? 'Screen sharing started' : 'Screen sharing stopped',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _endCall() async {
    await _videoService.leaveChannel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _isJoinedSubscription?.cancel();
    _remoteUidSubscription?.cancel();
    _videoService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main content
            Expanded(
              child: _isConnecting
                  ? _buildConnectingView()
                  : _buildVideoInterface(),
            ),

            // Control buttons
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      color: Colors.black.withOpacity(0.8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _endCall,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consultation with $_patientName',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _appointmentTime,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isPatientJoined ? Icons.person : Icons.person_off,
              color: _isPatientJoined ? Colors.green : Colors.red,
            ),
            onPressed: null,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            'Connecting to video call...',
            style: AppTypography.heading4.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'Channel: $_channelName',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInterface() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Video tab
        _buildVideoView(),
        // Chat tab
        _buildChatView(),
        // Notes tab
        _buildNotesView(),
      ],
    );
  }

  Widget _buildVideoView() {
    return Stack(
      children: [
        // Remote video (full screen)
        _videoService.createRemoteView(),

        // Local video (picture-in-picture)
        Positioned(
          top: AppDimensions.spacingL,
          right: AppDimensions.spacingL,
          child: Container(
            width: 120,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: _videoService.createLocalView(),
            ),
          ),
        ),

        // Call status overlay
        if (_isScreenShared)
          Positioned(
            top: AppDimensions.spacingL,
            left: AppDimensions.spacingL,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.screen_share, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Screen Sharing',
                    style: AppTypography.caption.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatView() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                final isFromDoctor =
                    message.senderId ==
                    (context.read<AuthBloc>().state as AuthAuthenticated)
                        .user
                        .id;

                return _buildChatMessage(message, isFromDoctor);
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingM,
                        vertical: AppDimensions.spacingS,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message, bool isFromDoctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Row(
        mainAxisAlignment: isFromDoctor
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isFromDoctor) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                _patientName[0].toUpperCase(),
                style: AppTypography.caption.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: isFromDoctor ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: isFromDoctor ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (isFromDoctor) ...[
            const SizedBox(width: AppDimensions.spacingS),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesView() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consultation Notes',
            style: AppTypography.heading4.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          if (_reason != null) ...[
            Text(
              'Reason for Visit:',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(_reason!),
            const SizedBox(height: AppDimensions.spacingM),
          ],
          if (_symptoms != null) ...[
            Text(
              'Symptoms:',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(_symptoms!),
            const SizedBox(height: AppDimensions.spacingM),
          ],
          Text(
            'Notes:',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Enter consultation notes here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      color: Colors.black.withOpacity(0.8),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.videocam), text: 'Video'),
                Tab(icon: Icon(Icons.chat), text: 'Chat'),
                Tab(icon: Icon(Icons.note), text: 'Notes'),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute button
              _buildControlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                color: _isMuted ? Colors.red : Colors.white,
                onPressed: _toggleMute,
              ),

              // Video toggle button
              _buildControlButton(
                icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                color: _isVideoEnabled ? Colors.white : Colors.red,
                onPressed: _toggleVideo,
              ),

              // Screen share button
              _buildControlButton(
                icon: Icons.screen_share,
                color: _isScreenShared ? Colors.orange : Colors.white,
                onPressed: _toggleScreenShare,
              ),

              // End call button
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.white),
                  onPressed: _endCall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
