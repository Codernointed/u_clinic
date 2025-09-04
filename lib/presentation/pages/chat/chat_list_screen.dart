import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/chat/chat_bloc.dart';
import '../../providers/chat/chat_event.dart';
import '../../providers/chat/chat_state.dart';
import '../../providers/auth/auth_bloc.dart';
import '../../providers/auth/auth_state.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/enums/user_role.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
      print('👤 Current user ID: $_currentUserId');
      // Load chats for current user
      context.read<ChatBloc>().add(LoadChats(_currentUserId));

      // Force reload chats after a short delay to ensure they display
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          context.read<ChatBloc>().add(LoadChats(_currentUserId));
        }
      });
    } else {
      print('⚠️ User not authenticated, waiting for auth state...');
      // Don't load chats yet, wait for auth state to be available
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && _currentUserId.isEmpty) {
          _currentUserId = state.user.id;
          print('👤 Current user ID: $_currentUserId');
          context.read<ChatBloc>().add(LoadChats(_currentUserId));
        }
      },
      child: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          // Force rebuild when chats are loaded
          if (state is ChatsLoaded) {
            print('🔄 Forcing UI rebuild with ${state.chats.length} chats');
          }
        },
        builder: (context, chatState) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Chats'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _showSearch,
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildChatsList()),
            ],
          ),
          floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                // Show FAB for both patients and staff (staff can create chats with patients)
                return FloatingActionButton(
                  onPressed: _createNewChat,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.chat),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search chats...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              context.read<ChatBloc>().add(LoadChats(_currentUserId));
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
        ),
        onChanged: (query) {
          if (query.isNotEmpty) {
            context.read<ChatBloc>().add(SearchChats(_currentUserId, query));
          } else {
            context.read<ChatBloc>().add(LoadChats(_currentUserId));
          }
        },
      ),
    );
  }

  Widget _buildChatsList() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use real chats only
        if (state is ChatsLoaded) {
          print('📱 Displaying ${state.chats.length} chats');
          if (state.chats.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            itemCount: state.chats.length,
            itemBuilder: (context, index) {
              final chat = state.chats[index];
              return _buildChatItem(chat);
            },
          );
        }

        if (state is SearchResults && state.searchType == 'chats') {
          final chats = state.results as List<Chat>;
          if (chats.isEmpty) {
            return _buildNoSearchResults();
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _buildChatItem(chat);
            },
          );
        }

        if (state is ChatError) {
          return _buildErrorState(state.message);
        }

        return const Center(child: Text('No chats available'));
      },
    );
  }

  Widget _buildChatItem(Chat chat) {
    // Get current user role to show appropriate information
    final authState = context.read<AuthBloc>().state;
    bool isStaff = false;

    if (authState is AuthAuthenticated) {
      isStaff =
          authState.user.role == UserRole.staff ||
          authState.user.role == UserRole.admin;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            chat.patientName.isNotEmpty
                ? chat.patientName[0].toUpperCase()
                : 'U',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
        ),
        title: Text(
          isStaff ? 'Patient: ${chat.patientName}' : chat.patientName,
          style: AppTypography.heading5,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chat.subject ?? 'No subject', style: AppTypography.bodyMedium),
            const SizedBox(height: AppDimensions.spacingXS),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingS,
                    vertical: AppDimensions.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(chat.status),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    chat.status,
                    style: AppTypography.caption.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingS,
                    vertical: AppDimensions.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardConsultation,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    chat.chatType,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (chat.description != null && chat.description!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingXS),
              Text(
                chat.description!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_formatTime(chat.createdAt), style: AppTypography.caption),
            const SizedBox(height: AppDimensions.spacingXS),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
        onTap: () => _openChat(chat),
      ),
    );
  }

  Widget _buildEmptyState() {
    // Get current user role
    final authState = context.read<AuthBloc>().state;
    bool isStaff = false;

    if (authState is AuthAuthenticated) {
      isStaff =
          authState.user.role == UserRole.staff ||
          authState.user.role == UserRole.admin;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isStaff ? Icons.support_agent : Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            isStaff ? 'No patient chats yet' : 'No chats yet',
            style: AppTypography.heading5.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            isStaff
                ? 'When patients start conversations, they will appear here'
                : 'Start a conversation to get help from healthcare staff',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          if (!isStaff)
            ElevatedButton(
              onPressed: _createNewChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start New Chat'),
            ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            'No chats found',
            style: AppTypography.heading5.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Try a different search term',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            'Error loading chats',
            style: AppTypography.heading5.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ElevatedButton(
            onPressed: () {
              context.read<ChatBloc>().add(LoadChats(_currentUserId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showSearch() {
    // Search is already available in the search bar
    // This could be used for advanced search options
  }

  void _createNewChat() {
    showDialog(
      context: context,
      builder: (context) => _CreateChatDialog(
        userId: _currentUserId,
        onChatCreated: (chat) {
          Navigator.pop(context);
          _openChat(chat);
        },
      ),
    );
  }

  void _openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)),
    );
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
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _CreateChatDialog extends StatefulWidget {
  final String userId;
  final Function(Chat) onChatCreated;

  const _CreateChatDialog({required this.userId, required this.onChatCreated});

  @override
  State<_CreateChatDialog> createState() => _CreateChatDialogState();
}

class _CreateChatDialogState extends State<_CreateChatDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedChatType = 'consultation';
  String? _selectedPatientId;
  String? _selectedPatientName;
  bool _isCreating = false;
  List<Map<String, String>> _patients = [];
  bool _isLoadingPatients = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadPatients() async {
    try {
      // Load real patients from Supabase
      final response = await SupabaseService.instance
          .from('users')
          .select('id, first_name, last_name')
          .eq('role', 'patient')
          .limit(50);

      final patients = (response as List)
          .map(
            (user) => {
              'id': user['id'] as String,
              'name': '${user['first_name']} ${user['last_name']}' as String,
            },
          )
          .toList();

      if (mounted) {
        setState(() {
          _patients = patients;
          _isLoadingPatients = false;
        });
      }

      print('✅ Loaded ${patients.length} real patients for chat');
    } catch (e) {
      print('❌ Error loading patients: $e');
      if (mounted) {
        setState(() {
          _patients = [
            {'id': 'demo1', 'name': 'Demo Patient 1'},
            {'id': 'demo2', 'name': 'Demo Patient 2'},
          ];
          _isLoadingPatients = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if current user is staff
    final authState = context.read<AuthBloc>().state;
    bool isStaff = false;

    if (authState is AuthAuthenticated) {
      isStaff =
          authState.user.role == UserRole.staff ||
          authState.user.role == UserRole.admin;
    }

    return AlertDialog(
      title: Text(isStaff ? 'Start Chat with Patient' : 'Start New Chat'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isStaff) ...[
              if (_isLoadingPatients)
                const CircularProgressIndicator()
              else
                DropdownButtonFormField<String>(
                  value: _selectedPatientId,
                  decoration: const InputDecoration(
                    labelText: 'Select Patient',
                    border: OutlineInputBorder(),
                  ),
                  items: _patients.map((patient) {
                    return DropdownMenuItem(
                      value: patient['id'],
                      child: Text(patient['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPatientId = value;
                      _selectedPatientName = _patients.firstWhere(
                        (p) => p['id'] == value,
                      )['name'];
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a patient';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: AppDimensions.spacingM),
            ],
            DropdownButtonFormField<String>(
              value: _selectedChatType,
              decoration: const InputDecoration(
                labelText: 'Chat Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'consultation',
                  child: Text('Consultation'),
                ),
                DropdownMenuItem(value: 'support', child: Text('Support')),
                DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedChatType = value!;
                });
              },
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createChat,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Start Chat'),
        ),
      ],
    );
  }

  void _createChat() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreating = true;
      });

      try {
        final authState = context.read<AuthBloc>().state;
        bool isStaff = false;

        if (authState is AuthAuthenticated) {
          isStaff =
              authState.user.role == UserRole.staff ||
              authState.user.role == UserRole.admin;
        }

        String patientId = widget.userId;
        String patientName = 'Unknown User';

        if (isStaff && _selectedPatientId != null) {
          // Staff is creating chat with selected patient
          patientId = _selectedPatientId!;
          patientName = _selectedPatientName ?? 'Unknown Patient';
        } else if (authState is AuthAuthenticated) {
          // Patient is creating chat
          patientName =
              '${authState.user.firstName} ${authState.user.lastName}';
        }

        final chat = Chat(
          id: '', // Will be generated by Supabase
          patientId: patientId,
          patientName: patientName,
          chatType: _selectedChatType,
          subject: _subjectController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          status: 'pending',
          createdAt: DateTime.now(),
        );

        context.read<ChatBloc>().add(CreateChat(chat));

        // Listen for chat creation result
        final subscription = context.read<ChatBloc>().stream.listen((state) {
          if (!mounted) return; // Check if widget is still mounted

          if (state is ChatCreated) {
            widget.onChatCreated(state.chat);
            return;
          } else if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error creating chat: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
            if (mounted) {
              setState(() {
                _isCreating = false;
              });
            }
            return;
          }
        });

        // Cancel subscription when widget is disposed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            subscription.cancel();
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating chat: $e'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() {
            _isCreating = false;
          });
        }
      }
    }
  }
}
