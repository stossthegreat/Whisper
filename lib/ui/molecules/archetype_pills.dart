import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../atoms/atoms.dart';

class ArchetypePills extends StatelessWidget {
  final List<ArchetypeItem> archetypes;

  const ArchetypePills({
    super.key,
    required this.archetypes,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: WFDims.spacingS,
      runSpacing: WFDims.spacingS,
      children: archetypes.map((archetype) {
        final baseColor = _getArchetypeColor(archetype.weight);
        return Pill(
          text:
              '${_getArchetypeEmoji(archetype.label)} ${archetype.label} — ${archetype.weight}%',
          backgroundColor: baseColor.withOpacity(0.2),
          textColor: baseColor,
        );
      }).toList(),
    );
  }

  String _getArchetypeEmoji(String label) {
    switch (label.toLowerCase()) {
      case 'gaslighting':
      case 'gaslighter':
        return '🤡';
      case 'love bombing':
      case 'love bomber':
        return '💣';
      case 'darvo':
        return '⚔️';
      case 'triangulation':
        return '📐';
      case 'silent treatment':
        return '🤐';
      case 'hoovering':
        return '🌪️';
      case 'breadcrumbing':
        return '🍞';
      default:
        return '🦊';
    }
  }

  Color _getArchetypeColor(int weight) {
    if (weight >= 80) return WFColors.buttonGradient[0];
    if (weight >= 60) return const Color(0xFFF59E0B);
    return WFColors.purple400;
  }
}

class ArchetypeItem {
  final String label;
  final int weight;

  const ArchetypeItem({
    required this.label,
    required this.weight,
  });
}
