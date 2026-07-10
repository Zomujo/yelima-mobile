import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yelima/shared/widgets/layout/app_button.dart';
import '../../core/router/route_paths.dart';
import '../widgets/layout/app_scaffold.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Go Home',
              onPressed: () => context.go(RoutePaths.home),
            ),
          ],
        ),
      ),
    );
  }
}
