import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/supabase_service.dart';
import '../../../presentation/providers/auth/auth_bloc.dart';
import '../../../presentation/providers/auth/auth_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _index = 0;

  // Real data from Supabase
  Map<String, int> _userCounts = {};
  List<Map<String, dynamic>> _recentUsers = [];
  List<Map<String, dynamic>> _systemStats = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      setState(() => _isLoadingData = true);

      // Load user counts by role
      final userCountsResponse = await SupabaseService.instance
          .from('users')
          .select('role');

      final userCounts = <String, int>{};
      for (final user in userCountsResponse as List) {
        final role = user['role'] as String;
        userCounts[role] = (userCounts[role] ?? 0) + 1;
      }

      // Load recent users (last 10)
      final recentUsersResponse = await SupabaseService.instance
          .from('users')
          .select('id, first_name, last_name, email, role, created_at')
          .order('created_at', ascending: false)
          .limit(10);

      // Load appointment counts
      final appointmentCountsResponse = await SupabaseService.instance
          .from('appointments')
          .select('status');

      final appointmentCounts = <String, int>{};
      for (final appointment in appointmentCountsResponse as List) {
        final status = appointment['status'] as String;
        appointmentCounts[status] = (appointmentCounts[status] ?? 0) + 1;
      }

      setState(() {
        _userCounts = userCounts;
        _recentUsers = List<Map<String, dynamic>>.from(recentUsersResponse);
        _systemStats = [
          {
            'title': 'Total Users',
            'value': userCounts.values.fold(0, (a, b) => a + b),
            'icon': Icons.people,
            'color': AppColors.primary,
          },
          {
            'title': 'Total Appointments',
            'value': appointmentCounts.values.fold(0, (a, b) => a + b),
            'icon': Icons.calendar_today,
            'color': AppColors.cardAppointment,
          },
          {
            'title': 'Active Doctors',
            'value': userCounts['staff'] ?? 0,
            'icon': Icons.medical_services,
            'color': AppColors.success,
          },
          {
            'title': 'Patients',
            'value': userCounts['patient'] ?? 0,
            'icon': Icons.person,
            'color': AppColors.warning,
          },
        ];
        _isLoadingData = false;
      });

      print('✅ Admin data loaded successfully');
    } catch (e) {
      print('❌ Error loading admin data: $e');
      setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.admin,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.admin, AppColors.adminDark],
            ),
          ),
        ),
        title: Text(
          _index == 0
              ? 'System Overview'
              : _index == 1
              ? 'User Management'
              : _index == 2
              ? 'Analytics'
              : 'Admin Profile',
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            tooltip: 'Patient Home',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRouter.home),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          _SystemOverviewView(),
          _UserManagementView(),
          _AnalyticsView(),
          _AdminProfileView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _index,
        selectedItemColor: AppColors.admin,
        unselectedItemColor: AppColors.textTertiary,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _SystemOverviewView extends StatelessWidget {
  const _SystemOverviewView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        children: [
          // System Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppDimensions.spacingM,
            crossAxisSpacing: AppDimensions.spacingM,
            childAspectRatio: 1.2,
            children: [
              _SystemStatCard(
                title: 'Total Users',
                value: '1,247',
                icon: Icons.people,
                color: AppColors.primary,
                trend: '+12%',
                isPositive: true,
              ),
              _SystemStatCard(
                title: 'Active Sessions',
                value: '89',
                icon: Icons.computer,
                color: AppColors.success,
                trend: '+5%',
                isPositive: true,
              ),
              _SystemStatCard(
                title: 'Appointments Today',
                value: '156',
                icon: Icons.calendar_today,
                color: AppColors.warning,
                trend: '+18%',
                isPositive: true,
              ),
              _SystemStatCard(
                title: 'System Health',
                value: '99.8%',
                icon: Icons.health_and_safety,
                color: AppColors.success,
                trend: '+0.2%',
                isPositive: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Quick Actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.admin.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: AppColors.admin,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      'Admin Actions',
                      style: AppTypography.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: AppDimensions.spacingM,
                  crossAxisSpacing: AppDimensions.spacingM,
                  childAspectRatio: 1,
                  children: [
                    _AdminActionCard(
                      title: 'User\nManagement',
                      icon: Icons.people,
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.userManagement,
                      ),
                    ),
                    _AdminActionCard(
                      title: 'System\nReports',
                      icon: Icons.assessment,
                      color: AppColors.success,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.systemAnalytics,
                      ),
                    ),
                    _AdminActionCard(
                      title: 'Content\nManagement',
                      icon: Icons.article,
                      color: AppColors.warning,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.contentManagement,
                      ),
                    ),
                    _AdminActionCard(
                      title: 'Backup\nSystem',
                      icon: Icons.backup,
                      color: AppColors.info,
                      onTap: () {},
                    ),
                    _AdminActionCard(
                      title: 'Security\nLogs',
                      icon: Icons.security,
                      color: AppColors.error,
                      onTap: () {},
                    ),
                    _AdminActionCard(
                      title: 'System\nSettings',
                      icon: Icons.settings,
                      color: AppColors.textSecondary,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.settings),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Recent Activity
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      'Recent Activity',
                      style: AppTypography.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
                ...List.generate(
                  5,
                  (index) => _ActivityItem(
                    title: 'New user registration',
                    subtitle: 'john.doe@umat.edu.gh joined as Patient',
                    time: '${index + 1} min ago',
                    icon: Icons.person_add,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;

  const _SystemStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.error)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? AppColors.success : AppColors.error,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: AppTypography.caption.copyWith(
                        color: isPositive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            value,
            style: AppTypography.heading2.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserManagementView extends StatefulWidget {
  const _UserManagementView();

  @override
  State<_UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<_UserManagementView> {
  String _selectedFilter = 'All Users';

  @override
  Widget build(BuildContext context) {
    final users = [
      {
        'name': 'Dr. Emmanuel Mensah',
        'email': 'e.mensah@umat.edu.gh',
        'role': 'Staff',
        'status': 'Active',
        'avatar':
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'John Doe',
        'email': 'john.doe@umat.edu.gh',
        'role': 'Patient',
        'status': 'Active',
        'avatar':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Jane Smith',
        'email': 'jane.smith@umat.edu.gh',
        'role': 'Patient',
        'status': 'Inactive',
        'avatar':
            'https://images.unsplash.com/photo-1494790108755-2616b332b893?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Dr. Sarah Wilson',
        'email': 's.wilson@umat.edu.gh',
        'role': 'Staff',
        'status': 'Active',
        'avatar':
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Admin User',
        'email': 'admin@umat.edu.gh',
        'role': 'Admin',
        'status': 'Active',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search users by name or email',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                    tooltip: 'Add New User',
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _AdminFilterChip(
                      label: 'All Users',
                      isSelected: _selectedFilter == 'All Users',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'All Users'),
                    ),
                    const SizedBox(width: 8),
                    _AdminFilterChip(
                      label: 'Patients',
                      isSelected: _selectedFilter == 'Patients',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'Patients'),
                    ),
                    const SizedBox(width: 8),
                    _AdminFilterChip(
                      label: 'Staff',
                      isSelected: _selectedFilter == 'Staff',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'Staff'),
                    ),
                    const SizedBox(width: 8),
                    _AdminFilterChip(
                      label: 'Admins',
                      isSelected: _selectedFilter == 'Admins',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'Admins'),
                    ),
                    const SizedBox(width: 8),
                    _AdminFilterChip(
                      label: 'Active',
                      isSelected: _selectedFilter == 'Active',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'Active'),
                    ),
                    const SizedBox(width: 8),
                    _AdminFilterChip(
                      label: 'Inactive',
                      isSelected: _selectedFilter == 'Inactive',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'Inactive'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            itemCount: users.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.spacingS),
            itemBuilder: (_, i) => _UserCard(user: users[i]),
          ),
        ),
      ],
    );
  }
}

