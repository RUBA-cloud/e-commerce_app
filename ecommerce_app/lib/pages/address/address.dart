import 'package:ecommerce_app/components/basic_input.dart';
import 'package:ecommerce_app/constants/text_styles.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/pages/address/cubit/address_cubit.dart';
import 'package:ecommerce_app/pages/address/cubit/address_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final List<CartModel> cartModel =
        (args is List<CartModel>) ? args : <CartModel>[];

    return BlocProvider(
      create: (_) => AddressCubit(initialCart: cartModel),
      child: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AddressCubit>();

          // لو ما في إحداثيات في الـ state استخدم عمّان كافتراضي
          final mapCenter = (state.latitude != null && state.longitude != null)
              ? latlng.LatLng(state.latitude!, state.longitude!)
              : const latlng.LatLng(31.9539, 35.9106);

          return Scaffold(
            appBar: AppBar(
              title: Text('address'.tr),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: cubit.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    /// Street Name
                    Text(
                      'street_name'.tr,
                      style: AppTextStyles.caption(context),
                    ),
                    const SizedBox(height: 8),
                    BasicInput(
                      controller: cubit.streetCtrl,
                      label: 'street_name'.tr,
                      hintText: 'street_name_hint'.tr,
                      isBorder: true,
                      radius: 40,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) {
                          return 'street_name_required'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Building Number
                    Text(
                      'building_number'.tr,
                      style: AppTextStyles.caption(context),
                    ),
                    const SizedBox(height: 8),
                    BasicInput(
                      controller: cubit.buildingCtrl,
                      label: 'building_number'.tr,
                      hintText: 'building_number'.tr,
                      keyboardType: TextInputType.number,
                      isBorder: true,
                      radius: 40,
                      prefixIcon: const Icon(Icons.apartment),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) {
                          return 'building_number_required'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Full Address / Details
                    Text(
                      'address_details'.tr,
                      style: AppTextStyles.caption(context),
                    ),
                    const SizedBox(height: 8),
                    BasicInput(
                      controller: cubit.fullAddressCtrl,
                      label: 'address_details'.tr,
                      hintText: 'address_details_hint'.tr,
                      maxLines: 3,
                      isBorder: true,
                      radius: 20,
                      prefixIcon: const Icon(Icons.home_outlined),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) {
                          return 'address_required'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'pick_address_on_map'.tr,
                      style: AppTextStyles.caption(context),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 260,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: cubit.mapController,
                              options: MapOptions(
                                initialCenter: mapCenter,
                                initialZoom: 14,
                                onTap: (tapPosition, point) {
                                  cubit.onMapTapped(point);
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.ecommerce_app',
                                ),
                                if (state.latitude != null &&
                                    state.longitude != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: latlng.LatLng(
                                          state.latitude!,
                                          state.longitude!,
                                        ),
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.bottomCenter,
                                        child: const Icon(
                                          Icons.location_pin,
                                          size: 40,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: FloatingActionButton.small(
                                heroTag: 'current_location_btn',
                                onPressed: () => cubit.useCurrentLocation(),
                                child: const Icon(Icons.my_location),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// Save button
                    state.loading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () => cubit.submit(),
                              child: Text(
                                'save'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
