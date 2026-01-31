import 'package:ecommerce_app/components/basic_input.dart';
import 'package:ecommerce_app/views/changePassword/cubit/change_password_cubit.dart';
import 'package:ecommerce_app/views/changePassword/cubit/change_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordCubit(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatelessWidget {
  const _ChangePasswordView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('password_changed_successfully'.tr)),
          );
        } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ChangePasswordCubit>();

        return Scaffold(
          appBar: AppBar(
            title: Text('change_password'.tr),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'change_password_page_content_here'.tr,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  BasicInput(
                    controller: cubit.oldPasswordController,
                    isPassword: true,
                    radius: 20,
                    label: 'old_password'.tr,
                    isBorder: true,
                  ),
                  const SizedBox(height: 10),

                  BasicInput(
                    controller: cubit.newPasswordController,
                    isPassword: true,
                    radius: 20,
                    label: 'new_password'.tr,
                    isBorder: true,
                  ),
                  const SizedBox(height: 10),

                  BasicInput(
                    controller: cubit.confirmPasswordController,
                    isPassword: true,
                    radius: 20,
                    label: 'confirm_password'.tr,
                    isBorder: true,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      onPressed: state.isLoading
                          ? null
                          : () => cubit.changePassword(),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('change_password'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
