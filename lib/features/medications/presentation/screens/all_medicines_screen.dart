import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../controllers/all_medicines_controller.dart';
import '../widgets/all_medicines/medicines_list.dart';

class AllMedicinesScreen extends StatefulWidget {
  const AllMedicinesScreen({super.key});

  @override
  State<AllMedicinesScreen> createState() => _AllMedicinesScreenState();
}

class _AllMedicinesScreenState extends State<AllMedicinesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllMedicinesController>().fetchAllMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      appBar: AppHeader(
        title: 'All Medicines',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  GoRouter.of(context).push('/medications/add');
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDBA74),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const AppText.bodyMedium(
                    'Add',
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
