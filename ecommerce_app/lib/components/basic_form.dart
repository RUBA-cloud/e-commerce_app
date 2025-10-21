// ...existing code...
import 'package:flutter/material.dart';

class BasicFormWidget extends StatelessWidget {
  final Widget form;
  const BasicFormWidget({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primaryContainer.withOpacity(.45),
                scheme.surfaceVariant.withOpacity(.35),
                scheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Decorative blobs
        Positioned(
          top: -80,
          left: -50,
          child: _blurBall(scheme.primary.withOpacity(.18), 200),
        ),
        Positioned(
          bottom: -100,
          right: -60,
          child: _blurBall(scheme.secondary.withOpacity(.16), 240),
        ),

        // Foreground form
        Center(child: form),
      ],
    );
  }

  Widget _blurBall(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.9),
            blurRadius: size * 0.35,
            spreadRadius: size * 0.12,
          ),
        ],
      ),
    );
  }
}
// ...existing code...
