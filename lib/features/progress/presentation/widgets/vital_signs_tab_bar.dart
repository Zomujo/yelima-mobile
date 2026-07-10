import 'package:flutter/material.dart';

class VitalSignsTabBar extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChanged;

  const VitalSignsTabBar({super.key, required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildTab('bp', Icons.favorite, 'Blood Pressure',
              const [Color(0xFFEF4444), Color(0xFFEC4899)]),
          const SizedBox(width: 12),
          _buildTab('glucose', Icons.water_drop, 'Glucose',
              const [Color(0xFF3B82F6), Color(0xFF06B6D4)]),
        ],
      ),
    );
  }

  Widget _buildTab(String id, IconData icon, String label, List<Color> gradientColors) {
    final isActive = activeTab == id;
    return GestureDetector(
      onTap: () => onTabChanged(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isActive ? 1.05 : 1.0),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(colors: gradientColors)
              : const LinearGradient(colors: [Colors.white, Colors.white]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isActive ? Colors.black26 : Colors.black12,
              blurRadius: isActive ? 10 : 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : const Color(0xFF374151),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
