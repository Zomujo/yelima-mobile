import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../controllers/all_medicines_controller.dart';
import '../widgets/all_medicines/medicines_list.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// Every medication, with add and swipe-to-delete.
class AllMedicinesScreen extends ConsumerStatefulWidget {
  const AllMedicinesScreen({super.key});

  @override
  ConsumerState<AllMedicinesScreen> createState() => _AllMedicinesScreenState();
}

class _AllMedicinesScreenState extends ConsumerState<AllMedicinesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allMedicinesControllerProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      appBar: AppHeader(
        title: context.l10n.allMedicines,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  GoRouter.of(context).push(RoutePaths.addMedication);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.orange300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppText.bodyMedium(
                    context.l10n.add,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: const MedicinesList(),
    );
  }
}
