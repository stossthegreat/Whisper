import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../atoms/glass_card.dart';
import '../../atoms/kicker.dart';
import '../../atoms/metric_bar.dart';
import '../../atoms/section_title.dart';
import '../../atoms/copy_line.dart';
import '../../atoms/pill.dart';
import '../../atoms/divider_faint.dart';
import '../../atoms/wf_icon_button.dart';
import '../../atoms/wf_primary_button.dart';
import '../../../widgets/app_header.dart';

class StylebookPage extends StatelessWidget {
  const StylebookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WFColors.base,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WFDims.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Glass Card Demo
            Text('Glass Card', style: WFTextStyles.h3),
            const SizedBox(height: WFDims.spacingS),
            GlassCard(
              child: Column(
                children: [
                  Text('Glass Card Example', style: WFTextStyles.h4),
                  const SizedBox(height: WFDims.spacingS),
                  Text(
                      'Glass panels: white 28–36% opacity + blur(18) + 1px border rgba(168,85,255,0.35)',
                      style: WFTextStyles.bodyMedium),
                ],
              ),
            ),

            const SizedBox(height: WFDims.spacingXL),

            // Kicker Demo
            Text('Kicker', style: WFTextStyles.h3),
            const SizedBox(height: WFDims.spacingS),
            const Kicker(text: 'scan mode'),

            const SizedBox(height: WFDims.spacingXL),

            // Metric Bar Demo
            Text('Metric Bar', style: WFTextStyles.h3),
            const SizedBox(height: WFDims.spacingS),
            GlassCard(
              child: Column(
                children: [
                  MetricBar(label: 'Red Flag', value: 85),
                  const SizedBox(height: WFDims.spacingM),
                  MetricBar(label: 'Certainty', value: 67),
                  const SizedBox(height: WFDims.spacingM),
                  MetricBar(label: 'Viral Potential', value: 42),
                ],
              ),
            ),

            const SizedBox(height: WFDims.spacingXL),

            // Section Title Demo
            Text('Section Title', style: WFTextStyles.h3),
            const SizedBox(height: WFDims.spacingS),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(emoji: '💥', title: 'Headline'),
                  const SizedBox(height: WFDims.titleBodySpacing),
                  Text('This is the content under the section title',
                      style: WFTextStyles.bodyMedium),
                  const SizedBox(height: WFDims.sectionSpacing),
                  SectionTitle(emoji: '🕵️', title: 'The Read'),
                  const SizedBox(height: WFDims.titleBodySpacing),
                  Text('Another section with proper spacing',
                      style: WFTextStyles.bodyMedium),
                ],
              ),
            ),

            const SizedBox(height: WFDims.spacingXL),

            // Copy Line Demo
            Text('Copy Line', style: WFTextStyles.h3),
            const SizedBox(height: WFDims.spacingS),
            GlassCard(
              child: CopyLine(text: 'This text can be copied to clipboard'),
            ),

            const SizedBox(height: WFDims.spacingXL),

            // Pills Demo
            Text('Pills', style: WFTextStyles.h3),
            const SizedBox(height: WFDims.spacingS),
            Wrap(
              spacing: WFDims.spacingS,
              runSpacing: WFDims.spacingS,
              children: [
                Pill(text: '🦊 Gaslighting — 89%'),
                Pill(text: '🎭 Love Bombing — 67%'),
                Pill(text: '⚔️ DARVO — 45%'),
              ],
            ),

            const SizedBox(height: WFDims.spacingXL),

            // Divider Demo
            Text('Divider Faint', style: WFTextStyles.h3),
            const SizedBox(height: WFDims.spacingS),
            GlassCard(
              child: Column(
                children: [
                  Text('Content above divider', style: WFTextStyles.bodyMedium),
                  const DividerFaint(),
                  Text('Content below divider', style: WFTextStyles.bodyMedium),
                ],
              ),
            ),

            const SizedBox(height: WFDims.spacingXL),

            // Buttons Demo
            Text('Buttons', style: WFTextStyles.h3),
            const SizedBox(height: WFDims.spacingS),
            Row(
              children: [
                WFIconButton(
                  icon: Icons.copy,
                  onPressed: () {},
                  tooltip: 'Copy',
                ),
                const SizedBox(width: WFDims.spacingM),
                WFIconButton(
                  icon: Icons.share,
                  onPressed: () {},
                  tooltip: 'Share',
                ),
                const SizedBox(width: WFDims.spacingM),
                Expanded(
                  child: WFPrimaryButton(
                    text: 'Analyze',
                    icon: Icons.visibility,
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: WFDims.spacingM),

            WFPrimaryButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),

            const SizedBox(height: WFDims.spacingXXL),
          ],
        ),
      ),
    );
  }
}
