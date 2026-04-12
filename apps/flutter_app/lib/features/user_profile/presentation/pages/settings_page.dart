import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/widgets/profile_section_navigation_bar.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/pages/contact_us_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.userType,
  });

  final String userType;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  String _language = 'English';
  String _savedAddress = 'Cairo, Egypt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: ProfileSectionNavigationBar(
        userType: widget.userType,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          _tile(
            Icons.phone_outlined,
            'Contact us',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContactUsPage(userType: widget.userType),
                ),
              );
            },
          ),
          if (widget.userType != 'Doctor') ...[
            SizedBox(height: 14.h),
            _tile(
              Icons.location_on_outlined,
              'Save Address',
              trailingText: _savedAddress,
              onTap: _showAddressDialog,
            ),
          ],
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                const Icon(Icons.dark_mode_outlined),
                SizedBox(width: 14.w),
                Text(
                  'Dark Mode',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) => setState(() => isDarkMode = value),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          _tile(
            Icons.share_outlined,
            'Share',
            onTap: _shareApp,
          ),
          SizedBox(height: 14.h),
          _tile(
            Icons.language_outlined,
            'Language',
            trailingText: _language,
            onTap: _showLanguageSheet,
          ),
          SizedBox(height: 14.h),
          _tile(
            Icons.info_outline_rounded,
            'App info',
            onTap: _showAppInfo,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddressDialog() async {
    final controller = TextEditingController(text: _savedAddress);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Address'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter your address',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                setState(() => _savedAddress = text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLanguageSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                trailing:
                    _language == 'English' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _language = 'English');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Arabic'),
                trailing: _language == 'Arabic' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _language = 'Arabic');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareApp() {
    Clipboard.setData(
      const ClipboardData(
        text: 'Try Physixia demo for guided recovery sessions and patient follow-up.',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App message copied to clipboard')),
    );
  }

  void _showAppInfo() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('App info'),
          content: const Text(
            'Physixia ROM Tracker\nVersion 1.0 Demo\nGraduation project build for patient follow-up and recovery flows.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _tile(
    IconData icon,
    String title, {
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(icon),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingText != null)
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    trailingText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            SizedBox(width: 8.w),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
