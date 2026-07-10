import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_decoration.dart';
import '../../../../core/router/route_paths.dart';
import '../controllers/home_metrics_controller.dart';
import 'package:provider/provider.dart';

class HomeBottomNavItem {
  final dynamic assetPath;
  final String route;
  final bool isAvatar;

  const HomeBottomNavItem({
    required this.assetPath,
    required this.route,
    this.isAvatar = false,
  });
}

final List<HomeBottomNavItem> _bottomNavs = [
  HomeBottomNavItem(
    assetPath: AppImages.homeIcon.assetName,
    route: RoutePaths.home,
  ),
  HomeBottomNavItem(
    assetPath: AppImages.messageIcon.assetName,
    route: RoutePaths.chat,
  ),
  HomeBottomNavItem(
    assetPath: AppImages.logIcon.assetName,
    route: RoutePaths.readingLogging,
  ),
  HomeBottomNavItem(
    assetPath: AppImages.tickedAppointIcon.assetName,
    route: RoutePaths.appointments,
  ),
  const HomeBottomNavItem(
    assetPath: Iconsax.user,
    route: RoutePaths.profile,
    isAvatar: false,
  ),
];

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).matchedLocation;

    return SafeArea(
      top: false,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: AppDecoration.shadowMd,
          ),
          child: Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List.generate(
              _bottomNavs.length,
              (index) {
                final item = _bottomNavs[index];
                final isActive = path.startsWith(item.route);

                return _NavItemButton(item: item, isActive: isActive);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  final bool isActive;
  final HomeBottomNavItem item;

  const _NavItemButton({required this.item, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive
          ? null
          : () {
              // Proactively refresh home metrics if navigating to Home
              if (item.route == RoutePaths.home) {
                try {
                  context.read<HomeMetricsController>().fetchMetrics();
                } catch (_) {}
              }
              context.go(item.route);
            },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: item.isAvatar
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: AppColors.primary, width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.transparent,
                  backgroundImage: item.assetPath is AssetImage
                      ? item.assetPath
                      : AssetImage(item.assetPath.toString()),
                ),
              )
            : item.assetPath is IconData
                ? Icon(
                    item.assetPath as IconData,
                    size: 28,
                    color: isActive ? AppColors.primary : AppColors.textGrey,
                  )
                : SvgPicture.asset(
                    item.assetPath is AssetImage
                        ? (item.assetPath as AssetImage).assetName
                        : item.assetPath.toString(),
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      isActive ? AppColors.primary : AppColors.textGrey,
                      BlendMode.srcIn,
                    ),
                  ),
      ),
    );
  }
}
