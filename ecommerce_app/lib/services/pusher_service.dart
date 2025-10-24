// lib/services/pusher_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/about_us.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:http/http.dart' as http;

class PusherService {
  // ------------------ Singleton ------------------
  PusherService._();
  static final PusherService _instance = PusherService._();
  factory PusherService() => _instance;

  // ------------------ Fields ------------------
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  final _controller = StreamController<AboutUsInfoModel>.broadcast();
  Stream<AboutUsInfoModel> get stream => _controller.stream;

  bool _connected = false;
  bool _initialized = false;
  bool _companyInfoSubscribed = false;
  String? _baseUrl;

  AboutUsInfoModel? _lastCompanyInfo;

  // ------------------ Init / Connect ------------------
  /// Call once on app start (after token may be available).
  Future<void> init({
    String? baseUrl, // e.g. basicRoute
  }) async {
    if (_initialized) return;

    _baseUrl = baseUrl ?? basicRoute;

    if (kDebugMode) Fluttertoast.showToast(msg: "Initializing Pusher…");

    await _pusher.init(
      apiKey: "b6ecb13acb55900e518a", cluster: "api2",
      // IMPORTANT: use 'ap2' (not 'api2')
      // We'll do manual auth inside onAuthorizer:
      // (so don't set authEndpoint here)
      onAuthorizer:
          (String channelName, String socketId, dynamic options) async {
        final token = UserModel.currentUser?.accessToken;

        final res = await http.post(
          Uri.parse('$_baseUrl/broadcasting/auth'),
          headers: {
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: {
            'channel_name': channelName,
            'socket_id': socketId,
          },
        );

        if (res.statusCode < 200 || res.statusCode >= 300) {
          if (kDebugMode) {
            print('Pusher auth failed: ${res.statusCode} ${res.body}');
          }
          throw Exception('Pusher auth failed ${res.statusCode}');
        }

        // Must return decoded JSON containing 'auth' (and optionally 'channel_data')
        return jsonDecode(res.body) as Map<String, dynamic>;
      },
      onConnectionStateChange: (current, previous) {
        if (kDebugMode) print('Pusher state: $previous -> $current');
        return current;
      },
      onError: (message, code, exception) {
        if (kDebugMode) print('Pusher error: $message ($code) $exception');
      },
      onEvent: (PusherEvent event) {
        if (kDebugMode) {
          print('Event: ${event.eventName} on ${event.channelName}');
        }
      },
    );

    await _pusher.connect();
    _connected = true;
    _initialized = true;
  }

  void _ensureReady() async {
    if (!_initialized || !_connected) {
      throw StateError(
          'Call PusherService().init(...) before using the service.');
    }
  }

  // ------------------ Subscribe ------------------
  /// Subscribe to company info changes. Safe to call multiple times.
  Future<AboutUsInfoModel?> subscribeCompanyInfo() async {
    if (_companyInfoSubscribed) return _lastCompanyInfo;
    if (_connected) {
      const channel =
          'private-company_info'; // must match Laravel PrivateChannel('company_info')
      await _pusher.subscribe(
        channelName: channel,
        onEvent: (PusherEvent event) {
          print("eejej");
          if (event.eventName == 'company_info_updated') {
            try {
              final raw = event.data ?? '{}';
              final data = jsonDecode(raw);

              // Accept common Laravel shapes: {company:{...}} or {data:{...}} or {...}
              final map = (data is Map)
                  ? Map<String, dynamic>.from(data)
                  : <String, dynamic>{};
              final payload = (map['company'] ?? map['company'] ?? map)
                  as Map<String, dynamic>;

              final model = AboutUsInfoModel.fromJson(payload);
              _lastCompanyInfo = model;
              _controller.add(model);

              if (kDebugMode) print('Parsed company info OK');
            } catch (e) {
              if (kDebugMode) print('Failed to parse company_info_updated: $e');
            }
          }
        },
        onSubscriptionSucceeded: (String channelName, dynamic data) {
          if (kDebugMode) print('Subscribed: $channelName');
          Fluttertoast.showToast(msg: 'Subscribed: $channelName');
          return data;
        },
        onSubscriptionError: (String message, dynamic e) {
          if (kDebugMode) print('Subscription error: $message $e');
          Fluttertoast.showToast(msg: 'Subscription error: $message');
          return message;
        },
      );

      _companyInfoSubscribed = true;
      return _lastCompanyInfo;
    }
    return null;
  }

  /// Await one update.
  Future<AboutUsInfoModel?> nextCompanyInfo({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    await init();
    _ensureReady();
    await subscribeCompanyInfo();
    return stream.first.timeout(
      timeout,
      onTimeout: () => throw TimeoutException(
        'No company_info_updated within ${timeout.inSeconds}s',
      ),
    );
    // no re-init here!
  }

  // ------------------ Teardown ------------------
  Future<void> dispose() async {
    try {
      if (_companyInfoSubscribed) {
        await _pusher.unsubscribe(channelName: 'private-company_info');
      }
      await _pusher.disconnect();
      await _controller.close();
    } finally {
      _companyInfoSubscribed = false;
      _connected = false;
      _initialized = false;
    }
  }
}
