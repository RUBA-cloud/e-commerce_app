// lib/pages/address/cubit/address_cubit.dart
import 'dart:async';

import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/pages/address/cubit/address_state.dart';
import 'package:ecommerce_app/repostery%20/profile_repoiistery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

class AddressCubit extends Cubit<AddressState> {
  /// المستخدم الحالي (قد يكون null)
  final UserModel? currentUser = UserModel.currentUser;

  AddressCubit({List<CartModel>? initialCart})
      : _cartItems = initialCart ?? [],
        super(AddressState.initial()) {
    // عند إنشاء الكيوبت استخدم إحداثيات المستخدم إن وُجدت، وإلا عمّان
    final initialPoint = defaultLatLng;
    emit(
      state.copyWith(
        latitude: initialPoint.latitude,
        longitude: initialPoint.longitude,
      ),
    );

    _initLocation();
    _initTextAddress();
  }


  final formKey = GlobalKey<FormState>();

  final TextEditingController streetCtrl = TextEditingController();
  final TextEditingController buildingCtrl = TextEditingController();
  final TextEditingController fullAddressCtrl = TextEditingController();

  /// Cart items to convert into order
  List<CartModel> _cartItems;
  List<CartModel> get cartItems => _cartItems;

  /// Map controller for flutter_map
  final MapController mapController = MapController();

  /// إحداثيات عمّان الثابتة
  static const latlng.LatLng _ammanLatLng = latlng.LatLng(31.9539, 35.9106);

  /// الإحداثيات الافتراضية:
  /// - لو عند المستخدم إحداثيات محفوظة → نستخدمها
  /// - غير ذلك → عمّان
  latlng.LatLng get defaultLatLng {
    final u = currentUser;
    if (u != null &&
        u.latiude != null &&
        u.longtiude != null &&
        u.latiude != 0 &&
        u.longtiude != 0) {
      return latlng.LatLng(u.latiude!, u.longtiude!);
    }
    return _ammanLatLng;
  }

  /// Called when user taps map
  void onMapTapped(latlng.LatLng pos) {
    emit(
      state.copyWith(
        latitude: pos.latitude,
        longitude: pos.longitude,
        error: null,
      ),
    );
  }
  Future<void> _initTextAddress()async{
 fullAddressCtrl.text = currentUser!.address!;
 streetCtrl.text=UserModel.currentUser!.streetName!;
 buildingCtrl.text =currentUser!.buildingNumber!;

  }