class _AdminFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _AdminFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(),
      selectedColor: AppColors.admin.withOpacity(0.2),
      checkmarkColor: AppColors.admin,
      backgroundColor: AppColors.surfaceLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.admin : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, String> user;

  const _UserCard({required this.user});

  Color get _roleColor {
    switch (user['role']) {
      case 'Admin':
        return AppColors.admin;
      case 'Staff':
        return AppColors.staff;
      default:
        return AppColors.patient;
    }
  }

  Color get _statusColor {
    return user['status'] == 'Active' ? AppColors.success : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              user['avatar']!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: _roleColor.withOpacity(0.1),
                child: Icon(Icons.person, color: _roleColor),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['name']!,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Text(
                        user['status']!,
                        style: AppTypography.caption.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user['email']!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Text(
                        user['role']!,
                        style: AppTypography.caption.copyWith(
                          color: _roleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit User')),
              const PopupMenuItem(
                value: 'disable',
                child: Text('Disable User'),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Delete User')),
            ],
            onSelected: (value) {
              // Handle menu actions
            },
          ),
        ],
      ),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        children: [
          // Analytics Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.admin, AppColors.adminDark],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Column(
              children: [
                const Icon(Icons.analytics, size: 48, color: Colors.white),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'System Analytics',
                  style: AppTypography.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Real-time insights and performance metrics',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Analytics Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppDimensions.spacingM,
            crossAxisSpacing: AppDimensions.spacingM,
            childAspectRatio: 1.1,
            children: [
              _AnalyticsCard(
                title: 'Daily Active Users',
                value: '892',
                subtitle: '+15% from yesterday',
                icon: Icons.people,
                color: AppColors.primary,
              ),
              _AnalyticsCard(
                title: 'Appointments',
                value: '234',
                subtitle: '+8% from last week',
                icon: Icons.event,
                color: AppColors.success,
              ),
              _AnalyticsCard(
                title: 'System Uptime',
                value: '99.9%',
                subtitle: 'Last 30 days',
                icon: Icons.computer,
                color: AppColors.info,
              ),
              _AnalyticsCard(
                title: 'Response Time',
                value: '142ms',
                subtitle: 'Average API response',
                icon: Icons.speed,
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Performance Chart Placeholder
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Performance Overview',
                  style: AppTypography.heading4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: const Center(child: Text('Chart Placeholder')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            value,
            style: AppTypography.heading2.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminProfileView extends StatelessWidget {
  const _AdminProfileView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.admin, AppColors.adminDark],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'System Administrator',
                  style: AppTypography.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Super Admin',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'admin@umat.edu.gh',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AdminProfileStat(label: 'Users', value: '1,247'),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _AdminProfileStat(label: 'Uptime', value: '99.9%'),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _AdminProfileStat(label: 'Experience', value: '5 yrs'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Admin Actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Actions',
                  style: AppTypography.heading4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _AdminProfileTile(
                  icon: Icons.security,
                  title: 'Security Settings',
                  subtitle: 'Manage system security',
                  onTap: () {},
                ),
                _AdminProfileTile(
                  icon: Icons.backup,
                  title: 'System Backup',
                  subtitle: 'Backup and restore data',
                  onTap: () {},
                ),
                _AdminProfileTile(
                  icon: Icons.update,
                  title: 'System Updates',
                  subtitle: 'Check for updates',
                  onTap: () {},
                ),
                _AdminProfileTile(
                  icon: Icons.support,
                  title: 'Support Center',
                  subtitle: 'Get technical support',
                  onTap: () {},
                ),
                _AdminProfileTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Logout from admin portal',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRouter.healthcareSignIn,
                  ),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _AdminProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _AdminProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _AdminProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.1)
              : AppColors.admin.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.admin,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? AppColors.error : AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}
