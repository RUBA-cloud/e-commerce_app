import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF26215C),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Avatar ──────────────────────────────────────
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: const Color(0xFFEEEDFE),
                      child: Text(
                        'AR',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3C3489),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Ahmad Al-Rashid',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF26215C),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'ahmad@example.com',
                      style: TextStyle(
                          fontSize: 13.sp, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // ── Menu items ───────────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _menuItem(Icons.shopping_bag_outlined, 'My Orders'),
                  _divider(),
                  _menuItem(Icons.location_on_outlined, 'Addresses'),
                  _divider(),
                  _menuItem(Icons.payment_outlined, 'Payment Methods'),
                  _divider(),
                  _menuItem(Icons.notifications_outlined, 'Notifications'),
                  _divider(),
                  _menuItem(Icons.help_outline_rounded, 'Help & Support'),
                  _divider(),
                  _menuItem(Icons.info_outline_rounded, 'About'),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── Logout ───────────────────────────────────────
            Container(
              color: Colors.white,
              child: _menuItem(
                Icons.logout_rounded,
                'Log Out',
                color: Colors.red[400],
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon,
              size: 22.r,
              color: color ?? const Color(0xFF3C3489)),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: color ?? const Color(0xFF26215C),
              ),
            ),
          ),
          Icon(Icons.chevron_right,
              size: 18.r, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    indent: 52.w,
    color: Colors.grey.withOpacity(0.12),
  );
}