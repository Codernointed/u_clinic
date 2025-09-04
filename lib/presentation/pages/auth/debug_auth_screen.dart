import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'dart:developer' as developer;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';

class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'testpassword123');
  final _firstNameController = TextEditingController(text: 'Test');
  final _lastNameController = TextEditingController(text: 'User');
  final _studentIdController = TextEditingController(text: 'TEST123');
  final _departmentController = TextEditingController(text: 'Computer Science');

  String _logOutput = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logOutput +=
          '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
    developer.log(message, name: 'DebugAuth');
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _logOutput = '';
    });

    try {
      _addLog('🔗 Testing Supabase connection...');

      final client = Supabase.instance.client;

      // Test basic connection
      final response = await client.from('users').select('count').limit(1);
      _addLog('✅ Database connection successful');
      _addLog('📊 Response: $response');
    } catch (e) {
      _addLog('❌ Connection failed: $e');

      // Check for specific RLS recursion error
      if (e.toString().contains('infinite recursion detected in policy')) {
        _addLog('');
        _addLog('🔧 SOLUTION: RLS Policy Issue Detected');
        _addLog('This is a Row Level Security policy problem.');
        _addLog('');
        _addLog('To fix this:');
        _addLog('1. Go to Supabase Dashboard');
        _addLog('2. Navigate to SQL Editor');
        _addLog('3. Run the fix_rls_policies.sql script');
        _addLog('4. Or temporarily disable RLS for testing');
        _addLog('');
        _addLog('Quick fix (disable RLS):');
        _addLog('ALTER TABLE users DISABLE ROW LEVEL SECURITY;');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('🚀 Testing sign up...');

      final client = Supabase.instance.client;

      final authResponse = await client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        data: {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'student_id': _studentIdController.text,
          'department': _departmentController.text,
        },
      );

      _addLog('📧 Auth response: ${authResponse.user?.id ?? 'null'}');
      _addLog(
        '📧 Session: ${authResponse.session?.accessToken != null ? 'present' : 'null'}',
      );
      _addLog('📧 User metadata: ${authResponse.user?.userMetadata}');

      if (authResponse.user != null) {
        _addLog('✅ User created successfully: ${authResponse.user!.id}');

        // Try to create user profile
        try {
          final userData = {
            'id': authResponse.user!.id,
            'email': _emailController.text,
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'student_id': _studentIdController.text,
            'department': _departmentController.text,
            'role': 'patient',
            'is_active': true,
            'is_email_verified': false,
            'is_phone_verified': false,
            'two_factor_enabled': false,
            'presenting_symptoms': [],
            'medical_conditions': [],
            'allergies': [],
            'current_medications': [],
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };

          final insertResponse = await client.from('users').insert(userData);
          _addLog('✅ User profile created successfully');
          _addLog('📊 Insert response: $insertResponse');
        } catch (e) {
          _addLog('❌ Failed to create user profile: $e');
        }
      } else {
        _addLog('❌ User creation failed');
      }
    } catch (e) {
      _addLog('❌ Sign up error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('🔐 Testing sign in...');

      final client = Supabase.instance.client;

      final authResponse = await client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      _addLog('📧 Sign in response: ${authResponse.user?.id ?? 'null'}');
      _addLog(
        '📧 Session: ${authResponse.session?.accessToken != null ? 'present' : 'null'}',
      );

      if (authResponse.user != null) {
        _addLog('✅ Sign in successful: ${authResponse.user!.id}');

        // Try to get user profile
        try {
          final userData = await client
              .from('users')
              .select()
              .eq('id', authResponse.user!.id)
              .single();

          _addLog('✅ User profile retrieved: $userData');
        } catch (e) {
          _addLog('❌ Failed to get user profile: $e');
        }
      } else {
        _addLog('❌ Sign in failed');
      }
    } catch (e) {
      _addLog('❌ Sign in error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('🚪 Testing sign out...');

      final client = Supabase.instance.client;
      await client.auth.signOut();

      _addLog('✅ Sign out successful');
    } catch (e) {
      _addLog('❌ Sign out error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Debug Auth',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          children: [
            // Input fields
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            TextField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testConnection,
                    child: const Text('Test Connection'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testSignUp,
                    child: const Text('Test Sign Up'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testSignIn,
                    child: const Text('Test Sign In'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testSignOut,
                    child: const Text('Test Sign Out'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // Log output
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logOutput.isEmpty
                        ? 'Logs will appear here...'
                        : _logOutput,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




