import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

import '../../core/services/app_startup_service.dart';
import '../../core/constants/app_images.dart';
import '../../core/theme/app_colors.dart';
import '../../injection_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isAnimationComplete = false;
  bool _hasNavigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AppImages.logoPng, context);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Mandatory 2s delay
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward();
      });

      // Start the heavy initialization after a slight delay so animations don't stutter
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _init();
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        _isAnimationComplete = true;
        _navigateBasedOnStartupStatus();
      }
    });
  }

  Future<void> _init() async {
    final startupService = sl<AppStartupService>();
    startupService.addListener(_onStartupStatusChanged);
    await startupService.start();
  }

  void _onStartupStatusChanged() {
    if (!mounted) return;

    // If the animation is already done, we can navigate now
    if (_isAnimationComplete) {
      _navigateBasedOnStartupStatus();
    }
  }

  void _navigateBasedOnStartupStatus() {
    if (!mounted || _hasNavigated) return;

    final startupService = sl<AppStartupService>();
    final status = startupService.value;

    if (status.phase == StartupPhase.ready ||
        status.phase == StartupPhase.unauthenticated ||
        status.phase == StartupPhase.error) {
      
      _hasNavigated = true;
      final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
      context.go(redirect ?? '/');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    sl<AppStartupService>().removeListener(_onStartupStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color(0xFFFAF9F6),
        systemNavigationBarColor: const Color(0xFFFAF9F6),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo fading in and scaling up elegantly
              const Image(
                image: AppImages.logoPng,
                height: 180,
                width: 180,
                fit: BoxFit.fill,
              )
                  .animate(controller: _controller)
                  .fadeIn(duration: 1200.ms, curve: Curves.easeOut)
                  .scaleXY(
                      begin: 0.8,
                      end: 1.0,
                      duration: 1200.ms,
                      curve: Curves.easeOutCubic)
                  .shimmer(
                      delay: 600.ms, duration: 1200.ms, color: Colors.white54),

              const SizedBox(height: 6),

              // Text revealing with a gentle rise and fade
              const Text(
                'Yelima',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 2.0,
                  height: 1.1,
                ),
              )
                  .animate(controller: _controller)
                  .fadeIn(duration: 800.ms, delay: 600.ms)
                  .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 800.ms,
                      delay: 600.ms,
                      curve: Curves.easeOutQuart),
            ],
          ),
        ),
      ),
    );
  }
}
