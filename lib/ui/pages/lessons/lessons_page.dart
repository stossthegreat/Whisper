import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/taxonomy/tag_registry.dart';
import '../../../data/providers.dart';
import '../../../data/models/profile_models.dart';

import '../../shared/loading_shell.dart';
import '../../../features/lessons/world_overview/world_overview_page.dart';
import '../../../widgets/app_header.dart';

class LessonsPage extends ConsumerStatefulWidget {
  const LessonsPage({super.key});

  @override
  ConsumerState<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends ConsumerState<LessonsPage> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: WFColors.base,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            return _LessonsContent(profile: profile);
          },
          loading: () {
            return const LoadingShell();
          },
          error: (error, stack) {
            return const Center(
              child: Text('Error loading profile'),
            );
          },
        ),
      ),
    );
  }
}

class _LessonsContent extends ConsumerWidget {
  final UserProfile profile;

  const _LessonsContent({required this.profile});

  // Resolve image base path for category, supporting custom names for specific slugs
  String _categoryAssetBase(String slug) {
    switch (slug) {
      case 'composed_authority':
        return 'assets/images/categories/emotional_alchemy';
      case 'strategic_influence':
        return 'assets/images/categories/psychological_gravity';
      default:
        return 'assets/images/categories/$slug';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(WFDims.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with XP
          Center(
            child: Column(
              children: [
                Text('Learning Hub',
                    style: WFTextStyles.h1.copyWith(color: Colors.white)),
                const SizedBox(height: WFDims.spacingS),
                Text(
                  'Total XP: ${profile.xpTotal}',
                  style: WFTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: WFDims.spacingXL),

          // Categories Grid
          const SizedBox(height: WFDims.spacingL),

          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final categoryData = [
                {
                  'slug': 'magnetic_presence',
                  'name': displayTag('magnetic_presence'),
                  'color': 0xFFE91E63,
                  'emoji': '💫'
                },
                {
                  'slug': 'composed_authority',
                  'name': displayTag('composed_authority'),
                  'color': 0xFF26A69A,
                  'emoji': '❄️'
                },
                {
                  'slug': 'conversation_frames',
                  'name': displayTag('conversation_frames'),
                  'color': 0xFF3F51B5,
                  'emoji': '🎭'
                },
                {
                  'slug': 'scarcity_desire',
                  'name': displayTag('scarcity_desire'),
                  'color': 0xFFFF9800,
                  'emoji': '💎'
                },
                {
                  'slug': 'hidden_dynamics',
                  'name': displayTag('hidden_dynamics'),
                  'color': 0xFF9C27B0,
                  'emoji': '🎭'
                },
                {
                  'slug': 'strategic_influence',
                  'name': displayTag('strategic_influence'),
                  'color': 0xFF4CAF50,
                  'emoji': '⚔️'
                },
              ];

              final category = categoryData[index];
              final categoryProgress =
                  profile.categories[category['slug']!] ?? CategoryProgress();

              return _buildCategoryCard(
                context,
                category['slug'] as String,
                category['name'] as String,
                category['color'] as int,
                category['emoji'] as String,
                categoryProgress,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String categorySlug,
    String categoryName,
    int color,
    String emoji,
    CategoryProgress progress,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isUnlocked = profile.unlockedCategories.contains(categorySlug);
    final String assetBase = _categoryAssetBase(categorySlug);

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WorldOverviewPage(category: categorySlug),
                ),
              );
            }
          : null,
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
        child: Stack(
            children: [
              // Background image for category
              Positioned.fill(
                child: Image.asset(
                  '$assetBase.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      '$assetBase.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context2, error2, stackTrace2) {
                        // Fallback to colored background if asset missing
                        return Container(color: Color(color).withOpacity(0.15));
                      },
                    );
                  },
                ),
              ),
              // Dark gradient overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.35),
                      ],
                    ),
                  ),
                ),
              ),

              // Top row: chips left, lock right
              Positioned(
                top: screenWidth * 0.03,
                left: screenWidth * 0.03,
                right: screenWidth * 0.03,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress chips (Lv, XP)
                    Row(
                      children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.025,
                              vertical: screenHeight * 0.004),
                decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  'Lv.${progress.level}',
                  style: WFTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.028,
                  ),
                ),
              ),
                        SizedBox(width: screenWidth * 0.02),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.025,
                              vertical: screenHeight * 0.004),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                '${progress.xp} XP',
                style: WFTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontSize: screenWidth * 0.028,
                            ),
                ),
              ),
            ],
          ),
                    const Spacer(),
            if (!isUnlocked)
                      Icon(
                        Icons.lock,
                        color: Colors.white.withOpacity(0.85),
                      ),
                  ],
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}
