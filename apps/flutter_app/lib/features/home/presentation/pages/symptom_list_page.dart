import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/condition_details_page.dart';

class SymptomListPage extends StatefulWidget {
  const SymptomListPage({super.key});

  @override
  State<SymptomListPage> createState() => _SymptomListPageState();
}

class _SymptomListPageState extends State<SymptomListPage> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> symptoms = [
    {'name': 'Gout', 'icon': Icons.pan_tool_alt_outlined},
    {'name': 'Fractures', 'icon': Icons.hub_outlined},
    {'name': 'Nerve Injury', 'icon': Icons.psychology_outlined},
    {'name': 'Arthritis', 'icon': Icons.accessibility_new_rounded},
    {'name': 'Sporty', 'icon': Icons.fitness_center_rounded},
    {'name': 'Orthopedic', 'icon': Icons.personal_injury_outlined},
    {'name': 'Trauma', 'icon': Icons.airline_seat_flat_angled_outlined},
    {'name': 'Rheumatolo', 'icon': Icons.front_hand_outlined},
  ];

  List<Map<String, dynamic>> get _filteredSymptoms {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return symptoms;
    return symptoms
        .where((item) => (item['name'] as String).toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Find Your Symptoms',
      subtitle:
          'Choose the closest category so the patient journey stays relevant from the first step.',
      onBack: () => Navigator.pop(context),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            height: 56.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textSecondary),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search symptoms',
                      border: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.82,
            ),
            itemCount: _filteredSymptoms.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (_filteredSymptoms[index]['name'] == 'Arthritis') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConditionDetailsPage(),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4E7EE),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          _filteredSymptoms[index]['icon'] as IconData,
                          size: 22.sp,
                          color: const Color(0xFF4A4A4A),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        _filteredSymptoms[index]['name'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
