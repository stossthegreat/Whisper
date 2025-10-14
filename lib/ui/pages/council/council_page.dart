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

// BEGUILE AI — COUNCIL ARENA
// Matches the exact React prototype functionality and styling

class CouncilPage extends ConsumerStatefulWidget {
  const CouncilPage({super.key});

  @override
  ConsumerState<CouncilPage> createState() => _CouncilPageState();
}

class _CouncilPageState extends ConsumerState<CouncilPage>
    with TickerProviderStateMixin {
  String selectedMode = 'rizz';
  int age = 24;
  double tone = 50.0;
  final TextEditingController _inputController = TextEditingController();
  List<CouncilResponse> responses = [];
  Mentor? winner;
  String echo = '';
  bool isPlaying = false;
  bool _hasText = false;
  String? errorMessage;
  List<dynamic> verdicts = [];

  late AnimationController _animationController;

  final Map<String, ModeAccent> modeAccents = {
    'rizz': ModeAccent(0xFFEC4899, 0xFFF472B6, 0xFFFDA4AF),
    'seduction': ModeAccent(0xFFDC2626, 0xFFFB923C, 0xFFFDE68A),
    'power': ModeAccent(0xFF10B981, 0xFFF59E0B, 0xFF34D399),
    'analysis': ModeAccent(0xFF8B5CF6, 0xFF06B6D4, 0xFFA78BFA),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );
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
    _animationController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _summonCouncil() async {
    if (_inputController.text.trim().isEmpty || isPlaying) return;

    print("🔥 Calling Council endpoint...");
    
    if (mounted) {
      setState(() {
        isPlaying = true;
        errorMessage = null;
        verdicts = [];
        responses.clear();
        winner = null;
        echo = '';
      });
    }

    try {
      // Call the real Beguile API
      final response = await BeguileApi.council(
        mode: selectedMode,
        age: age,
        tone: tone.round(),
        scenario: _inputController.text.trim(),
      );

      print("✅ Response: $response");

      // Process the transcript from API response
      final transcript = response['transcript'] as List? ?? [];
      
      // Flatten the transcript if it's nested (handle malformed API responses)
      final flatTranscript = <Map<String, dynamic>>[];
      for (final item in transcript) {
        if (item is Map<String, dynamic>) {
          if (item.containsKey('mentorId')) {
            // Direct mentor response
            flatTranscript.add(item);
          } else if (item.containsKey('transcript') && item['transcript'] is List) {
            // Nested transcript - flatten it
            final nested = item['transcript'] as List;
            for (final nestedItem in nested) {
              if (nestedItem is Map<String, dynamic> && nestedItem.containsKey('mentorId')) {
                flatTranscript.add(nestedItem);
              }
            }
          }
        }
      }
      
      if (mounted) {
        setState(() {
          verdicts = flatTranscript;
        });
      }
      
      // Add each mentor response with animation delay
      for (int i = 0; i < flatTranscript.length; i++) {
        await Future.delayed(const Duration(milliseconds: 950));
        
        final mentorData = flatTranscript[i];
        final backendMentorId = mentorData['mentorId'] as String? ?? 'casanova';
        final mentorId = _mapMentorId(backendMentorId);
        final mentor = _councilMentors.firstWhere(
          (m) => m.id == mentorId,
          orElse: () => _councilMentors.first,
        );
        
        if (mounted) {
          setState(() {
            responses.add(CouncilResponse(
              id: '${mentorId}-${DateTime.now().millisecondsSinceEpoch}',
              mentorId: mentorId,
              text: mentorData['text'] as String? ?? 'Strategic insight...',
            ));
          });
        }
      }

      await Future.delayed(const Duration(milliseconds: 700));
      
      // Set winner from API response
      final winnerData = response['winner'] as Map<String, dynamic>? ?? {};
      final backendWinnerId = winnerData['id'] as String? ?? 'casanova';
      final winnerId = _mapMentorId(backendWinnerId);
      final winnerMentor = _councilMentors.firstWhere(
        (m) => m.id == winnerId,
        orElse: () => _councilMentors.first,
      );
      
      if (mounted) {
        setState(() {
          winner = winnerMentor;
          echo = response['echo'] as String? ?? _craftEcho();
          isPlaying = false;
        });
      }

      if (transcript.isEmpty) {
        print("⚠️ No council replies returned");
      } else {
        print("⚡ Rendering ${transcript.length} responses");
      }
    } catch (e) {
      print("❌ Council API error: $e");
      if (mounted) {
        setState(() {
          isPlaying = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  String _craftLine(Mentor mentor, String prevText) {
    final harsh = tone > 66;
    final gentle = tone < 33;
    
    String tune(String soft, String hard) {
      if (harsh) return hard;
      if (gentle) return soft;
      return '$soft $hard';
    }

    String react(String base) {
      if (prevText.isEmpty) return base;
      final nudges = [
        'I agree with the thrust—refine it:',
        'Build on that, but sharper:',
        'Counterpoint—same outcome, different path:',
        'Correction—keep the spirit, change the tactic:',
      ];
      final nudge = nudges[Random().nextInt(nudges.length)];
      return '$nudge $base';
    }

    switch (selectedMode) {
      case 'rizz':
        final options = [
          'Trouble looks good on us.',
          'You give main-character energy.',
          'Coffee or chaos?'
        ];
        return react(tune('Keep it playful:', 'One line, no chase:') + 
            ' "${options[Random().nextInt(options.length)]}"');
      case 'seduction':
        return react('Seduce rhythm, not words: pull back after warmth. Leave a hook they feel.');
      case 'power':
        return react('Withdraw to raise price. Strike once, clean.');
      case 'analysis':
        return react('Identify tactics, deny fuel, exit loops.');
      default:
        return '…';
    }
  }

  Mentor _pickWinner() {
    final favorites = {
      'rizz': 'casanova',
      'seduction': 'cleopatra',
      'power': 'machiavelli',
      'analysis': 'marcus_aurelius',
    };
    final favoriteId = favorites[selectedMode] ?? 'casanova';
    return _councilMentors.firstWhere(
      (m) => m.id == favoriteId,
      orElse: () => _councilMentors.first,
    );
  }

  // Council-specific mentors (includes Monroe for backend compatibility)
  static final List<Mentor> _councilMentors = [
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

  // Map backend mentor IDs to frontend mentor IDs
  String _mapMentorId(String backendId) {
    final mapping = {
      'sun_tzu': 'sun_tzu',
      'machiavelli': 'machiavelli', 
      'casanova': 'casanova',
      'aurelius': 'marcus_aurelius',
      'cleopatra': 'cleopatra',
      'monroe': 'monroe', // Keep Monroe for Council tab (backend expects Monroe)
    };
    return mapping[backendId] ?? backendId;
  }

  String _craftEcho() {
    final lines = {
      'rizz': 'Desire answers to rhythm, not volume.',
      'seduction': 'Be felt more than seen; scarcity is spellcraft.',
      'power': 'Own the frame; price your presence.',
      'analysis': 'Name the tactic, starve the loop.',
    };
    final endings = [
      'Victory favors restraint.',
      'Mystery moves markets.',
      'Clarity compels compliance.'
    ];
    return '${lines[selectedMode]} ${endings[Random().nextInt(endings.length)]}';
  }

  void _insertSample() {
    _inputController.text = 'She left me on read after I suggested a plan.';
  }

  @override
  Widget build(BuildContext context) {
    final accent = modeAccents[selectedMode]!;
    
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
                  subtitle: 'COUNCIL ARENA',
                ),
                const SizedBox(height: 24),
                _buildModeSelector(accent),
                const SizedBox(height: 20),
                _buildPersonalizationPanel(),
                const SizedBox(height: 20),
                _buildInputSection(accent),
                const SizedBox(height: 20),
                if (isPlaying) 
                  const LoadingStateWidget(message: "🔮 Summoning the Council...")
                else if (errorMessage != null) 
                  ErrorStateWidget(error: errorMessage!)
                else if (responses.isEmpty && verdicts.isEmpty) 
                  const EmptyStateWidget(text: "No responses yet")
                else if (responses.isNotEmpty) ...[
                  _buildCouncilFeed(),
                  const SizedBox(height: 20),
                ],
                if (winner != null) _buildWinnerCard(),
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
                const Text(
                  'COUNCIL ARENA',
                  style: TextStyle(
                    fontSize: 10,
                    color: WFColors.textTertiary,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(ModeAccent accent) {
    return GlassCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildModeChip('💋 Rizz', 'rizz'),
          _buildModeChip('🔥 Seduction', 'seduction'),
          _buildModeChip('⚡ Power', 'power'),
          _buildModeChip('🧠 Analysis', 'analysis'),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, String mode) {
    final isActive = selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? WFColors.glassMedium : WFColors.glassLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? WFColors.glassBorder.withOpacity(0.4) : WFColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, color: WFColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildPersonalizationPanel() {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Age',
                      style: TextStyle(fontSize: 12, color: WFColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: WFColors.glassBorder),
                      ),
                      child: TextField(
                        style: const TextStyle(color: WFColors.textPrimary),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: age.toString(),
                          hintStyle: const TextStyle(color: WFColors.textTertiary),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          final newAge = int.tryParse(value);
                          if (newAge != null && newAge >= 16 && newAge <= 80) {
                            setState(() => age = newAge);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tone: ${tone < 33 ? "Gentle" : tone > 66 ? "Harsh" : "Balanced"}',
                      style: const TextStyle(fontSize: 12, color: WFColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: WFColors.primary,
                        inactiveTrackColor: WFColors.glassBorder,
                        thumbColor: WFColors.primary,
                        overlayColor: WFColors.primary.withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: tone,
                        min: 0,
                        max: 100,
                        onChanged: (value) => setState(() => tone = value),
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

  Widget _buildInputSection(ModeAccent accent) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Scenario',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            height: 128,
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
                hintText: 'Describe the situation or paste messages…',
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
                    gradient: LinearGradient(
                      colors: [Color(accent.from), Color(accent.via), Color(accent.to)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(accent.from).withOpacity(0.6),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: (_hasText && !isPlaying) ? _summonCouncil : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      '🧠 Summon Council',
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

  Widget _buildCouncilFeed() {
    return Column(
      children: responses.map((response) {
        final mentorId = _mapMentorId(response.mentorId);
        final mentor = _councilMentors.firstWhere(
          (m) => m.id == mentorId,
          orElse: () => _councilMentors.first, // Safe fallback
        );
        return _buildMentorResponse(mentor, response);
      }).toList(),
    );
  }

  Widget _buildMentorResponse(Mentor mentor, CouncilResponse response) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WFColors.glassLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WFColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(int.parse('0xFF${mentor.color[0].substring(1)}')).withOpacity(0.2),
                  border: Border.all(
                    color: Color(int.parse('0xFF${mentor.color[0].substring(1)}')).withOpacity(0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    mentor.avatar,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(int.parse('0xFF${mentor.color[0].substring(1)}')),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                mentor.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(int.parse('0xFF${mentor.color[0].substring(1)}')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            response.text,
            style: const TextStyle(
              fontSize: 14,
              color: WFColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildActionButton('📋 Copy', () => _copyResponse(mentor, response)),
              const SizedBox(width: 8),
              _buildActionButton('📸 Share', () => _shareResponse()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard() {
    if (winner == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WFColors.glassLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: WFColors.glassBorder, width: 2),
      ),
      child: Stack(
        children: [
          // Winner glow
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(int.parse('0xFF${winner!.color[0].substring(1)}')).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: WFColors.glassLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: WFColors.glassBorder),
                ),
                child: Text(
                  'COUNCIL VERDICT • ${selectedMode.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.2,
                    color: WFColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Text(winner!.avatar, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Winner: ${winner!.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(int.parse('0xFF${winner!.color[0].substring(1)}')),
                          ),
                        ),
                        Text(
                          winner!.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: WFColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Metrics
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: WFColors.glassBorder),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildMetric('🧠 Dominance', '94 %')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMetric('💋 Charm', 
                        selectedMode == 'rizz' || selectedMode == 'seduction' ? '92 %' : '68 %')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMetric('✨ Clarity', '88 %')),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              _buildGradientDivider(),
              const SizedBox(height: 16),
              
              Text(
                '"$echo"',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: WFColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  _buildActionButton('📋 Copy Verdict', () => _copyVerdict()),
                  const SizedBox(width: 12),
                  _buildActionButton('📸 Share', () => _shareVerdict(), isPrimary: true),
                ],
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
              color: winner != null 
                  ? Color(int.parse('0xFF${winner!.color[0].substring(1)}'))
                  : WFColors.primary,
            ),
          ),
        ],
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
            winner != null 
                ? Color(int.parse('0xFF${winner!.color[0].substring(1)}')).withOpacity(0.6)
                : WFColors.primary.withOpacity(0.6),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? WFColors.buttonGradient[0].withOpacity(0.8) : WFColors.glassMedium,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: WFColors.textPrimary),
        ),
      ),
    );
  }

  void _copyResponse(Mentor mentor, CouncilResponse response) {
    final text = '${mentor.avatar} ${mentor.name}\n"${response.text}"\n\n— Beguile AI Council';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${mentor.name}\'s response!'),
        backgroundColor: WFColors.purple400,
      ),
    );
  }

  void _shareResponse() {
    if (responses.isEmpty) return;
    final allResponses = responses.map((r) {
      final mentorId = _mapMentorId(r.mentorId);
      final mentor = _councilMentors.firstWhere(
        (m) => m.id == mentorId,
        orElse: () => _councilMentors.first,
      );
      return '${mentor.avatar} ${mentor.name}: "${r.text}"';
    }).join('\n\n');
    
    final text = '🧠 Beguile AI Council Debate\n\n$allResponses\n\n— Beguile AI';
    Share.share(text);
  }

  void _copyVerdict() {
    if (winner == null) return;
    final text = '🏆 Council Winner: ${winner!.avatar} ${winner!.name}\n\n"$echo"\n\n— Beguile AI Council';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied verdict to clipboard!'),
        backgroundColor: WFColors.purple400,
      ),
    );
  }

  void _shareVerdict() {
    if (winner == null) return;
    final text = '🏆 Council Winner: ${winner!.avatar} ${winner!.name}\n\n"$echo"\n\n— Beguile AI Council';
    Share.share(text);
  }
}

// Data models
class CouncilResponse {
  final String id;
  final String mentorId;
  final String text;

  CouncilResponse({
    required this.id,
    required this.mentorId,
    required this.text,
  });
}

class ModeAccent {
  final int from;
  final int via;
  final int to;

  ModeAccent(this.from, this.via, this.to);
}
