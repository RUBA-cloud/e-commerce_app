import 'package:ecommerce_app/components/basic_input.dart' show BasicInput;
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
          if (state.verifyEmail == false) {
            Get.toNamed(AppRoutes.verifyEmail);
          }
          if (state.success) {
            Get.offAllNamed(AppRoutes.home);
          }
        },
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();

          return SingleChildScrollView(
            child: Form(
              key: cubit.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email
                  labeledBasicInput(
                    context: context,
                    labelKey: 'email',
                    hintKey: 'enter_email',
                    controller: cubit.emailCtrl,
                    icon: Icons.email,
                    radius: 40,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'email_required'.tr;
                      final re =
                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!re.hasMatch(value)) {
                        return 'enter_valid_email'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  labeledBasicInput(
                    context: context,
                    labelKey: 'password',
                    hintKey: 'enter_password',
                    controller: cubit.passwordCtrl,
                    icon: Icons.lock,
                    radius: 40,
                    isPassword: true,
                    validator: (v) =>
                        (v == null || v.isEmpty)
                            ? 'password_is_required'.tr
                            : null,
                  ),
                  const SizedBox(height: 24),

                  // Button / loader
                  state.loading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
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

/// 🔹 دالة shared لليبل + BasicInput
Widget labeledBasicInput({
  required BuildContext context,
  required String labelKey, // 'email' / 'password' ...
  String? hintKey,          // 'enter_email' ...
  required TextEditingController controller,
  required IconData icon,
  bool isPassword = false,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  double radius = 30,
}) {
  final labelText = labelKey.tr;
  final hintText = (hintKey ?? labelKey).tr;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        labelText,
        style: AppTextStyles.caption(context),
      ),
      const SizedBox(height: 8),
      BasicInput(
        controller: controller,
        label: labelText,
        hintText: hintText,
        isPassword: isPassword,
        keyboardType: keyboardType,
        isBorder: true,
        radius: radius,
        prefixIcon: Icon(icon),
        onChanged: onChanged,
        validator: validator,
      ),
    ],
  );
}
