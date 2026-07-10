import 'package:flutter/material.dart';

class FullScreenCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const FullScreenCloseButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: Material(
        color: const Color(0xFF374151).withValues(alpha: 0.85),
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.fullscreen_exit,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
