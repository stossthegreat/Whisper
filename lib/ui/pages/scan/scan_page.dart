import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

import '../../../core/theme/theme.dart';
import '../../../data/services/constants.dart';
import '../../../data/models/mentor_models.dart';
import '../../../services/beguile_api.dart';
import '../../../widgets/tab_header.dart';
import '../../../widgets/state_widgets.dart';
import '../../atoms/glass_card.dart';

// BEGUILE AI — SCAN TAB
// Matches the exact React prototype functionality and styling

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  // Scan-specific mentors (includes Monroe for backend compatibility)
  static final List<Mentor> _scanMentors = [
    ...MentorConstants.mentors.where((m) => m.id != 'churchill'), // All except Churchill
    const Mentor(
      id: 'monroe',
      name: 'Marilyn Monroe',
      subtitle: 'Magnetic Charm',
      avatar: '🌹',
      description: 'Control the spotlight—never chase it',
      color: ['#FF99C8', '#F472B6'], // soft pink to fuchsia
      greeting: 'Darling, I am Marilyn Monroe. They only see what you show them. Softness can be armor when you choose it. Charm quietly—power doesn\'t need volume.',
      presets: ['drill', 'advise', 'roleplay', 'chat'],
    ),
  ];

  Mentor selectedMentor = _scanMentors[0];
  String perspective = 'you'; // 'you' | 'them'
  final TextEditingController _inputController = TextEditingController();
  ScanResult? result;
  bool isScanning = false;
  bool _hasText = false;
  String? errorMessage;
  List<dynamic> verdicts = [];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      final hasText = _inputController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  final List<PowerMove> powerMovesYou = [
    PowerMove('⚔️', 'Frame Control', 'You set terms calmly and didn\'t chase.'),
    PowerMove('🧊', 'Strategic Silence', 'You let tension expose the truth.'),
    PowerMove('💎', 'Scarcity Signal', 'You valued time; desire rose.'),
    PowerMove('🎯', 'Reality Reframe', 'You renamed the moment—and won.'),
    PowerMove('🛡️', 'Boundary', 'You drew a line without apology.'),
  ];

  final List<PowerMove> powerMovesThem = [
    PowerMove('😈', 'Gaslight Attempt', 'They twisted facts to shift blame.'),
    PowerMove('🧵', 'Guilt Thread', 'They tried weaving debt you never owed.'),
    PowerMove('🕴️', 'Triangulation', '\'Everyone thinks…\' to box you in.'),
    PowerMove('🎭', 'Projection', 'Accused you of what they did.'),
    PowerMove('🔮', 'Future-Faking', 'Promises as bait, not plan.'),
  ];

  final List<String> tags = [
    'Gaslighting', 'Triangulation', 'Guilt Trip', 'Projection', 'Future Faking', 'Stonewalling'
  ];

  final List<String> quotes = [
    'Power respects power. You proved yours.',
    'They played checkers. You played 4D chess.',
    'Composure is a weapon; you used it well.',
    'Presence prices access. You set the tariff.',
  ];

  Future<void> _runScan() async {
    if (_inputController.text.trim().isEmpty || isScanning) return;

    print("🔥 Calling Scan endpoint...");
    
    if (mounted) {
      setState(() {
        isScanning = true;
        errorMessage = null;
        verdicts = [];
        result = null;
      });
    }

    try {
      // Call the real Beguile API
      final response = await BeguileApi.scan(
        text: _inputController.text.trim(),
        perspective: perspective == 'you' ? 'you' : 'them',
        mentorId: selectedMentor.id,
      );

      print("✅ Response: $response");

      // Convert API response to UI model
      final moves = (response['points'] as List?)
          ?.map((p) => PowerMove(
                p['emoji'] ?? '⚡',
                p['title'] ?? 'Power Move',
                p['text'] ?? 'Strategic insight',
              ))
          .toList() ?? [];

      final selectedTags = (response['tags'] as List?)
          ?.map((t) => t.toString())
          .toList() ?? [];

      final verdictsData = response['points'] as List? ?? [];

      if (mounted) {
        setState(() {
          isScanning = false;
          verdicts = verdictsData;
          result = ScanResult(
            score: (response['score'] as num?)?.toInt() ?? 85,
            verdict: _generateVerdict(response),
            moves: moves.take(3).toList(),
            tags: selectedTags.take(6).toList(),
            quote: response['quote']?.toString() ?? 'Power respects power.',
          );
        });
      }

      if (verdictsData.isEmpty) {
        print("⚠️ No results returned");
      } else {
        print("⚡ Rendering ${verdictsData.length} verdicts");
      }
    } catch (e) {
      print("❌ Scan API error: $e");
      if (mounted) {
        setState(() {
          isScanning = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  String _generateVerdict(Map<String, dynamic> response) {
    // Use API response or generate based on perspective
    if (response['mentor'] != null) {
      final mentorName = response['mentor']['name'] ?? selectedMentor.name;
      return perspective == 'you'
          ? 'You held frame; silence became your sword.'
          : 'They masked control as care. Pattern exposed.';
    }
    return perspective == 'you'
        ? 'You held frame; silence became your sword.'
        : 'They masked control as care. Pattern exposed.';
  }

  void _insertSample() {
    _inputController.text = 
        "I'm not mad, just disappointed. Everyone thinks you're being difficult. "
        "After everything I've done for you… Let's be rational; you're overreacting.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WFColors.base,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [WFColors.baseGradientStart, WFColors.baseGradientMid, WFColors.baseGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TabHeader(
                  title: 'Beguile AI',
                  subtitle: 'SCAN',
                ),
                const SizedBox(height: 24),
                _buildMentorSelector(),
                const SizedBox(height: 20),
                _buildPerspectiveToggle(),
                const SizedBox(height: 20),
                _buildInputSection(),
                const SizedBox(height: 20),
                if (isScanning) 
                  const LoadingStateWidget(message: "🧠 Analyzing message...")
                else if (errorMessage != null) 
                  ErrorStateWidget(error: errorMessage!)
                else if (result == null && verdicts.isEmpty) 
                  const EmptyStateWidget(text: "No verdicts yet")
                else if (result != null) ...[
                  _buildVerdictCard(),
                  const SizedBox(height: 20),
                  _buildShareCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: WFColors.glassLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WFColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: WFColors.buttonGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(child: Text('🔮', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: WFColors.beguileGradient,
                  ).createShader(bounds),
                  child: const Text(
                    'Beguile AI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Removed Mars edition tag per branding update
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: WFColors.glassMedium,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WFColors.glassBorder),
            ),
            child: const Text(
              '🪐 Live',
              style: TextStyle(fontSize: 12, color: WFColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorSelector() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Mentor',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _scanMentors.length,
            itemBuilder: (context, index) {
              final mentor = _scanMentors[index];
              final isSelected = selectedMentor.id == mentor.id;
              
              return GestureDetector(
                onTap: () => setState(() => selectedMentor = mentor),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? WFColors.glassMedium : WFColors.glassLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? Color(int.parse('0xFF${mentor.color[0].substring(1)}'))
                          : WFColors.glassBorder,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Color(int.parse('0xFF${mentor.color[0].substring(1)}')).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                  transform: isSelected ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mentor.avatar, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        mentor.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(int.parse('0xFF${mentor.color[0].substring(1)}')),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        mentor.subtitle,
                        style: const TextStyle(
                          fontSize: 9,
                          color: WFColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildPerspectiveToggle() {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Analyze Perspective',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Row(
            children: [
              _buildToggleChip('🧍 You', perspective == 'you', () => setState(() => perspective = 'you')),
              const SizedBox(width: 8),
              _buildToggleChip('🕴️ Them', perspective == 'them', () => setState(() => perspective = 'them')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? WFColors.glassMedium : WFColors.glassLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? WFColors.glassBorder.withOpacity(0.4) : WFColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, color: WFColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Psy‑Ops Scan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WFColors.glassBorder),
            ),
            child: TextField(
              controller: _inputController,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: WFColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Paste messages here…',
                hintStyle: TextStyle(color: WFColors.textTertiary),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: WFColors.buttonGradient),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: WFColors.buttonGradient[0].withOpacity(0.6),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: (_hasText && !isScanning) ? _runScan : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '⚡ Run Deep Scan',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _insertSample,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: WFColors.glassMedium,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Sample',
                    style: TextStyle(color: WFColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerdictCard() {
    if (result == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WFColors.glassLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: WFColors.glassBorder, width: 2),
      ),
      child: Stack(
        children: [
          // Mentor glow
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(int.parse('0xFF${selectedMentor.color[0].substring(1)}')).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PSY-OPS header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: WFColors.glassLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: WFColors.glassBorder),
                ),
                child: Text(
                  'PSY‑OPS REPORT • CASE‑${1000 + Random().nextInt(8999)}',
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.2,
                    color: WFColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Mentor info and verdict
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedMentor.avatar} ${selectedMentor.name} • ${selectedMentor.subtitle}',
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 2.2,
                            color: WFColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFFD1A6), Color(0xFFFFB3A1), Color(0xFFF6A3FF)],
                          ).createShader(bounds),
                          child: Text(
                            result!.verdict,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    selectedMentor.avatar,
                    style: TextStyle(
                      fontSize: 48,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Score block
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: WFColors.glassBorder),
                ),
                child: Column(
                  children: [
                    const Text(
                      'PSYCHOLOGICAL DOMINANCE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: WFColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFFD1A6), Color(0xFFFFB3A1), Color(0xFFF6A3FF)],
                          ).createShader(bounds),
                          child: Text(
                            '${result!.score}',
                            style: const TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Text(
                          '/100',
                          style: TextStyle(
                            fontSize: 30,
                            color: WFColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(int.parse('0xFF${selectedMentor.color[0].substring(1)}')).withOpacity(0.6),
                        ),
                      ),
                      child: Text(
                        'ELITE TIER',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(int.parse('0xFF${selectedMentor.color[0].substring(1)}')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Mini metrics
              Row(
                children: [
                  Expanded(child: _buildMetric('🧠 Control Ratio', '82 %')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetric('💎 Emotional Balance', '76 %')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetric('⚡ Tempo', 'Stable')),
                ],
              ),
              
              const SizedBox(height: 16),
              _buildGradientDivider(),
              const SizedBox(height: 16),
              
              // Power moves
              const Text(
                '⚡ POWER MOVES',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.0,
                  color: WFColors.textTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...result!.moves.map((move) => _buildPowerMoveCard(move)),
              
              const SizedBox(height: 16),
              _buildGradientDivider(),
              const SizedBox(height: 16),
              
              // Tactics
              const Text(
                '🚨 TACTICS DETECTED',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.0,
                  color: WFColors.textTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result!.tags.map((tag) => _buildTacticTag(tag)).toList(),
              ),
              
              const SizedBox(height: 16),
              _buildGradientDivider(),
              const SizedBox(height: 16),
              
              // Quote
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(int.parse('0xFF${selectedMentor.color[0].substring(1)}')),
                    width: 4,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedMentor.name} says',
                      style: const TextStyle(
                        fontSize: 12,
                        color: WFColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${result!.quote}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: WFColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WFColors.glassBorder),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: WFColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(int.parse('0xFF${selectedMentor.color[0].substring(1)}')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerMoveCard(PowerMove move) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WFColors.glassBorder),
      ),
      child: Row(
        children: [
          Text(move.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  move.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: WFColors.textPrimary,
                  ),
                ),
                Text(
                  move.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: WFColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTacticTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(int.parse('0xFF${selectedMentor.color[0].substring(1)}')).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(int.parse('0xFF${selectedMentor.color[0].substring(1)}')).withOpacity(0.5),
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 12,
          color: WFColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildGradientDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(int.parse('0xFF${selectedMentor.color[0].substring(1)}')).withOpacity(0.6),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildShareCard() {
    if (result == null) return const SizedBox();

    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color(int.parse('0xFF${selectedMentor.color[0].substring(1)}')).withOpacity(0.6),
              width: 2,
            ),
            gradient: const LinearGradient(
              colors: [Color(0xE6141416), Color(0xEB120E12)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Text(
                '${selectedMentor.avatar} ${selectedMentor.name} • ${perspective.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.2,
                  color: WFColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result!.verdict,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(int.parse('0xFF${selectedMentor.color[0].substring(1)}')),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFD1A6), Color(0xFFFFB3A1), Color(0xFFF6A3FF)],
                    ).createShader(bounds),
                    child: Text(
                      '${result!.score}',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Text(
                    '/100',
                    style: TextStyle(
                      fontSize: 20,
                      color: WFColors.textMuted,
                    ),
                  ),
                ],
              ),
              const Text(
                'ELITE TIER • FRAME MASTERY',
                style: TextStyle(
                  fontSize: 11,
                  color: WFColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ...result!.moves.map((move) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(move.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: WFColors.textPrimary),
                          children: [
                            TextSpan(
                              text: move.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(text: ' — '),
                            TextSpan(
                              text: move.description,
                              style: const TextStyle(color: WFColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              const Text(
                'Beguile AI • Mars Edition',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: WFColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton('📋 Copy Text', () => _copyText()),
            const SizedBox(width: 12),
            _buildActionButton('📸 Save Card', () => _saveCard(), isPrimary: true),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? WFColors.buttonGradient[0].withOpacity(0.8) : WFColors.glassMedium,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: WFColors.textPrimary),
        ),
      ),
    );
  }

  void _copyText() {
    if (result == null) return;
    final lines = result!.moves.map((m) => '${m.emoji} ${m.title} — ${m.description}').join('\n');
    final text = '${selectedMentor.avatar} ${selectedMentor.name} — ${perspective == 'you' ? 'Your' : 'Their'} Verdict\n'
        '"${result!.verdict}"\n\n'
        '🧠 ${result!.score}/100 • ELITE TIER\n\n'
        '$lines\n\n'
        '💬 "${result!.quote}"\n\n'
        'Beguile AI';
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        backgroundColor: WFColors.purple400,
      ),
    );
  }

  void _saveCard() {
    if (result == null) return;
    final lines = result!.moves.map((m) => '${m.emoji} ${m.title} — ${m.description}').join('\n');
    final text = '${selectedMentor.avatar} ${selectedMentor.name} — ${perspective == 'you' ? 'Your' : 'Their'} Verdict\n'
        '"${result!.verdict}"\n\n'
        '🧠 ${result!.score}/100 • ELITE TIER\n\n'
        '$lines\n\n'
        '💬 "${result!.quote}"\n\n'
        'Beguile AI';
    
    Share.share(text);
  }
}

// Data models
class ScanResult {
  final int score;
  final String verdict;
  final List<PowerMove> moves;
  final List<String> tags;
  final String quote;

  ScanResult({
    required this.score,
    required this.verdict,
    required this.moves,
    required this.tags,
    required this.quote,
  });
}

class PowerMove {
  final String emoji;
  final String title;
  final String description;

  PowerMove(this.emoji, this.title, this.description);
}
