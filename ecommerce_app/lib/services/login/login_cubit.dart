import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/login_request.dart';
import 'package:ecommerce_app/data/model/response/login_entity.dart';
import 'package:ecommerce_app/domain/usecases/login_use_case.dart';
import 'package:ecommerce_app/services/login/login_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  static LoginCubit get(BuildContext context) => BlocProvider.of(context);

  String country = 'Jordan';
  String city    = 'Amman';

  // FIX: field initializer can't call getIt before super() — move to constructor
  final  _loginUseCase = getIt<LoginUseCase>();

    // ✅

  // ── Get country & city from GPS ──────────────────────────────────────────
  Future<void> getCountryAndCity() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return;
      final place = placemarks.first;

      if ((place.country ?? '').isNotEmpty) country = place.country!;
      if ((place.locality ?? place.administrativeArea ?? '').isNotEmpty) {
        city = place.locality ?? place.administrativeArea ?? city;
      }
    } catch (_) {
      // Non-fatal — login still works with fallback values
    }
  }

  // ── Submit ───────────────────────────────────────────────────────────────
  Future<void> submit({required LoginRequest loginRequest}) async {
    if (state is LoginLoading) return;
    emit(LoginLoading());

    try {


      final result = await _loginUseCase.execute(loginRequest);

      switch (result) {
        case Success<LoginEntity>():
          emit(LoginSuccess());

        case Failure():
          final code = result.statusCode;
          if (code == 403) {
            emit(LoginUnverified());
          } else {
            emit(LoginFailed(result.error ?? 'unknown_error'));
          }
      }
    } catch (e) {
      emit(LoginFailed(e.toString()));
    }
  }
}