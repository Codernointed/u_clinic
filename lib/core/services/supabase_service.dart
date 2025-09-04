import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../constants/supabase_constants.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  late final SupabaseClient _client;

  // Getters
  SupabaseClient get client => _client;
  GoTrueClient get auth => _client.auth;

  /// Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    required Map<String, dynamic> userData,
  }) async {
    return await _client.auth.updateUser(UserAttributes(data: userData));
  }

  /// Database operations - using direct client access
  PostgrestQueryBuilder<dynamic> from(String table) {
    return _client.from(table);
  }

  /// Storage operations - using direct client access
  StorageFileApi storageFrom(String bucket) {
    return _client.storage.from(bucket);
  }

  /// Real-time subscriptions - using direct client access
  RealtimeChannel channel(String channelName) {
    return _client.channel(channelName);
  }

  /// Upload file to storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final response = await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    if (response.isEmpty) {
      throw Exception('Failed to upload file');
    }

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Download file from storage
  Future<Uint8List> downloadFile({
    required String bucket,
    required String path,
  }) async {
    return await _client.storage.from(bucket).download(path);
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }

  /// Get public URL for file
  String getPublicUrl({required String bucket, required String path}) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
