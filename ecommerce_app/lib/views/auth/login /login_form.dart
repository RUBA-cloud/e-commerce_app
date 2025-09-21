import 'package:ecommerce_app/components/basic_input.dart';
import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/constants/text_styles.dart';
import 'package:ecommerce_app/views/cubit/login_cubit.dart';
import 'package:ecommerce_app/views/cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// LOGIN (STATELESS WIDGET)
/// ---------------------------
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.success) {
            Get.toNamed(AppRoutes.home);
            // Navigator.pushReplacementNamed(context, '/home');
          } else if (state.error != null) {}
        },
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();

          return SingleChildScrollView(
            child: Form(
              key: cubit.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
                    radius: 40,
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

                  // Password
                  Text(
                    "password".tr,
                    style: AppTextStyles.caption(context),

                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  BasicInput(
                    controller: cubit.passwordCtrl,
                    label: 'password'.tr,
                    hintText: 'enter_password'.tr,
                    isPassword: true,
                    isBorder: true,
                    radius: 40,
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor, // main color
                              foregroundColor: Colors.white, // text color
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // rounded corners
                              ),
                              elevation: 4, // slight shadow
                            ),
                            onPressed: () => cubit.submit(),
                            child: Text(
                              'login'.tr,
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
          );
        },
      ),
    );
  }
}