  /// Called once when cubit is created
  Future<void> _initLocation() async {
    try {
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // خدمة الموقع مغلقة → استخدم الإحداثيات الافتراضية (مستخدم أو عمّان)
        final point = defaultLatLng;
        emit(
          state.copyWith(
            latitude: point.latitude,
            longitude: point.longitude,
          ),
        );
        mapController.move(point, 14);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        // رفض صلاحيات → استخدم الإحداثيات الافتراضية
        final point = defaultLatLng;
        emit(
          state.copyWith(
            latitude: point.latitude,
            longitude: point.longitude,
          ),
        );
        mapController.move(point, 14);
        return;
      }

      // تم السماح → استخدم موقع الجهاز
      final pos = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      final point = latlng.LatLng(pos.latitude, pos.longitude);

      // خزّن الإحداثيات في المستخدم (صحّحنا الـ lat/long)
      if (currentUser != null) {
        currentUser!.latiude = pos.latitude;
        currentUser!.longtiude = pos.longitude;
      }

      emit(
        state.copyWith(
          latitude: point.latitude,
          longitude: point.longitude,
        ),
      );

      // حرّك الخريطة إلى موقع المستخدم
      mapController.move(point, 16);
    } catch (e) {
      // أي خطأ → استخدم الإحداثيات الافتراضية
      final point = defaultLatLng;
      emit(
        state.copyWith(
          latitude: point.latitude,
          longitude: point.longitude,
          error: e.toString(),
        ),
      );
      mapController.move(point, 14);
    }
  }

  /// Called from the button (my location)
  Future<void> useCurrentLocation() async {
    try {
      emit(state.copyWith(error: null));

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // خدمة الموقع مغلقة → أظهر رسالة لكن ما زلنا نستخدم الإحداثيات الحالية أو الافتراضية
        final fallback = defaultLatLng;
        emit(
          state.copyWith(
            error: 'location_service_disabled'.tr,
            latitude: state.latitude ?? fallback.latitude,
            longitude: state.longitude ?? fallback.longitude,
          ),
        );

        mapController.move(
          latlng.LatLng(
            state.latitude ?? fallback.latitude,
            state.longitude ?? fallback.longitude,
          ),
          14,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        // رفض صلاحيات → استخدم الإحداثيات الحالية أو الافتراضية
        final fallback = defaultLatLng;
        emit(
          state.copyWith(
            error: 'location_permission_denied'.tr,
            latitude: state.latitude ?? fallback.latitude,
            longitude: state.longitude ?? fallback.longitude,
          ),
        );

        mapController.move(
          latlng.LatLng(
            state.latitude ?? fallback.latitude,
            state.longitude ?? fallback.longitude,
          ),
          14,
        );
        return;
      }

      // تم السماح → استخدم موقع الجهاز
      final pos = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      final point = latlng.LatLng(pos.latitude, pos.longitude);

      // خزّن الإحداثيات في المستخدم
      if (currentUser != null) {
        currentUser!.latiude = pos.latitude;
        currentUser!.longtiude = pos.longitude;
      }

      emit(
        state.copyWith(
          latitude: point.latitude,
          longitude: point.longitude,
        ),
      );

      mapController.move(point, 16);
    } catch (e) {
      // أي خطأ → استخدم آخر قيمة مخزّنة أو الافتراضية
      final fallback = defaultLatLng;
      final point = latlng.LatLng(
        state.latitude ?? fallback.latitude,
        state.longitude ?? fallback.longitude,
      );

      emit(
        state.copyWith(
          error: e.toString(),
          latitude: point.latitude,
          longitude: point.longitude,
        ),
      );

      mapController.move(point, 14);
    }
  }

  /// ضبط عناصر السلة من الخارج
  void setCartModel(List<CartModel> cart) {
    _cartItems = cart;
  }

  /// مجموع السلة
  double get cartTotal {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
  }

  Future<void> submit() async {
    final form = formKey.currentState;
    if (form == null) return;

    // لو الفورم غير صحيح → أوقف
    if (!form.validate()) {
      return;
    }

    if (state.latitude == null || state.longitude == null) {
      emit(state.copyWith(error: 'please_select_location_on_map'.tr));
      return;
    }

    if (_cartItems.isEmpty) {
      emit(state.copyWith(error: 'cart_is_empty'.tr));
      return;
    }

    emit(state.copyWith(loading: true, success: false, error: null));

    try {
      final double totalPrice = cartTotal;

      final double lat = state.latitude!;
      final double long = state.longitude!;
      final String address = fullAddressCtrl.text.trim();
      final String buildingNumber = buildingCtrl.text.trim();
      final String street = streetCtrl.text.trim();

      // حول السلة إلى OrderModel
      final OrderModel order = CartModel.fromCartListToOrder(
        cartItems,
        address,
        buildingNumber,
        street,
        totalPrice,
        lat,
        long,
      );

      // حفظ العنوان في البروفايل (اختياريًا تستخدم النتيجة)
      final profileRepo = ProfileRepository();
     if( await profileRepo.saveAddress(
        address: address,
        buildingNumber: buildingNumber,
        lat: UserModel.currentUser!.latiude!.toString(),
        long: UserModel.currentUser!.longtiude!.toString(),
        street: street,
      )){

      await Future.delayed(const Duration(milliseconds: 500));

      emit(state.copyWith(
        loading: false,
        success: true,
        error: null,
      ));

      // الانتقال لصفحة الطلبات مع تمرير الطلب
      Get.toNamed(AppRoutes.orders, arguments: order);
      }
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          success: false,
          error: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    streetCtrl.dispose();
    buildingCtrl.dispose();
    fullAddressCtrl.dispose();
    return super.close();
  }
}
