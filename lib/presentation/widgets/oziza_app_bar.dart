import 'package:flutter/material.dart';

class OzizaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

  const OzizaAppBar({super.key, this.onSearchTap, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 80.0,
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onSearchTap,
                child: const Icon(Icons.search, color: Colors.white, size: 30),
              ),
              const Text(
                'OZIZA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                  fontFamily: 'Arial',
                ),
              ),
              GestureDetector(
                onTap: onNotificationTap,
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
