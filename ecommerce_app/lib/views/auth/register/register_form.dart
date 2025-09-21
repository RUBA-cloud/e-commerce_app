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
          final scheme = Theme.of(context).colorScheme;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Form (NOT scrollable) ----
              Expanded(
                child: Form(
                  key: cubit.formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ListView(
                    children: [
                      const SizedBox(height: 12),

                      // Full name
                      Text(
                        'full_name'.tr,
                        style: AppTextStyles.caption(context),
                      ),
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 12),

                      // Email
                      Text('email'.tr, style: AppTextStyles.caption(context)),
                      const SizedBox(height: 6),
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
                          if (!re.hasMatch(value)) {
                            return 'enter_valid_email'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Phone
                      Text('phone'.tr, style: AppTextStyles.caption(context)),
                      const SizedBox(height: 6),
                      BasicInput(
                        controller: cubit.phoneCtrl,
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
                          if (!re.hasMatch(value)) {
                            return 'enter_valid_phone'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password
                      Text(
                        'password'.tr,
                        style: AppTextStyles.caption(context),
                      ),
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 12),

                      // Confirm password
                      Text(
                        'renter_password'.tr,
                        style: AppTextStyles.caption(context),
                      ),
                      const SizedBox(height: 6),
                      BasicInput(
                        controller: cubit.renterPasswordCtrl,
                        label: 'renter_password'.tr,
                        hintText: 'renter_password'.tr,
                        isPassword: true,
                        isBorder: true,
                        radius: 30,
                        prefixIcon: const Icon(Icons.lock),
                        validator: (v) {
                          final value = (v ?? '');
                          if (value.isEmpty) return 'password_required'.tr;
                          if (value != cubit.passwordCtrl.text) {
                            return 'passwords_do_not_match'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      const Spacer(),
                    ],
                  ),
                ),
              ),

              // ---- Submit button (single) ----
              state.loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => cubit.submit(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
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
