import 'package:easy_localization/easy_localization.dart';
import 'package:ecommerce_app/constant/app_theme.dart';
import 'package:ecommerce_app/data/model/response/carts/carts_entity.dart';
import 'package:ecommerce_app/presentation/cart/checkout_order/order_summary_screen.dart';
import 'package:ecommerce_app/services/cart/cart_cubit.dart';
import 'package:ecommerce_app/services/cart/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart' as latlng;

class AddressPage extends StatefulWidget {
  const AddressPage({super.key, this.cartItems = const []});

  final List<CartsDataEntity> cartItems;

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _fullAddressCtrl = TextEditingController();
  final _mapController = MapController();

  double? _lat;
  double? _lng;

  @override
  void dispose() {
    _streetCtrl.dispose();
    _buildingCtrl.dispose();
    _fullAddressCtrl.dispose();
    super.dispose();
  }

  void _onMapTapped(latlng.LatLng point) {
    setState(() {
      _lat = point.latitude;
      _lng = point.longitude;
    });
    _mapController.move(point, 14);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final primary = c.main;

    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        // Step 2 → push order summary screen
        if (state is CartGoToOrderSummary) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CartCubit>(),
                child: OrderSummaryScreen(state: state),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: c.textField,
        extendBody: true,
        body: SafeArea(
          child: Column(
            children: [
              _header(context, c),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldsCard(context, c, primary),
                        SizedBox(height: 18.h),
                        _sectionLabel(context, 'pick_address_on_map'.tr(), primary),
                        SizedBox(height: 10.h),
                        _mapCard(context, c, primary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _saveDock(context, c, primary),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _header(BuildContext context, AppColors c) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: c.card,
        border: Border(
            bottom:
            BorderSide(color: c.hint.withOpacity(0.12))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: c.textField,
                shape: BoxShape.circle,
                border: Border.all(color: c.hint.withOpacity(0.15)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16.r, color: c.icon),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.main, c.sub]),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.location_on_rounded,
                color: Colors.white, size: 24.r),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('address'.tr(),
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: c.bodyText)),
              Text('set_your_delivery_location'.tr(),
                  style: TextStyle(
                      fontSize: 12.sp, color: c.hint)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Fields card ───────────────────────────────────────────────────────────

  Widget _fieldsCard(
      BuildContext context, AppColors c, Color primary) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
              color: primary.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(context, 'street_name'.tr(), c),
          SizedBox(height: 8.h),
          _inputField(
            controller: _streetCtrl,
            hint: 'street_name_hint'.tr(),
            icon: Icons.signpost_outlined,
            primary: primary,
            c: c,
            validator: (v) =>
            (v ?? '').trim().isEmpty ? 'street_name_required'.tr() : null,
          ),
          SizedBox(height: 14.h),
          _fieldLabel(context, 'building_number'.tr(), c),
          SizedBox(height: 8.h),
          _inputField(
            controller: _buildingCtrl,
            hint: 'building_number'.tr(),
            icon: Icons.apartment_rounded,
            primary: primary,
            c: c,
            keyboardType: TextInputType.number,
            validator: (v) =>
            (v ?? '').trim().isEmpty ? 'building_number_required'.tr() : null,
          ),
          SizedBox(height: 14.h),
          _fieldLabel(context, 'address_details'.tr(), c),
          SizedBox(height: 8.h),
          _inputField(
            controller: _fullAddressCtrl,
            hint: 'address_details_hint'.tr(),
            icon: Icons.home_outlined,
            primary: primary,
            c: c,
            maxLines: 3,
            isRounded: false,
            validator: (v) =>
            (v ?? '').trim().isEmpty ? 'address_required'.tr() : null,
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color primary,
    required AppColors c,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRounded = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(fontSize: 14.sp, color: c.bodyText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.hint, fontSize: 13.sp),
        prefixIcon: Icon(icon, color: primary, size: 20.r),
        filled: true,
        fillColor: c.textField,
        contentPadding:
        EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(isRounded ? 40.r : 16.r),
          borderSide: BorderSide(color: c.hint.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(isRounded ? 40.r : 16.r),
          borderSide: BorderSide(color: c.hint.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(isRounded ? 40.r : 16.r),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  // ── Map card ──────────────────────────────────────────────────────────────

  Widget _mapCard(
      BuildContext context, AppColors c, Color primary) {
    final mapCenter = (_lat != null && _lng != null)
        ? latlng.LatLng(_lat!, _lng!)
        : const latlng.LatLng(31.9539, 35.9106);

    return Container(
      height: 240.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
              color: primary.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: 14,
                onTap: (_, point) => _onMapTapped(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ecommerce_app',
                ),
                if (_lat != null && _lng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: latlng.LatLng(_lat!, _lng!),
                        width: 40,
                        height: 40,
                        alignment: Alignment.bottomCenter,
                        child: Icon(Icons.location_pin,
                            size: 40.r, color: Colors.red.shade400),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              top: 12.h,
              right: 12.w,
              child: GestureDetector(
                onTap: () {
                  // TODO: use geolocator to get current location
                },
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: c.card,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.my_location_rounded,
                      size: 20.r, color: primary),
                ),
              ),
            ),
            Positioned(
              bottom: 12.h,
              left: 12.w,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: c.card.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: c.hint.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_rounded,
                        size: 13.r, color: primary),
                    SizedBox(width: 4.w),
                    Text('tap_to_pin'.tr(),
                        style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: c.hint)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Save dock ─────────────────────────────────────────────────────────────

  Widget _saveDock(BuildContext context, AppColors c, Color primary) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16.w, 12.h, 16.w, MediaQuery.paddingOf(context).bottom + 12.h),
      decoration: BoxDecoration(
        color: c.card,
        boxShadow: [
          BoxShadow(
              color: primary.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          if (!_formKey.currentState!.validate()) return;
          // ✅ Step 2: confirm address → emit CartGoToOrderSummary
          context.read<CartCubit>().confirmAddress(
            street: _streetCtrl.text.trim(),
            building: _buildingCtrl.text.trim(),
            fullAddress: _fullAddressCtrl.text.trim(),
            latitude: _lat,
            longitude: _lng,
          );
        },
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.main, c.sub]),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                  color: primary.withOpacity(0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 6)),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20.r),
              SizedBox(width: 8.w),
              Text('continue'.tr(),
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(
      BuildContext context, String text, Color primary) {
    final c = Theme.of(context).appColors;
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primary, c.sub]),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(text,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: c.bodyText)),
      ],
    );
  }

  Widget _fieldLabel(
      BuildContext context, String text, AppColors c) {
    return Text(text,
        style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: c.hint,
            letterSpacing: 0.3));
  }
}