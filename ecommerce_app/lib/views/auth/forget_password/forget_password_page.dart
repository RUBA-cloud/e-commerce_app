import 'package:ecommerce_app/components/basic_input.dart';
import 'package:ecommerce_app/constants/text_styles.dart';
import 'package:ecommerce_app/views/auth/forget_password/cubit/forget_password_cubit.dart';
import 'package:ecommerce_app/views/auth/forget_password/cubit/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final scheme = Theme.of(context).colorScheme;
    final isAr =
        (Get.locale?.languageCode ?? Get.deviceLocale?.languageCode) == 'ar';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withOpacity(.06),
              scheme.secondary.withOpacity(.05),
              scheme.background,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              left: -40,
              child: _blurBall(scheme.primary.withOpacity(.18), 180),
            ),
            Positioned(
              bottom: -90,
              right: -50,
              child: _blurBall(scheme.secondary.withOpacity(.16), 220),
            ),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: scheme.surface.withOpacity(.94),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  shadowColor: scheme.primary.withOpacity(.15),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: scheme.primary.withOpacity(.08),
                      ),
                    ),
                    child: BlocProvider(
                      create: (_) => ForgetPasswordCubit(),
                      child:
                          BlocConsumer<
                            ForgetPasswordCubit,
                            ForgetPasswordState
                          >(
                            listener: (context, state) {
                              if (state is ForgetPasswordSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('reset_email_sent'.tr),
                                  ),
                                );
                              } else if (state is ForgetPasswordFailure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.error)),
                                );
                              }
                            },
                            builder: (context, state) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  26,
                                  24,
                                  24,
                                ),
                                child: Column(
                                  crossAxisAlignment: isAr
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Brand icon / header
                                    Row(
                                      mainAxisAlignment: isAr
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 56,
                                          width: 56,
                                          decoration: BoxDecoration(
                                            color: scheme.primary.withOpacity(
                                              .12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.lock_reset_rounded,
                                            size: 28,
                                            color: scheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'forget_password'.tr,
                                      style: AppTextStyles.headline(context),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'enter_email_to_reset'.tr,
                                      style: AppTextStyles.bodyMuted(context),
                                    ),
                                    const SizedBox(height: 20),

                                    // Email input
                                    BasicInput(
                                      controller: emailController,
                                      label: 'email'.tr,
                                      hintText: 'enter_email_to_reset'.tr,
                                      keyboardType: TextInputType.emailAddress,
                                      isBorder: true,
                                      radius: 30,
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                      validator: (v) {
                                        final value = (v ?? '').trim();
                                        if (value.isEmpty)
                                          return 'email_required'.tr;
                                        final re = RegExp(
                                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                        );
                                        if (!re.hasMatch(value))
                                          return 'invalid_email'.tr;
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    // Submit
                                    state is ForgetPasswordLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.send_rounded,
                                              ),
                                              label: Text(
                                                'send_reset_link'.tr,
                                                style: AppTextStyles.button(
                                                  context,
                                                ),
                                              ),
                                              onPressed: () {
                                                BlocProvider.of<
                                                      ForgetPasswordCubit
                                                    >(context)
                                                    .sendResetEmail(
                                                      emailController.text,
                                                    );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: scheme.primary,
                                                foregroundColor:
                                                    scheme.onPrimary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                      horizontal: 20,
                                                    ),
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                            ),
                                          ),

                                    const SizedBox(height: 14),

                                    // Helper / back to login
                                    Row(
                                      mainAxisAlignment: isAr
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.arrow_back_rounded,
                                            size: 18,
                                          ),
                                          label: Text(
                                            'login'.tr,
                                            style: AppTextStyles.link(context),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).maybePop(),
                                          style: TextButton.styleFrom(
                                            foregroundColor: scheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurBall(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 24)],
      ),
    );
  }
}
