import 'package:ecommerce_app/components/basic_input.dart' show BasicInput;
import 'package:ecommerce_app/constants/app_routes.dart';
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
          final cubit = context.read<RegisterCubit>();

          if (state.isSuccess) {
            Get.toNamed(
              AppRoutes.verifyEmail,
              arguments: cubit.emailCtrl.text,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('registered_successfully'.tr)),
            );
            cubit.reset();
          } else if (state.isEmailFound) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('email_already_exist'.tr)),
            );
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<RegisterCubit>();
          final scheme = Theme.of(context).colorScheme;

          // لما أي فيلد يتغير نرجّع الستيت عادي ونلغي الأخطاء
          void onAnyChanged(String _) => cubit.reset();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Form (scrollable) ----
              Expanded(
                child: Form(
                  key: cubit.formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 12),

                      // Full name
                      labeledBasicInput(
                        context: context,
                        labelKey: 'full_name',
                        hintKey: 'enter_full_name',
                        controller: cubit.nameCtrl,
                        icon: Icons.person,
                        onChanged: onAnyChanged,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'name_required'.tr
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Email
                      labeledBasicInput(
                        context: context,
                        labelKey: 'email',
                        hintKey: 'enter_email',
                        controller: cubit.emailCtrl,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: onAnyChanged,
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

                      if (state.isEmailFound) ...[
                        const SizedBox(height: 6),
                        Text(
                          'email_already_exist'.tr,
                          style: AppTextStyles.caption(context).copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Phone
                      labeledBasicInput(
                        context: context,
                        labelKey: 'phone',
                        hintKey: 'enter_phone',
                        controller: cubit.phoneCtrl,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        onChanged: onAnyChanged,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) {
                            return 'phone_number_is_required'.tr;
                          }
                          final re = RegExp(r'^\+?[0-9]{7,15}$');
                          if (!re.hasMatch(value)) {
                            return 'enter_valid_phone'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password
                      labeledBasicInput(
                        context: context,
                        labelKey: 'password',
                        hintKey: 'enter_password',
                        controller: cubit.passwordCtrl,
                        icon: Icons.lock,
                        isPassword: true,
                        onChanged: onAnyChanged,
                        validator: (v) =>
                            (v == null || v.isEmpty)
                                ? 'password_is_required'.tr
                                : null,
                      ),
                      const SizedBox(height: 12),

                      // Confirm password
                      labeledBasicInput(
                        context: context,
                        labelKey: 'renter_password',
                        hintKey: 'renter_password',
                        controller: cubit.renterPasswordCtrl,
                        icon: Icons.lock,
                        isPassword: true,
                        onChanged: onAnyChanged,
                        validator: (v) {
                          final value = (v ?? '');
                          if (value.isEmpty) {
                            return 'password_is_required'.tr;
                          }
                          if (value != cubit.passwordCtrl.text) {
                            return 'passwords_do_not_match'.tr;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ---- Submit button ----
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : () => cubit.submit(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'register'.tr,
                          style: AppTextStyles.button(context),
                        ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}

/// 🔹 دالة shared widget بدل StatelessWidget مستقل
Widget labeledBasicInput({
  required BuildContext context,
  required String labelKey, // 'full_name' / 'email'...
  String? hintKey,          // 'enter_full_name' ...
  required TextEditingController controller,
  required IconData icon,
  bool isPassword = false,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
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
      const SizedBox(height: 6),
      BasicInput(
        controller: controller,
        label: labelText,
        hintText: hintText,
        isPassword: isPassword,
        keyboardType: keyboardType,
        isBorder: true,
        radius: 30,
        prefixIcon: Icon(icon),
        onChanged: onChanged,
        validator: validator,
      ),
    ],
  );
}
