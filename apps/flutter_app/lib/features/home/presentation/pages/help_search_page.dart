import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/symptom_list_page.dart';

class HelpSearchPage extends StatefulWidget {
  const HelpSearchPage({super.key});

  @override
  State<HelpSearchPage> createState() => _HelpSearchPageState();
}

class _HelpSearchPageState extends State<HelpSearchPage> {
  static const List<String> suggestions = [
    'Shockwave therapy',
    'Ultrasound therapy',
    'Pediatric physiotherapy',
    'Laser therapy',
    'Spine therapy',
    'Chronic pain',
  ];

  final TextEditingController _searchController = TextEditingController(
    text: 'Rehab exercises',
  );

  List<String> get _filteredSuggestions {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return suggestions;
    return suggestions
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Search',
      subtitle:
          'Quickly search treatments, therapy techniques, or rehab guidance.',
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.black, size: 24),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Rehab exercises',
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 16.sp,
                      ),
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice search is not available yet'),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(999.r),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  overlayColor: const MaterialStatePropertyAll(Colors.transparent),
                  child: const Icon(Icons.mic_none, color: Colors.black, size: 24),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          ListView.separated(
            itemCount: _filteredSuggestions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(height: 18.h),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  _searchController.text = _filteredSuggestions[index];
                  setState(() {});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SymptomListPage(),
                    ),
                  );
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: const MaterialStatePropertyAll(Colors.transparent),
                child: Text(
                  _filteredSuggestions[index],
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    color: const Color(0xFFC8C8C8),
                    fontWeight: FontWeight.w400,
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
