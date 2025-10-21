// lib/features/auth/verify_email/verify_email_page.dart
import 'dart:ui';
import 'package:ecommerce_app/components/basic_form.dart';
import 'package:ecommerce_app/views/auth/verify_email/cubit/verify_email_cubit.dart';
import 'package:ecommerce_app/views/auth/verify_email/cubit/verify_email_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:get/get.dart';

class VerifyEmailAndResendEmailPage extends StatelessWidget {
  final String title;
  final String headlineText;
  final String subTitle;
  final String appRoute;

  const VerifyEmailAndResendEmailPage({
    super.key,
    required this.title,
    required this.subTitle,
    required this.headlineText,
    required this.appRoute,
  });

  @override
  Widget build(BuildContext context) {
    final String email = Get.arguments as String? ?? '';
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => VerifyEmailCubit()..sendEmail(appRoute, email),
      child: BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
        listenWhen: (p, c) =>
            p.verified != c.verified || p.error != c.error || p.sent != c.sent,
        listener: (context, state) {
          if (state.verified) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('email_verified'.trParams({'k': 'Email verified'})),
              ),
            );
          } else if (state.sent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('verification_email_sent'
                    .trParams({'k': 'Verification email sent'})),
              ),
            );
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<VerifyEmailCubit>();

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(title),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: scheme.onPrimaryContainer,
            ),
            body:
                // Content
                BasicFormWidget(
              form: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: scheme.outlineVariant.withOpacity(.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.06),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                            color: scheme.surface.withOpacity(.75),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon badge with soft gradient ring
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        scheme.primary.withOpacity(.12),
                                        scheme.secondary.withOpacity(.10),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: scheme.primary.withOpacity(.15),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.mark_email_read_rounded,
                                      size: 44,
                                      color: scheme.primary,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
                                Text(
                                  headlineText,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  subTitle,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurface.withOpacity(0.72),
                                    height: 1.35,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 14),

                                // Email chip (masked a bit for style)
                                if (email.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: scheme.primaryContainer
                                          .withOpacity(.35),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: scheme.primary.withOpacity(.20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.alternate_email,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          email,
                                          style: textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 20),

                                // Actions row
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: state.checking
                                            ? null
                                            : cubit.checkVerified,
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          elevation: state.checking ? 0 : 1,
                                        ),
                                        child: state.checking
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              )
                                            : Text('i_verified'
                                                .trParams({'k': 'I verified'})),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: state.sending ||
                                                state.secondsLeft > 0
                                            ? null
                                            : () => cubit.sendEmail(
                                                  appRoute,
                                                  email,
                                                ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Builder(
                                          builder: (_) {
                                            if (state.sending) {
                                              return const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            }
                                            return Text(
                                              state.secondsLeft > 0
                                                  ? 'resend_in_seconds'
                                                      .trParams({
                                                      's':
                                                          'Resend in ${state.secondsLeft}s'
                                                    })
                                                  : 'resend_email'.trParams(
                                                      {'k': 'Resend email'}),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // “Open email app”
                                TextButton.icon(
                                  onPressed: _openEmailApp,
                                  icon: const Icon(Icons.open_in_new_rounded),
                                  label: Text('open_email_app'
                                      .trParams({'k': 'Open email app'})),
                                ),

                                const SizedBox(height: 6),

                                // Wrong email hint
                                Text(
                                  'wrong_email_hint'.trParams({
                                    'k':
                                        "Used the wrong email? Go back and change it."
                                  }),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurface.withOpacity(0.64),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 8),

                                // Status strip (dynamic)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: _statusColor(
                                            scheme: scheme, state: state)
                                        .withOpacity(.12),
                                    border: Border.all(
                                      color: _statusColor(
                                              scheme: scheme, state: state)
                                          .withOpacity(.22),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _statusIcon(state),
                                        size: 18,
                                        color: _statusColor(
                                            scheme: scheme, state: state),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        state.verified
                                            ? 'email_verified'.trParams(
                                                {'k': 'Email verified'})
                                            : state.sent
                                                ? 'verification_email_sent'
                                                    .trParams({
                                                    'k':
                                                        'Verification email sent'
                                                  })
                                                : state.sending
                                                    ? 'resend_email'.trParams(
                                                        {'k': 'Resend email'})
                                                    : 'open_email_app'
                                                        .trParams({
                                                        'k': 'Open email app'
                                                      }),
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: _statusColor(
                                              scheme: scheme, state: state),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _statusColor({
    required ColorScheme scheme,
    required VerifyEmailState state,
  }) {
    if (state.verified) return scheme.tertiary;
    if (state.sent) return scheme.primary;
    if (state.sending) return scheme.secondary;
    return scheme.outline;
  }

  IconData _statusIcon(VerifyEmailState state) {
    if (state.verified) return Icons.verified_rounded;
    if (state.sent) return Icons.send_rounded;
    if (state.sending) return Icons.autorenew_rounded;
    return Icons.info_outline_rounded;
  }

  Future<void> _openEmailApp() async {
    const url = 'mailto:';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }
}
