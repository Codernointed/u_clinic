import 'package:flutter/material.dart';
import 'package:u_clinic/core/constants/app_constants.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/domain/enums/consultation_type.dart';

class EConsultationScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final String department;
  final ConsultationType consultationType;

  const EConsultationScreen({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.department,
    required this.consultationType,
  });

  @override
  State<EConsultationScreen> createState() => _EConsultationScreenState();
}

class _EConsultationScreenState extends State<EConsultationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isCallActive = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isScreenShared = false;
  bool _isRecording = false;

  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeChat();
  }

  void _initializeChat() {
    // Add some initial chat messages
    _chatMessages.addAll([
      ChatMessage(
        sender: 'Dr. ${widget.doctorName}',
        message: 'Hello! How are you feeling today?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isFromDoctor: true,
      ),
      ChatMessage(
        sender: 'You',
        message: 'Hi Doctor, I\'ve been experiencing some symptoms...',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        isFromDoctor: false,
      ),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'E-Consultation',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Dr. ${widget.doctorName} - ${widget.department}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _showConsultationInfo,
            icon: const Icon(Icons.info_outline, color: AppColors.primary),
            tooltip: 'Consultation Info',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            if (widget.consultationType == ConsultationType.video)
              const Tab(text: 'Video'),
            if (widget.consultationType == ConsultationType.voice)
              const Tab(text: 'Voice'),
            const Tab(text: 'Chat'),
            const Tab(text: 'Notes'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isCallActive && widget.consultationType != ConsultationType.text)
            _buildCallControls(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                if (widget.consultationType == ConsultationType.video)
                  _buildVideoTab(),
                if (widget.consultationType == ConsultationType.voice)
                  _buildVoiceTab(),
                _buildChatTab(),
                _buildNotesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCallButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            color: _isMuted ? AppColors.warning : AppColors.primary,
            onPressed: _toggleMute,
          ),
          if (widget.consultationType == ConsultationType.video)
            _buildCallButton(
              icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              label: _isVideoEnabled ? 'Stop Video' : 'Start Video',
              color: _isVideoEnabled ? AppColors.primary : AppColors.warning,
              onPressed: _toggleVideo,
            ),
          _buildCallButton(
            icon: _isScreenShared
                ? Icons.stop_screen_share
                : Icons.screen_share,
            label: _isScreenShared ? 'Stop Sharing' : 'Share Screen',
            color: _isScreenShared ? AppColors.warning : AppColors.primary,
            onPressed: _toggleScreenShare,
          ),
          _buildCallButton(
            icon: _isRecording ? Icons.stop : Icons.fiber_manual_record,
            label: _isRecording ? 'Stop Recording' : 'Record',
            color: _isRecording ? AppColors.emergency : AppColors.primary,
            onPressed: _toggleRecording,
          ),
          _buildCallButton(
            icon: Icons.call_end,
            label: 'End Call',
            color: AppColors.emergency,
            onPressed: _endCall,
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Stack(
              children: [
                // Main video area
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 64,
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Text(
                        'Waiting for doctor to join...',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Picture-in-picture (patient's own video)
                Positioned(
                  top: AppDimensions.spacingM,
                  right: AppDimensions.spacingM,
                  child: Container(
                    width: 120,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                // Call status
                Positioned(
                  top: AppDimensions.spacingM,
                  left: AppDimensions.spacingM,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingS),
                        Text(
                          'Connected',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildCallActionButtons(),
      ],
    );
  }

  Widget _buildVoiceTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  Text(
                    'Voice Call Active',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    'Dr. ${widget.doctorName}',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.department,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  Text(
                    '00:05:32',
                    style: AppTypography.heading4.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildCallActionButtons(),
      ],
    );
  }

  Widget _buildCallActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.call,
            label: 'Start Call',
            color: AppColors.success,
            onPressed: _startCall,
          ),
          _buildActionButton(
            icon: Icons.schedule,
            label: 'Reschedule',
            color: AppColors.warning,
            onPressed: _rescheduleCall,
          ),
          _buildActionButton(
            icon: Icons.cancel,
            label: 'Cancel',
            color: AppColors.emergency,
            onPressed: _cancelCall,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final message = _chatMessages[index];
              return _buildChatMessage(message);
            },
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    final isFromDoctor = message.isFromDoctor;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFromDoctor) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppDimensions.spacingS),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isFromDoctor
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingM),
                  decoration: BoxDecoration(
                    color: isFromDoctor
                        ? AppColors.primaryLight
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Text(
                    message.message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isFromDoctor
                          ? AppColors.textPrimary
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  _formatTime(message.timestamp),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (!isFromDoctor) ...[
            const SizedBox(width: AppDimensions.spacingS),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _attachFile,
            icon: const Icon(Icons.attach_file, color: AppColors.primary),
            tooltip: 'Attach File',
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: AppColors.primary),
            tooltip: 'Send Message',
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Consultation Notes', Icons.edit_note, [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Symptoms Reported:',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    '• Fever and sore throat\n• Difficulty swallowing\n• Mild headache',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doctor\'s Observations:',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    'Patient appears alert and responsive. Symptoms consistent with viral pharyngitis.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations:',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    '• Rest and hydration\n• Over-the-counter pain relievers\n• Follow up if symptoms worsen',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              title,
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        ...children,
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showConsultationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consultation Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Appointment ID', widget.appointmentId),
            _buildInfoRow('Doctor', 'Dr. ${widget.doctorName}'),
            _buildInfoRow('Department', widget.department),
            _buildInfoRow(
              'Type',
              widget.consultationType.value.replaceAll('_', ' ').toUpperCase(),
            ),
            _buildInfoRow('Date', DateTime.now().toString().split(' ')[0]),
            _buildInfoRow('Time', '10:00 AM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Call control methods
  void _startCall() {
    setState(() {
      _isCallActive = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Call started successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
  }

  void _toggleScreenShare() {
    setState(() {
      _isScreenShared = !_isScreenShared;
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  void _endCall() {
    setState(() {
      _isCallActive = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Call ended'),
        backgroundColor: AppColors.emergency,
      ),
    );
  }

  void _rescheduleCall() {
    // TODO: Implement reschedule functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reschedule functionality coming soon'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _cancelCall() {
    // TODO: Implement cancel functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cancel functionality coming soon'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _attachFile() {
    // TODO: Implement file attachment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File attachment coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = ChatMessage(
        sender: 'You',
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
        isFromDoctor: false,
      );

      setState(() {
        _chatMessages.add(message);
      });

      _messageController.clear();

      // Auto-scroll to bottom
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
  }
}

class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isFromDoctor;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isFromDoctor,
  });
}
