import 'package:ecommerce_app/components/basic_input.dart' show BasicInput;
import 'package:ecommerce_app/constants/text_styles.dart';
import 'package:ecommerce_app/views/auth/register/cubit/register_cubit.dart';
import 'package:ecommerce_app/views/auth/register/cubit/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('registered_successfully'.tr)),
            );
          } else if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<RegisterCubit>();

          return SingleChildScrollView(
            child: Form(
              key: cubit.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "full_name".tr,
                    style: AppTextStyles.caption(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  // Full name
                  BasicInput(
                    controller: cubit.nameCtrl,
                    label: 'full_name'.tr,
                    hintText: 'enter_full_name'.tr,
                    isBorder: true,
                    radius: 30,
                    prefixIcon: const Icon(Icons.person),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'name_required'.tr
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  Text(
                    "email".tr,
                    style: AppTextStyles.caption(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  BasicInput(
                    controller: cubit.emailCtrl,
                    label: 'email'.tr,
                    hintText: 'enter_email'.tr,
                    keyboardType: TextInputType.emailAddress,
                    isBorder: true,
                    radius: 30,
                    prefixIcon: const Icon(Icons.email),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'email_required'.tr;
                      final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!re.hasMatch(value)) return 'enter_valid_email'.tr;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "phone".tr,
                    style: AppTextStyles.caption(context),

                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  BasicInput(
                    controller: cubit.emailCtrl,
                    label: 'phone'.tr,
                    hintText: 'enter_phone'.tr,
                    keyboardType: TextInputType.phone,
                    isBorder: true,
                    radius: 30,
                    prefixIcon: const Icon(Icons.phone),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'phone_required'.tr;
                      final re = RegExp(r'^\+?[0-9]{7,15}$');
                      if (!re.hasMatch(value)) return 'enter_valid_phone'.tr;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "password".tr,
                    style: AppTextStyles.caption(context),
                    textAlign: TextAlign.center,
                  ),
                  // Password
                  BasicInput(
                    controller: cubit.passwordCtrl,
                    label: 'password'.tr,
                    hintText: 'enter_password'.tr,
                    isPassword: true,
                    isBorder: true,
                    radius: 30,
                    prefixIcon: const Icon(Icons.lock),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'password_required'.tr
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "renter_password".tr,
                    style: AppTextStyles.caption(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  BasicInput(
                    controller: cubit.passwordCtrl,
                    label: 'renter_password'.tr,
                    hintText: 'renter_password'.tr,
                    isPassword: true,
                    isBorder: true,
                    radius: 30,
                    prefixIcon: const Icon(Icons.lock),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'password_required'.tr
                        : null,
                  ),
                  const SizedBox(height: 24),

                  state.loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => cubit.submit(),
                            child: Text('sign_up'.tr),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
