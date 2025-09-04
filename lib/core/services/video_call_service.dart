import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallService {
  // For testing, you can use Agora's test app ID
  // In production, replace with your own Agora App ID
  static const String _appId = 'aab8b8f5a8cd4469a9d9baecd7f3a4b9';
  static const String _token = ''; // Leave empty for testing

  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isJoined = false;
  int? _localUid;
  int? _remoteUid;

  // Stream controllers for UI updates
  final StreamController<bool> _isJoinedController =
      StreamController<bool>.broadcast();
  final StreamController<int?> _localUidController =
      StreamController<int?>.broadcast();
  final StreamController<int?> _remoteUidController =
      StreamController<int?>.broadcast();

  // Streams for UI
  Stream<bool> get isJoinedStream => _isJoinedController.stream;
  Stream<int?> get localUidStream => _localUidController.stream;
  Stream<int?> get remoteUidStream => _remoteUidController.stream;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isJoined => _isJoined;
  int? get localUid => _localUid;
  int? get remoteUid => _remoteUid;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await [Permission.microphone, Permission.camera].request();

      // Create RTC engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(appId: _appId));

      // Set event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: _onJoinChannelSuccess,
          onUserJoined: _onUserJoined,
          onUserOffline: _onUserOffline,
        ),
      );

      // Enable video
      await _engine!.enableVideo();
      await _engine!.setChannelProfile(
        ChannelProfileType.channelProfileCommunication,
      );

      _isInitialized = true;
      print('✅ Agora RTC Engine initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Agora RTC Engine: $e');
      rethrow;
    }
  }

  Future<void> joinChannel(String channelName, {int? uid}) async {
    if (!_isInitialized || _isJoined) return;

    try {
      await _engine!.joinChannel(
        token: _token,
        channelId: channelName,
        uid: uid ?? 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      print('🔄 Joining channel: $channelName');
    } catch (e) {
      print('❌ Failed to join channel: $e');
      rethrow;
    }
  }

  Future<void> leaveChannel() async {
    if (!_isInitialized || !_isJoined) return;

    try {
      await _engine!.leaveChannel();
      _isJoined = false;
      _localUid = null;
      _remoteUid = null;

      _isJoinedController.add(false);
      _localUidController.add(null);
      _remoteUidController.add(null);

      print('👋 Left channel');
    } catch (e) {
      print('❌ Failed to leave channel: $e');
    }
  }

  Future<void> enableLocalVideo(bool enabled) async {
    if (!_isInitialized) return;

    try {
      await _engine!.enableLocalVideo(enabled);
      print('📹 Local video ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('❌ Failed to toggle local video: $e');
    }
  }

  Future<void> enableLocalAudio(bool enabled) async {
    if (!_isInitialized) return;

    try {
      await _engine!.enableLocalAudio(enabled);
      print('🎤 Local audio ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('❌ Failed to toggle local audio: $e');
    }
  }

  Future<void> switchCamera() async {
    if (!_isInitialized) return;

    try {
      await _engine!.switchCamera();
      print('📷 Camera switched');
    } catch (e) {
      print('❌ Failed to switch camera: $e');
    }
  }

  // Event handlers
  void _onJoinChannelSuccess(RtcConnection connection, int elapsed) {
    _isJoined = true;
    _localUid = connection.localUid;

    _isJoinedController.add(true);
    _localUidController.add(_localUid);

    print('✅ Joined channel successfully. Local UID: $_localUid');
  }

  void _onUserJoined(RtcConnection connection, int remoteUid, int elapsed) {
    _remoteUid = remoteUid;
    _remoteUidController.add(_remoteUid);

    print('👤 Remote user joined. UID: $remoteUid');
  }

  void _onUserOffline(
    RtcConnection connection,
    int remoteUid,
    UserOfflineReasonType reason,
  ) {
    _remoteUid = null;
    _remoteUidController.add(null);

    print('👤 Remote user left. UID: $remoteUid, Reason: $reason');
  }

  // UI helpers
  Widget createLocalView() {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text('Initializing...', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(
          uid: 0,
          sourceType: VideoSourceType.videoSourceCamera,
        ),
      ),
    );
  }

  Widget createRemoteView() {
    if (!_isInitialized || _remoteUid == null) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Text(
            'Waiting for remote user...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(
          uid: _remoteUid,
          sourceType: VideoSourceType.videoSourceRemote,
        ),
        connection: RtcConnection(channelId: 'test_channel'),
      ),
    );
  }

  void dispose() {
    leaveChannel();
    _engine?.release();
    _isJoinedController.close();
    _localUidController.close();
    _remoteUidController.close();
  }
}

// Singleton instance
final VideoCallService videoCallService = VideoCallService();
