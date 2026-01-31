import 'dart:ui';
import 'package:ecommerce_app/components/basic_form.dart';
import 'package:ecommerce_app/components/basic_input.dart';
import 'package:ecommerce_app/constants/app_routes.dart';
import 'package:ecommerce_app/constants/text_styles.dart';
import 'package:ecommerce_app/views/auth/forget_password/cubit/forget_password_cubit.dart';
import 'package:ecommerce_app/views/auth/forget_password/cubit/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: scheme.onPrimaryContainer,
        ),
        body: BasicFormWidget(
          form: formWidget(scheme),
        ));
  }

  Widget formWidget(var scheme) {
    final emailController = TextEditingController();
    final isAr =
        (Get.locale?.languageCode ?? Get.deviceLocale?.languageCode) == 'ar';

    final formKey = GlobalKey<FormState>();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Card(
                elevation: 8,
                margin: EdgeInsets.zero,
                color: scheme.surface.withOpacity(.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: scheme.outlineVariant.withOpacity(.25),
                  ),
                ),
                child: BlocProvider(
                  create: (_) => ForgetPasswordCubit(),
                  child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
                    listener: (context, state) {
                      if (state is ForgetPasswordSuccess) {
                        Get.toNamed(
                          AppRoutes.resendPasswordEmail,
                          arguments: emailController.text.trim(),
                        );
                      } else if (state is ForgetPasswordFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error)),
                        );
                      }
                    },
                    builder: (context, state) {
                      final loading = state is ForgetPasswordLoading;

                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                            child: Form(
                              key: formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: isAr
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icon + header
                                  Row(
                                    mainAxisAlignment: isAr
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 64,
                                        width: 64,
                                        decoration: BoxDecoration(
                                          color:
                                              scheme.primary.withOpacity(.12),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: Icon(
                                          Icons.lock_reset_rounded,
                                          size: 30,
                                          color: scheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'forget_password'.tr,
                                    style: AppTextStyles.headline(context)
                                        .copyWith(
                                      height: 1.15,
                                    ),
                                    textAlign:
                                        isAr ? TextAlign.right : TextAlign.left,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'enter_email_to_reset'.tr,
                                    style: AppTextStyles.bodyMuted(context)
                                        .copyWith(
                                      color: scheme.onSurface.withOpacity(.72),
                                    ),
                                    textAlign:
                                        isAr ? TextAlign.right : TextAlign.left,
                                  ),
                                  const SizedBox(height: 22),

                                  // Email input
                                  BasicInput(
                                    controller: emailController,
                                    label: 'email'.tr,
                                    hintText: 'enter_email_to_reset'.tr,
                                    keyboardType: TextInputType.emailAddress,
                                    isBorder: true,
                                    radius: 16,
                                    prefixIcon:
                                        const Icon(Icons.email_outlined),
                                    validator: (v) {
                                      final value = (v ?? '').trim();
                                      if (value.isEmpty) {
                                        return 'email_required'.tr;
                                      }
                                      final re =
                                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                      if (!re.hasMatch(value)) {
                                        return 'invalid_email'.tr;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Submit
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: loading
                                          ? null
                                          : () {
                                              if (formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                context
                                                    .read<ForgetPasswordCubit>()
                                                    .sendResetEmail(
                                                        emailController.text
                                                            .trim());
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: scheme.primary,
                                        foregroundColor: scheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 20,
                                        ),
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        child: loading
                                            ? SizedBox(
                                                key: const ValueKey('loading'),
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    scheme.onPrimary,
                                                  ),
                                                ),
                                              )
                                            : Row(
                                                key: const ValueKey('label'),
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons.send_rounded),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'send_reset_link'.tr,
                                                    style: AppTextStyles.button(
                                                        context),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Back to login
                                  Row(
                                    mainAxisAlignment: isAr
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            Navigator.of(context).maybePop(),
                                        icon: const Icon(
                                            Icons.arrow_back_rounded,
                                            size: 18),
                                        label: Text(
                                          'login'.tr,
                                          style: AppTextStyles.link(context),
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: scheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Loading overlay
                          if (loading)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  color: scheme.surface.withOpacity(.25),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
