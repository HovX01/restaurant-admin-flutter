import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../../core/config/api_config.dart';
import '../../core/storage/secure_storage_manager.dart';
import '../../core/utils/logger.dart';

/// WebSocket service for real-time updates
/// Following the WebSocket integration guide at docs/api/WebSocket-Integration.md
/// Uses STOMP protocol over SockJS
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  StompClient? _stompClient;
  final _storage = SecureStorageManager();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Stream controllers for different topics
  final _notificationsController = StreamController<Map<String, dynamic>>.broadcast();
  final _kitchenController = StreamController<Map<String, dynamic>>.broadcast();
  final _deliveryController = StreamController<Map<String, dynamic>>.broadcast();
  final _systemController = StreamController<Map<String, dynamic>>.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get notificationsStream =>
      _notificationsController.stream;
  Stream<Map<String, dynamic>> get kitchenStream => _kitchenController.stream;
  Stream<Map<String, dynamic>> get deliveryStream => _deliveryController.stream;
  Stream<Map<String, dynamic>> get systemStream => _systemController.stream;

  /// Connect to WebSocket server
  /// Should be called after successful login
  Future<void> connect() async {
    if (_isConnected) {
      AppLogger.warning('WebSocket already connected');
      return;
    }

    try {
      final token = await _storage.getToken();
      if (token == null) {
        AppLogger.error('No auth token available for WebSocket connection');
        return;
      }

      AppLogger.info('Connecting to WebSocket: ${ApiConfig.wsUrl}');

      _stompClient = StompClient(
        config: StompConfig(
          url: '${ApiConfig.wsUrl}/websocket',
          onConnect: _onConnect,
          onWebSocketError: (error) => _onError(error.toString()),
          onStompError: (frame) => _onStompError(frame),
          onDisconnect: _onDisconnect,
          beforeConnect: () async {
            AppLogger.debug('WebSocket connecting...');
          },
          stompConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          // Reconnection strategy
          reconnectDelay: const Duration(seconds: 5),
          heartbeatIncoming: const Duration(seconds: 20),
          heartbeatOutgoing: const Duration(seconds: 20),
        ),
      );

      _stompClient!.activate();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to connect WebSocket', e, stackTrace);
    }
  }

  /// Called when WebSocket connection is established
  void _onConnect(StompFrame frame) {
    _isConnected = true;
    AppLogger.info('WebSocket connected successfully');

    // Subscribe to default notification topic
    _subscribeToTopic(
      ApiConfig.wsTopicNotifications,
      _notificationsController,
    );
  }

  /// Called when WebSocket encounters an error
  void _onError(String error) {
    AppLogger.error('WebSocket error: $error');
  }

  /// Called when STOMP error occurs
  void _onStompError(StompFrame frame) {
    AppLogger.error('STOMP error: ${frame.body}');
  }

  /// Called when WebSocket disconnects
  void _onDisconnect(StompFrame frame) {
    _isConnected = false;
    AppLogger.warning('WebSocket disconnected');
  }

  /// Subscribe to a specific topic
  void _subscribeToTopic(
    String topic,
    StreamController<Map<String, dynamic>> controller,
  ) {
    if (!_isConnected || _stompClient == null) {
      AppLogger.warning('Cannot subscribe - not connected');
      return;
    }

    AppLogger.info('Subscribing to topic: $topic');

    _stompClient!.subscribe(
      destination: topic,
      callback: (frame) {
        if (frame.body != null) {
          try {
            final data = json.decode(frame.body!);
            if (data is Map<String, dynamic>) {
              AppLogger.debug('Received message on $topic: $data');
              controller.add(data);
            }
          } catch (e, stackTrace) {
            AppLogger.error('Failed to parse WebSocket message', e, stackTrace);
          }
        }
      },
    );
  }

  /// Subscribe to kitchen topic (for KITCHEN_STAFF role)
  void subscribeToKitchen() {
    _subscribeToTopic(ApiConfig.wsTopicKitchen, _kitchenController);
  }

  /// Subscribe to delivery staff topic (for DELIVERY_STAFF role)
  void subscribeToDeliveryStaff() {
    _subscribeToTopic(ApiConfig.wsTopicDeliveryStaff, _deliveryController);
  }

  /// Subscribe to system topic (for ADMIN role)
  void subscribeToSystem() {
    _subscribeToTopic(ApiConfig.wsTopicSystem, _systemController);
  }

  /// Send a message to a destination
  void send({
    required String destination,
    required Map<String, dynamic> body,
  }) {
    if (!_isConnected || _stompClient == null) {
      AppLogger.warning('Cannot send message - not connected');
      return;
    }

    try {
      _stompClient!.send(
        destination: destination,
        body: json.encode(body),
      );
      AppLogger.debug('Message sent to $destination: $body');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send message', e, stackTrace);
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    if (_stompClient != null) {
      AppLogger.info('Disconnecting WebSocket');
      _stompClient!.deactivate();
      _stompClient = null;
      _isConnected = false;
    }
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _notificationsController.close();
    _kitchenController.close();
    _deliveryController.close();
    _systemController.close();
  }
}
