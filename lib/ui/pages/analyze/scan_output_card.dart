import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/whisperfire_models.dart';
import '../../../data/services/whisperfire_services.dart';
import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';

class ScanOutputCard extends StatelessWidget {
  final WhisperfireResponse result;
  final String original;
  const ScanOutputCard(
      {super.key, required this.result, required this.original});

  @override
  Widget build(BuildContext context) {
    final profileTag = WhisperfireServices.extractProfileTag(result);
    final whyBullets = _splitBullets(result.powerPlay);
    final principle = (result.counterIntervention ?? '').trim();

    return GlassCard(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopLine(
                tabLabel: '🔍 SCAN — ${_nickname(result.tactic.label)}',
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
                        onPressed: () => _shareScanAnalysis(result, original),
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

              // 1) 💥 Headline (TOP)
              _section('💥', 'Headline', result.headline),

              // 2) 📨 Message (you wrote)
              _section('📨', 'Message (you wrote)', original),

              // 3) 💀 What actually happened (plain English)
              _section('💀', 'What actually happened', result.coreTake),

              // 4) ⚠️ Mistake (use motives if it carries the failure idea, else fallback)
              if (result.motives.trim().isNotEmpty)
                _section('⚠️', 'Mistake', result.motives),

              // 5) 🔥 What you should've said (one lethal line or first line)
              _section('🔥', 'What you should\'ve said',
                  _oneLine(result.suggestedReply.text)),

              // 6) ✨ Why it works (3–5 bullets from power_play)
              if (whyBullets.isNotEmpty)
                _bullets('✨', 'Why it works', whyBullets),

              // 7) 🚀 Principle for next time (counter_intervention)
              if (principle.isNotEmpty)
                _section('🚀', 'Principle for next time', principle),

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

  // ——— helpers ———

  void _shareScanAnalysis(WhisperfireResponse result, String original) {
    final shareText = '''
🔍 SCAN ANALYSIS

${result.headline}

📨 You wrote:
$original

💀 What happened:
${result.coreTake}

⚠️ Mistake:
${result.motives}

🔥 Rewrite:
${_oneLine(result.suggestedReply.text)}

✨ Why it works:
${_splitBullets(result.powerPlay).join('\n• ')}

🚀 Principle:
${result.counterIntervention ?? ''}

Powered by Beguile AI 🚀
''';

    // Use Flutter's share functionality
    Share.share(shareText, subject: 'Scan Analysis - Beguile AI');
  }

  String _nickname(String label) {
    switch (label.toLowerCase()) {
      case 'gaslighting':
        return 'Gaslight Gourmet';
      case 'love bombing':
        return 'Love Bomber';
      case 'darvo':
        return 'DARVO Master';
      case 'triangulation':
        return 'Triangle Architect';
      case 'silent treatment':
        return 'Silent Assassin';
      case 'hoovering':
        return 'Hoover Hero';
      case 'breadcrumbing':
        return 'Breadcrumb Baker';
      case 'none detected':
        return 'Clean Scan';
      default:
        return 'Pattern Detected';
    }
  }

  List<String> _splitBullets(String block) {
    final lines = block
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return lines.take(5).toList();
  }

  String _oneLine(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

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
        ...items.map((b) => Padding(
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
                      b,
                      style: WFTextStyles.bodyMedium.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: WFDims.sectionSpacing),
      ],
    );
  }
}
