import 'package:flutter/material.dart';

class DurationSelector extends StatelessWidget {
  final String duration;
  final Function(String) onDurationChanged;

  const DurationSelector({super.key, required this.duration, required this.onDurationChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildDurationButton('24h', '24 Hours'),
          _buildDurationButton('1w', '1 Week'),
          _buildDurationButton('1m', '1 Month'),
        ],
      ),
    );
  }

  Widget _buildDurationButton(String id, String label) {
    final isActive = duration == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => onDurationChanged(id),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isActive ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
