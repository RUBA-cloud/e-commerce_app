// lib/views/cubit/login_cubit.dart
import 'package:ecommerce_app/models/city_model.dart';
import 'package:ecommerce_app/models/country_model.dart';
import 'package:ecommerce_app/repostery%20/profile_repoiistery.dart';
import 'package:ecommerce_app/services/auth_services.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/views/cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  // Controllers live in Cubit so the UI can be Stateless.
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> submit() async {
    // prevent double-submit
    if (state.loading == true) return;

    if (!(formKey.currentState?.validate() ?? false)) return;
if(await checkConnectivity()){
      
    try {
      emit(state.copyWith(loading: true, error: null, success: false));

      final email = emailCtrl.text.trim();
      final password = passwordCtrl.text; // don't trim password
      final resultCountryAndCity = await getCountryAndCity();

      final res = await AuthServices.I.login(email: email, password: password,country: resultCountryAndCity.country!,city:resultCountryAndCity.city!);
      // Accept 200 or 201 as success
      if (res.isOk && (res.statusCode == 200 || res.statusCode == 201)) {
        // Your AuthServices returns ApiResult<Map<String, dynamic>>
        // with user under res.data['data']
        final map = res.data ?? {};
        final user = (map['data'] as Map?)?.cast<String, dynamic>() ?? {};
        // CountryModel? countryModel = CountryModel.fromJson(user['country']);
       // CityModel? cityModel = CityModel.fromJson(user['city']);

        // persist lightweight profile (adjust keys if your API differs)
        final rawCountry = user['country'];
        final countryStr = rawCountry == null
            ? 'Jordan'
            : (rawCountry is String
                ? rawCountry
                : (rawCountry is Map
                    ? CountryModel.fromJson((rawCountry ).cast<String, dynamic>()).nameEn ?? 'Jordan'
                    : 'Jordan'));

        final rawCity = user['city'];
        final cityStr = rawCity == null
            ? 'Jordan'
            : (rawCity is String
                ? rawCity
                : (rawCity is Map
                    ? CityModel.fromJson((rawCity).cast<String, dynamic>()).nameEn ?? 'Jordan'
                    : 'Jordan'));

        await ProfileRepository().saveProfileData(
          id: user['id'],
          name: (user['name'] ?? ''),
          email: (user['email'] ?? ''),
          phone: user['phone'] ?? '',
          address: user['address'] ?? '', // fill if you have it
          street:user['street'] ?? '',
          accessToken: user['access_token'] ?? '',
          country: countryStr,
          city: cityStr,
        );

        emit(state.copyWith(loading: false, success: true,verifyEmail: true));
        return;
      }
      else{ 
        if(res.statusCode==403){

          emit(state.copyWith(
            loading: false,
            success: false,
            verifyEmail: false,
            error: 'account_not_verified'.tr,
          ));
        }
      }

      // Not OK -> surface server error or fallback
      emit(state.copyWith(
        loading: false,
        success: false,
        error: res.error ?? 'Login failed',
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, success: false, error: e.toString()));
    }}
    else{
      emit(state.copyWith(
        loading: false,
        success: false,
        error: 'no_internet_connection'.tr,
      ));
    }
  }

  // optional helper if you still need it
  void saveUser(Map<String, dynamic> result) {
    // result['data'] is typically the user map
    // print(result['data']);
  }

  @override
  Future<void> close() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    return super.close();
  }
}


class LocationResult {
  final String? country;
  final String? city;
  LocationResult({this.country, this.city});
}

Future<LocationResult> getCountryAndCity() async {
  // 1) تأكد من تفعيل خدمة الموقع
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled');
  }

  // 2) صلاحيات الموقع
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    throw Exception('Location permission denied');
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission denied forever');
  }

  // 3) احصل على الإحداثيات
  final pos = await Geolocator.getCurrentPosition(
    // ignore: deprecated_member_use
    desiredAccuracy: LocationAccuracy.high,
  );

  // 4) حوّلها إلى City/Country
  final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
  final p = placemarks.isNotEmpty ? placemarks.first : null;

  return LocationResult(
    country: p?.country,
    city: p?.locality ?? p?.administrativeArea, // locality = city غالباً
  );
}
