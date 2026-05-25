import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Wishlist',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF26215C),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border,
                size: 64.r, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              'No saved items yet',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap the heart on any product\nto save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}