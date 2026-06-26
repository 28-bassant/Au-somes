import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/stories_time/screens/loading_screen.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../utils/app_colors.dart';

class StoryTimeScreen extends StatefulWidget {
  const StoryTimeScreen({super.key});

  @override
  State<StoryTimeScreen> createState() => _StoryTimeScreenState();
}

class _StoryTimeScreenState extends State<StoryTimeScreen> {
  late TextEditingController _nameCtrl;
  String? _selectedTopic;
  final Set<String> _selectedConcepts = {};

  bool get isRtl => Localizations.localeOf(context).languageCode == 'ar';

  List<Map<String, String>> get _topics {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'key': 'day_at_kindergarten', 'label': l10n.day_at_kindergarten},
      {'key': 'park_outing', 'label': l10n.park_outing},
      {'key': 'space_adventure', 'label': l10n.space_adventure},
      {'key': 'underwater_world', 'label': l10n.underwater_world},
      {'key': 'supermarket_trip', 'label': l10n.supermarket_trip},
    ];
  }

  List<Map<String, String>> get _concepts {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'key': 'above', 'label': l10n.above},
      {'key': 'under', 'label': l10n.under},
      {'key': 'between', 'label': l10n.between},
      {'key': 'near', 'label': l10n.near},
      {'key': 'far', 'label': l10n.far},
      {'key': 'inside', 'label': l10n.inside},
      {'key': 'outside', 'label': l10n.outside},
      {'key': 'left', 'label': l10n.left},
      {'key': 'right', 'label': l10n.right},
      {'key': 'front', 'label': l10n.front},
      {'key': 'back', 'label': l10n.back},
      {'key': 'visual_perception', 'label': l10n.visual_perception},
    ];
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          _buildHeader(l10n),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * .04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * .03),
                  _buildNameField(l10n),
                  SizedBox(height: height * .03),
                  _buildTopics(l10n),
                  SizedBox(height: height * .03),
                  _buildConcepts(l10n),
                  SizedBox(height: height * .03),
                ],
              ),
            ),
          ),
          _buildStartButton(l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    final isArabic = languageProvider.isArabic();
    var height = MediaQuery.of(context).size.height;


    return Container(
      height: height * .15,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 56, 18, 22),
      decoration: BoxDecoration(
        color: AppColors.lightPastelBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  l10n.interactive_story,
                  textAlign: TextAlign.center,
                  style: AppStyles.bold18Black,
                ),
              ),
              // السهم - في اليمين للعربي، وفي اليسار للإنجليزي
              Positioned(
                right: isArabic ? 0 : null,
                left: isArabic ? null : 0,
                child: InkWell(
                  onTap: () {
                    Navigator.popUntil(
                      context,
                          (route) => route is MaterialPageRoute && route.builder.toString().contains('ParentScreen'),
                    );
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: AppColors.blackColor,
                  ),
                ),              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            l10n.story_time_header,
            textAlign: TextAlign.center,
            style: AppStyles.medium14BlackWithOpacity60,
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(l10n.child_name, style: AppStyles.bold14Black),
            const SizedBox(width: 6),
            const Text('🧒', style: TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.greyColor),
          ),
          child: TextField(
            controller: _nameCtrl,
            style: AppStyles.medium10Black,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: InputBorder.none,
              hintText: l10n.enter_child_name,
              hintStyle: AppStyles.regular14Grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopics(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.story_theme, style: AppStyles.bold14Black),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _topics.map((t) {
            final sel = _selectedTopic == t['key'];
            return GestureDetector(
              onTap: () => setState(() => _selectedTopic = t['key']),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: sel ? AppColors.softBlue : AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: sel ? AppColors.softBlue : AppColors.greyColor,
                  ),
                ),
                child: Text(
                  t['label']!,
                  style: AppStyles.bold12Black.copyWith(
                    color: sel ? AppColors.whiteColor : AppColors.blackColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConcepts(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.spatial_visual_for_training, style: AppStyles.bold14Black),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _concepts.map((c) {
            final sel = _selectedConcepts.contains(c['key']);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) {
                  _selectedConcepts.remove(c['key']);
                } else {
                  _selectedConcepts.add(c['key']!);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: sel ? AppColors.softBlue : AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: sel ? AppColors.softBlue : AppColors.greyColor,
                  ),
                ),
                child: Text(
                  c['label']!,
                  style: AppStyles.bold12Black.copyWith(
                    color: sel ? AppColors.whiteColor : AppColors.blackColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoadingScreen(),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.softBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 0,
        ),
        child: Text(l10n.start_interactive_story, style: AppStyles.bold16White),
      ),
    );
  }
}