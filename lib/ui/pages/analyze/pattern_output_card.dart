import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/whisperfire_models.dart';
import '../../../data/services/whisperfire_services.dart';
import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';

class PatternOutputCard extends StatelessWidget {
  final WhisperfireResponse result;
  const PatternOutputCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final profileTag = WhisperfireServices.extractProfileTag(result);
    final receipts = WhisperfireServices.getReceipts(result, 'pattern');

    final snapshot = receipts.take(8).toList(); // 🧵 Thread Snapshot
    final critical = _criticalMoments(result); // 💣 Critical Moments
    final psych = _psychProfile(result); // 🧠 Psych Profile (with explanation)
    final frameLedger = result.pattern?.cycle?.trim().isNotEmpty == true
        ? result.pattern!.cycle!
        : '';

    final fixes = _precisionFixes(result); // 🎯 Precision Fixes (why+how)
    final recovery = _lines(result.nextMoves, max: 6); // 🔄 Recovery Protocol
    final principle = (result.counterIntervention ?? '').trim();
    final hidden = (result.hiddenAgenda?.trim().isNotEmpty ?? false)
        ? result.hiddenAgenda!.trim()
        : (result.longGame?.trim() ?? '');

    return GlassCard(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopLine(
                tabLabel:
                    '🕵️‍♀️ PATTERN — ${_archetypeNickname(result.tactic.label)}',
                profileTag: profileTag,
                rightWidget: Column(
                  children: [
                    // Share button - top right
                    Container(
                      decoration: BoxDecoration(
                        color: WFColors.purple400.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => _sharePatternAnalysis(result),
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                        tooltip: 'Share Analysis',
                      ),
                    ),
                  ],
                ),
              ),

              // 1) 💥 Headline
              _section('💥', 'Headline', result.headline),

              // 2) 🧵 Thread Snapshot (compact, no walls)
              if (snapshot.isNotEmpty)
                _bullets('🧵', 'Thread Snapshot', snapshot),

              // 3) 💣 Critical Moments
              if (critical.isNotEmpty)
                _bullets('💣', 'Critical Moments', critical),

              // 4) 🧠 Psych Profile (with plain-English explanation)
              _section('🧠', 'Psych Profile', psych),

              // 7) 🎯 Precision Fixes
              if (fixes.isNotEmpty) _bullets('🎯', 'Precision Fixes', fixes),

              // 8) 🔄 Recovery Protocol
              if (recovery.isNotEmpty)
                _bullets('🔄', 'Recovery Protocol', recovery),

              // 9) 📜 Principle to Keep
              _section('📜', 'Principle to Keep', principle),

              // 10) 🔍 Hidden Agenda Scan
              if (hidden.isNotEmpty)
                _section('🔍', 'Hidden Agenda Scan', hidden),

              // 11) 💬 Boundary Script (final message to send)
              _script(result.suggestedReply.text),

              // Add spacing before the logo
              const SizedBox(height: 60),
            ],
          ),

          // Beguile AI logo - positioned at the very bottom
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [WFColors.purple400, WFColors.purple600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '🔮',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Beguile AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- helpers ----------
  List<String> _criticalMoments(WhisperfireResponse r) {
    // Prefer contradictions if present; otherwise derive from prognosis arrows.
    if ((r.contradictions ?? []).isNotEmpty) {
      return r.contradictions!.take(3).toList();
    }
    final p = r.pattern?.prognosis ?? '';
    if (p.contains('→')) {
      return p
          .split('→')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(3)
          .toList();
    }
    return [];
  }

  String _psychProfile(WhisperfireResponse r) {
    final youArch = (r.archetypes ?? []).isNotEmpty
        ? r.archetypes!.map((a) => a.label).take(2).join(' / ')
        : 'Frame battler';
    final them = r.tactic.label;
    final role = r.targeting.isNotEmpty ? ' • ${r.targeting}' : '';

    // Two-layer: identity read + plain-English explanation
    final read = 'You: $youArch • Them: $them$role';
    final explain = (r.motives.trim().isNotEmpty)
        ? '\nExplanation: ${r.motives.trim()}'
        : '';
    return '$read$explain';
  }

  List<String> _precisionFixes(WhisperfireResponse r) {
    // Use "power_play" bullets as fixes, but make them actionable.
    final lines = _lines(r.powerPlay, max: 5);
    return lines.map((e) {
      // Light verb‑forward rewrite cue
      if (!RegExp(r'^(Lead|Host|Close|Escalate|Answer|Set|Invite|Cut|Stop)\b',
              caseSensitive: false)
          .hasMatch(e)) {
        return 'Apply: $e';
      }
      return e;
    }).toList();
  }

  List<String> _lines(String block, {int max = 6}) => block
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .take(max)
      .toList();

  Widget _section(String emoji, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(emoji: emoji, title: title),
        const SizedBox(height: WFDims.titleBodySpacing),
        Text(
          content,
          style: WFTextStyles.bodyMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: WFDims.sectionSpacing),
      ],
    );
  }

  Widget _bullets(String emoji, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(emoji: emoji, title: title),
        const SizedBox(height: WFDims.titleBodySpacing),
        ...items.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin:
                      const EdgeInsets.only(top: 10, right: WFDims.spacingS),
                  decoration: BoxDecoration(
                    color: WFColors.purple400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Text(
                    t,
                    style: WFTextStyles.bodyMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: WFDims.sectionSpacing),
      ],
    );
  }

  Widget _script(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(emoji: '💬', title: 'Boundary Script'),
        const SizedBox(height: WFDims.titleBodySpacing),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(WFDims.paddingM),
          decoration: BoxDecoration(
            color: WFColors.gray800.withOpacity(0.3),
            borderRadius: BorderRadius.circular(WFDims.radiusSmall),
            border:
                Border(left: BorderSide(color: WFColors.purple400, width: 3)),
          ),
          child: Text(
            text.trim(),
            style: WFTextStyles.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: WFDims.sectionSpacing),
      ],
    );
  }

  String _archetypeNickname(String label) {
    switch (label.toLowerCase()) {
      case 'gaslighting':
        return 'Reality Distorter';
      case 'love bombing':
        return 'Emotional Bomber';
      case 'darvo':
        return 'Victim Flipper';
      case 'triangulation':
        return 'Drama Architect';
      case 'silent treatment':
        return 'Ice Wall Builder';
      case 'hoovering':
        return 'Vacuum Operator';
      case 'breadcrumbing':
        return 'Hope Dangler';
      case 'none detected':
        return 'Clean Pattern';
      default:
        return 'Pattern Master';
    }
  }

  void _sharePatternAnalysis(WhisperfireResponse result) {
    final shareText = '''
🕵️‍♀️ PATTERN ANALYSIS

${result.headline}

🧠 Psych Profile: ${_psychProfile(result)}
⚖️ Frame Ledger: ${result.pattern?.cycle ?? 'Frame shifts not fully mapped'}
📉 Error Chain: ${result.pattern?.prognosis ?? 'No explicit error chain'}
📜 Principle: ${result.counterIntervention ?? 'Begin Challenger, end Victor—never downgrade to Clerk.'}

💬 Boundary Script: ${result.suggestedReply.text}

Powered by Beguile AI 🚀
''';

    // Use Flutter's share functionality
    Share.share(shareText, subject: 'Pattern Analysis - Beguile AI');
  }
}
