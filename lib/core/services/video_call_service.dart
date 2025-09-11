import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallService {
  // For testing, you can use Agora's test app ID
  // In production, replace with your own Agora App ID
  static const String _appId = 'b7e4f320217c4878beff66da07be0877';
  static const String _token = ''; // Leave empty for testing

  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isJoined = false;
  int? _localUid;
  int? _remoteUid;
  String? _currentChannelId;

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
          onUserMuteVideo: (RtcConnection connection, int uid, bool muted) {
            print('🎥 onUserMuteVideo: channel=${connection.channelId} uid=$uid muted=$muted');
          },
          onRemoteVideoStateChanged: (RtcConnection connection, int uid, RemoteVideoState state,
              RemoteVideoStateReason reason, int elapsed) {
            print(
                '🎥 onRemoteVideoStateChanged: channel=${connection.channelId} uid=$uid state=$state reason=$reason elapsed=$elapsed');
          },
          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state,
              ConnectionChangedReasonType reason) {
            print(
                '🔌 Connection state changed: channel=${connection.channelId}, state=$state, reason=$reason');
            if (state == ConnectionStateType.connectionStateConnected && !_isJoined) {
              _isJoined = true;
              _localUid = connection.localUid;
              _isJoinedController.add(true);
              _localUidController.add(_localUid);
              print('✅ Marked joined from connection state change. Local UID: $_localUid');
            }
          },
          onError: (ErrorCodeType err, String msg) {
            print('🚨 Agora Error: $err - $msg');
          },
        ),
      );

      // Enable media and configure
      await _engine!.enableVideo();
      await _engine!.enableLocalVideo(true);
      await _engine!.enableAudio();
      await _engine!.setDefaultAudioRouteToSpeakerphone(true);
      await _engine!.setChannelProfile(
        ChannelProfileType.channelProfileCommunication,
      );
      await _engine!.setVideoEncoderConfiguration(const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 0,
        orientationMode: OrientationMode.orientationModeFixedPortrait,
      ));
      // Removed setDualStreamMode for SDK compatibility

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
      _currentChannelId = channelName;
      // Start local preview before join for better UX
      try {
        await _engine!.startPreview();
      } catch (_) {}
      // Ensure broadcaster role explicitly
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await _engine!.joinChannel(
        token: _token,
        channelId: channelName,
        uid: uid ?? 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );

      print('🔄 Joining channel: $channelName (uid=${uid ?? 0})');
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

    print('✅ onJoinChannelSuccess: channel=${connection.channelId}, localUid=${connection.localUid}, elapsed=$elapsed');
  }

  void _onUserJoined(RtcConnection connection, int remoteUid, int elapsed) {
    _remoteUid = remoteUid;
    _remoteUidController.add(_remoteUid);

    print('👤 onUserJoined: channel=${connection.channelId}, remoteUid=$remoteUid, elapsed=$elapsed');
    // Query remote video stats to ensure subscription
    _engine?.getUserInfoByUid(remoteUid).then((info) {
      print('ℹ️ Remote user info: uid=${info.uid}, userAccount=${info.userAccount}');
    }).catchError((e) {
      print('⚠️ getUserInfoByUid failed: $e');
    });
  }

  void _onUserOffline(
    RtcConnection connection,
    int remoteUid,
    UserOfflineReasonType reason,
  ) {
    _remoteUid = null;
    _remoteUidController.add(null);

    print('👤 onUserOffline: channel=${connection.channelId}, remoteUid=$remoteUid, reason=$reason');
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

    print('🖼️ Rendering remote view: channel=${_currentChannelId}, remoteUid=${_remoteUid}');
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(
          uid: _remoteUid,
          sourceType: VideoSourceType.videoSourceRemote,
        ),
        connection: RtcConnection(channelId: _currentChannelId ?? 'test_channel'),
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
