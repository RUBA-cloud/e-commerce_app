

// ignore_for_file: deprecated_member_use


import 'package:dio/dio.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/repostery%20/profile_repoiistery.dart';
import 'package:ecommerce_app/services/auth_services.dart';

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

   Future<Response<dynamic>> refreshToken( String path, {
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var refreshResponse = await AuthServices.I.refreshToken();
      if (refreshResponse.isOk) {
        final map = refreshResponse.data ?? {};
        UserModel.currentUser!.accessToken =
            (map['access_token'] ?? '').toString();
        ProfileRepository().saveAccessToken(UserModel.currentUser!.accessToken!);
        // retry original request
        final retryResponse = await Dio().post(
          path,
          queryParameters: query,
          data: data,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
        return retryResponse;
      } else {
        throw Exception('Refresh token failed');
      }
    } catch (ex) {
      // propagate the error so the caller can handle it
      rethrow;
    }
  }
  Options get authOptions {
    final token = UserModel.currentUser?.accessToken;
    return Options(
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );}

Future<bool> checkConnectivity({String probeUrl = 'http://www.google.com'}) async {
  // For web, we rely on the browser's navigator.onLine property
  // if (kIsWeb) {
  //   return html.window.navigator.onLine;
  // } 

  // For mobile and desktop, we use the connectivity_plus package
  var connectivityResult = await (Connectivity().checkConnectivity());
  // ignore: unrelated_type_equality_checks
  if (connectivityResult .contains(ConnectivityResult.wifi) ||
      // ignore: unrelated_type_equality_checks
      connectivityResult .contains(ConnectivityResult.mobile) ||
      // ignore: unrelated_type_equality_checks
      connectivityResult .contains(ConnectivityResult.ethernet)) {
    return true;
  }   else {
    return false;   
    }}