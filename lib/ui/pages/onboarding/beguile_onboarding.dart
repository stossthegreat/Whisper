import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';

/* ──────────────────────── IMAGE CONSTANTS ──────────────────────── */
const List<String> _dojoCategoryImages = [
  'assets/images/categories/conversation_frames.jpg',
  'assets/images/categories/emotional_alchemy.png',
  'assets/images/categories/hidden_dynamics.jpg',
  'assets/images/categories/magnetic_presence.jpg',
  'assets/images/categories/psychological_gravity.png',
  'assets/images/categories/scarcity_desire.jpg',
];

const List<String> _mentorImages = [
  'assets/images/mentors/casanova.png',
  'assets/images/mentors/churchill.png',
  'assets/images/mentors/cleopatra.png',
  'assets/images/mentors/machiavelli.png',
  'assets/images/mentors/marcus_aurelius.png',
  'assets/images/mentors/sun_tzu.png',
];

/* ──────────────────────── MAIN ONBOARDING ──────────────────────── */
class BeguileOnboarding extends ConsumerStatefulWidget {
  final VoidCallback onFinish;
  const BeguileOnboarding({super.key, required this.onFinish});

  @override
  ConsumerState<BeguileOnboarding> createState() => _BeguileOnboardingState();
}

class _BeguileOnboardingState extends ConsumerState<BeguileOnboarding>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _WelcomeSlide(),
      const _LessonsSlide(),
      const _MentorsSlide(),
      const _AnalyzeSlide(),
      const _PowerSlide(),
      _FinishSlide(onContinue: widget.onFinish),
    ];

    return Scaffold(
      backgroundColor: WFColors.base,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => pages[i],
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: IgnorePointer(
                ignoring: true,
                child: Row(
                  children: [
                    _PageDots(count: pages.length, index: _page),
                    const Spacer(),
                    _BrandedFooter(),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            if (_page < pages.length - 1)
              Positioned(
                right: 16,
                bottom: 88,
                child: _GhostButton(
                  label: 'Next',
                  onTap: () => _controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────── SLIDES ───────────────────────── */

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide();
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: h * 0.8),
        child: Padding(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.05),
              Text('Welcome to',
                  style: WFTextStyles.h2.copyWith(
                    color: WFColors.gray400,
                    fontWeight: FontWeight.w600,
                    fontSize: w * 0.045,
                  )),
              SizedBox(height: h * 0.01),
              ShaderMask(
                shaderCallback: (b) =>
                    WFGradients.purpleGradient.createShader(b),
                child: Text('BEGUILE AI',
                    style: WFTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontSize: w * 0.08,
                    )),
              ),
              SizedBox(height: h * 0.02),
              Text('Where desire becomes strategy.',
                  style: WFTextStyles.h3.copyWith(
                    color: WFColors.purple400,
                    fontWeight: FontWeight.w700,
                    fontSize: w * 0.04,
                  )),
              SizedBox(height: h * 0.04),
              Text(
                "You've been chosen to step into the circle. Learn to hold the frame, ignite tension, and speak in lines that live rent-free in their minds forever.",
                style: WFTextStyles.bodyLarge.copyWith(
                  color: WFColors.gray300,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  fontSize: w * 0.035,
                ),
              ),
              SizedBox(height: h * 0.03),
              Container(
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.amber, size: w * 0.06),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: Text(
                      'Master the art of communication through advanced social psychology and strategic thinking.',
                      style: TextStyle(
                        color: Colors.amber[200],
                        fontSize: w * 0.03,
                      ),
                    ),
                  ),
                ]),
              ),
              SizedBox(height: h * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

/* --------------------------- DOJO --------------------------- */
class _LessonsSlide extends StatelessWidget {
  const _LessonsSlide();
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: h * 0.8),
        child: Padding(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.05),
              Text('THE DOJO',
                  style: WFTextStyles.h1.copyWith(
                    color: WFColors.purple400,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontSize: w * 0.08,
                  )),
              SizedBox(height: h * 0.01),
              Text('Where legends are forged',
                  style: WFTextStyles.h3.copyWith(
                    color: WFColors.gray400,
                    fontWeight: FontWeight.w600,
                    fontSize: w * 0.04,
                  )),
              SizedBox(height: h * 0.04),
              const _ImageGrid(assetPaths: _dojoCategoryImages),
              SizedBox(height: h * 0.03),
              Text(
                "Behind these doors lie 120+ lessons across 6 legendary categories. Each world unlocks new levels of mastery. You start as a student. You'll leave as a master.",
                style: WFTextStyles.bodyLarge.copyWith(
                  color: WFColors.gray300,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  fontSize: w * 0.035,
                ),
              ),
              SizedBox(height: h * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

/* --------------------------- MENTORS --------------------------- */
class _MentorsSlide extends StatelessWidget {
  const _MentorsSlide();
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: h * 0.8),
        child: Padding(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.05),
              Text('THE COUNCIL',
                  style: WFTextStyles.h1.copyWith(
                    color: WFColors.purple400,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontSize: w * 0.08,
                  )),
              SizedBox(height: h * 0.01),
              Text('Ancient wisdom at your fingertips',
                  style: WFTextStyles.h3.copyWith(
                    color: WFColors.gray400,
                    fontWeight: FontWeight.w600,
                    fontSize: w * 0.04,
                  )),
              SizedBox(height: h * 0.04),
              const _ImageGrid(assetPaths: _mentorImages),
              SizedBox(height: h * 0.03),
              Text(
                "Six legendary mentors await your questions. Casanova teaches charm defense. Cleopatra reveals power plays. Machiavelli exposes cunning. Each AI mentor is a master of their domain.",
                style: WFTextStyles.bodyLarge.copyWith(
                  color: WFColors.gray300,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  fontSize: w * 0.035,
                ),
              ),
              SizedBox(height: h * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

/* --------------------------- ANALYZER --------------------------- */
class _AnalyzeSlide extends StatelessWidget {
  const _AnalyzeSlide();
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: h * 0.8),
        child: Padding(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.05),
              Text('THE SCANNER',
                  style: WFTextStyles.h1.copyWith(
                    color: WFColors.purple400,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontSize: w * 0.08,
                  )),
              SizedBox(height: h * 0.01),
              Text('See through every facade',
                  style: WFTextStyles.h3.copyWith(
                    color: WFColors.gray400,
                    fontWeight: FontWeight.w600,
                    fontSize: w * 0.04,
                  )),
              SizedBox(height: h * 0.04),
              Text(
                "Upload a single message or an entire chat thread — and our AI reveals the hidden psychology behind every line.",
                style: WFTextStyles.bodyLarge.copyWith(
                  color: WFColors.gray300,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  fontSize: w * 0.035,
                ),
              ),
              SizedBox(height: h * 0.03),
              const _Bullet(
                  "🎭 Reveals the real tone — charm, control, sincerity, or manipulation."),
              const _Bullet(
                  "⚖️ Maps the power balance — who’s leading, who’s chasing."),
              const _Bullet(
                  "💔 Exposes emotional tactics — how they try to make you feel."),
              const _Bullet(
                  "🔥 Crafts your upgraded reply — seductive, assertive, or calm power."),
              SizedBox(height: h * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

/* --------------------------- POWER + FINISH --------------------------- */
// (Your _PowerSlide and _FinishSlide remain exactly as before)

/* ──────────────────────── HELPER WIDGETS ──────────────────────── */
class _ImageGrid extends StatelessWidget {
  final List<String> assetPaths;
  const _ImageGrid({required this.assetPaths});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: assetPaths.length,
      itemBuilder: (_, i) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(assetPaths[i], fit: BoxFit.cover),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: WFTextStyles.bodyMedium.copyWith(
                color: WFColors.gray300,
                fontSize: w * 0.033,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
