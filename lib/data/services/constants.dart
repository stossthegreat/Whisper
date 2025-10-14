import '../models/mentor_models.dart';
import '../models/whisperfire_models.dart';
import '../models/profile_models.dart';

class MentorConstants {
  // Fixed 6 mentors with exact names & taglines from spec
  static const List<Mentor> mentors = [
    Mentor(
      id: 'casanova',
      name: 'Casanova',
      subtitle: 'Master of Charm',
      avatar: '🎭',
      description: 'Understand charm tactics to defend against them',
      color: ['#EC4899', '#EF4444'], // pink-500 to red-500
      greeting:
          'Ah, my dear friend... I am Casanova. I will teach you the arts of charm - not to use, but to recognize when used against you. Knowledge is your shield.',
      presets: ['drill', 'advise', 'roleplay', 'chat'],
    ),
    Mentor(
      id: 'cleopatra',
      name: 'Cleopatra',
      subtitle: 'Queen of Influence',
      avatar: '👑',
      description: 'Recognize power plays and influence tactics',
      color: ['#F59E0B', '#EA580C'], // yellow-500 to orange-600
      greeting:
          'I am Cleopatra, Queen of Egypt. I commanded empires through influence. I will teach you to see through the veils of power and recognize when others seek to control you.',
      presets: ['drill', 'advise', 'roleplay', 'chat'],
    ),
    Mentor(
      id: 'machiavelli',
      name: 'Machiavelli',
      subtitle: 'Master of Strategy',
      avatar: '⚔️',
      description: 'Understand cunning to protect against it',
      color: ['#6B7280', '#EF4444'], // gray-500 to red-500
      greeting:
          'I am Niccolò Machiavelli. In the game of power, knowledge of cunning protects you from those who would use it against you. What strategy shall we analyze?',
      presets: ['drill', 'advise', 'roleplay', 'chat'],
    ),
    Mentor(
      id: 'sun_tzu',
      name: 'Sun Tzu',
      subtitle: 'Strategic Timing & Advantage',
      avatar: '⚔️',
      description: 'Know yourself and your opponent',
      color: ['#EF4444', '#EA580C'], // red-500 to orange-600
      greeting:
          'I am Sun Tzu. To defeat manipulation, you must know yourself and know your enemy. Every psychological battle is won before it begins. What strategy do you seek?',
      presets: ['drill', 'advise', 'roleplay', 'chat'],
    ),
    Mentor(
      id: 'marcus_aurelius',
      name: 'Marcus Aurelius',
      subtitle: 'Stoic Self-Command',
      avatar: '🏛️',
      description: 'Inner fortress of the mind',
      color: ['#8B5CF6', '#6366F1'], // purple-500 to indigo-500
      greeting:
          'I am Marcus Aurelius. True defense begins within. Build an unshakeable fortress of mind that no manipulation can breach. What troubles your inner peace?',
      presets: ['drill', 'advise', 'roleplay', 'chat'],
    ),
    Mentor(
      id: 'churchill',
      name: 'Winston Churchill',
      subtitle: 'Resolute Leadership',
      avatar: '🎖️',
      description: 'Stand firm against manipulation with unwavering resolve',
      color: ['#1F2937', '#374151'], // gray-800 to gray-700
      greeting:
          'I am Winston Churchill. In the darkest hour, resolve is your greatest weapon. Never give in to those who would break your spirit through manipulation.',
      presets: ['drill', 'advise', 'roleplay', 'chat'],
    ),
  ];

  static Mentor? getMentorById(String id) {
    try {
      return mentors.firstWhere((mentor) => mentor.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<String> get mentorIds => mentors.map((m) => m.id).toList();
  static List<String> get presetKeys => ['drill', 'advise', 'roleplay', 'chat'];
}

// Preset metadata used for UI helper card under mentor intro
class MentorPresetMeta {
  static const Map<String, Map<String, String>> byKey = {
    'drill': {
      'title': 'Drill',
      'description':
          'Rapid practice to build instinct. Short, targeted exercises to sharpen defenses.',
      'example':
          'Give me 5 quick drills to resist love bombing in text conversations.'
    },
    'advise': {
      'title': 'Advise',
      'description':
          'Direct, actionable guidance for a specific situation you describe.',
      'example':
          'She stopped replying after I teased her once. What should I do now?'
    },
    'roleplay': {
      'title': 'Roleplay',
      'description':
          'Simulate the other side so you can anticipate tactics and practice responses.',
      'example':
          'Roleplay a manipulator trying to make me feel guilty for saying no.'
    },
    'chat': {
      'title': 'Chat',
      'description':
          'Open conversation for questions, ideas, or general breakdowns.',
      'example': 'Break down this message and tell me what hidden tactics are in it.'
    },
  };
}

// Mock user data for development
class MockData {
  // Note: mockUser removed - now using the lesson engine UserProfile structure
  // The lesson engine will create default profiles automatically

  static WhisperfireResponse get mockScanResponse => const WhisperfireResponse(
        context: WhisperfireContext(
          relationship: 'Partner',
          tone: 'savage',
          contentType: 'dm',
          subjectName: null,
          tab: 'scan',
        ),
        headline: 'Classic reality distortion detected',
        coreTake:
            'Systematic attempt to undermine your perception of reality through contradiction and blame-shifting.',
        tactic: WhisperfireTactic(label: 'Gaslighting', confidence: 89),
        motives:
            'Control narrative, avoid accountability, destabilize your confidence',
        targeting: 'Self-trust, emotional stability, memory confidence',
        powerPlay:
            'Document everything. Gray rock method. Trust your initial instincts.',
        receipts: [
          '"You\'re being too dramatic" - minimizing your feelings',
          '"I never said that" - denying previous statements',
        ],
        nextMoves:
            'Double down on contradictions, escalate emotional manipulation',
        suggestedReply: WhisperfireSuggestedReply(
          style: 'one_liner',
          text:
              'I\'m documenting our conversations now. Let\'s stick to facts.',
        ),
        safety: WhisperfireSafety(
          riskLevel: 'MODERATE',
          notes: 'Document interactions, consider support network',
        ),
        metrics: WhisperfireMetrics(
          redFlag: 85,
          certainty: 78,
          viralPotential: 42,
        ),
        pattern: null,
        ambiguity: null,
      );

  static WhisperfireResponse get mockPatternResponse =>
      const WhisperfireResponse(
        context: WhisperfireContext(
          relationship: 'Partner',
          tone: 'savage',
          contentType: 'dm',
          subjectName: null,
          tab: 'pattern',
        ),
        headline: 'Systematic manipulation pattern detected',
        coreTake:
            'Long-term psychological warfare with clear escalation cycles.',
        tactic: WhisperfireTactic(label: 'Gaslighting', confidence: 92),
        motives: 'Complete control, emotional dependency, isolation',
        targeting: 'Self-trust, relationships, mental health',
        powerPlay: 'Document everything. Set firm boundaries. Seek support.',
        receipts: [
          '"You\'re being too dramatic" - minimizing your feelings',
          '"I never said that" - denying previous statements',
          '"Everyone thinks you\'re crazy" - isolation tactic',
          '"You made me do it" - victim blaming',
        ],
        nextMoves: 'Escalate manipulation, test boundaries, isolate further',
        suggestedReply: WhisperfireSuggestedReply(
          style: 'reverse_uno',
          text: 'I\'m documenting our conversations. Let\'s stick to facts.',
        ),
        safety: WhisperfireSafety(
          riskLevel: 'HIGH',
          notes: 'Immediate intervention needed. Document everything.',
        ),
        metrics: WhisperfireMetrics(
          redFlag: 92,
          certainty: 89,
          viralPotential: 67,
        ),
        pattern: WhisperfirePattern(
          cycle: 'Weekly escalation',
          prognosis: 'Will continue until stopped',
        ),
        ambiguity: null,
        hiddenAgenda: 'Complete psychological control',
        archetypes: [
          WhisperfireArchetype(label: 'Gaslighting', weight: 92),
          WhisperfireArchetype(label: 'Love Bombing', weight: 78),
          WhisperfireArchetype(label: 'DARVO', weight: 65),
        ],
        triggerPatternMap: 'Weekly escalation cycle',
        contradictions: [
          'Denies previous statements',
          'Claims victim status',
          'Minimizes your feelings',
        ],
        weapons: [
          'Emotional manipulation',
          'Gaslighting',
          'Isolation tactics',
        ],
        forecast: [
          WhisperfireForecast(
              window: '3-5 days',
              event: 'Love bombing attempt',
              likelihood: 85),
          WhisperfireForecast(
              window: '1 week', event: 'Escalation', likelihood: 92),
        ],
        counterIntervention: 'Immediate boundary setting and documentation',
        longGame: 'Complete psychological control and dependency',
      );
}

// ===== UPDATED MOCK DATA =====
extension MockDataProfile on MockData {
  static final UserProfile enhancedMockUser = UserProfile(
    id: 'defender_001',
    xpTotal: 2450,
    categories: {
      'charisma': CategoryProgress(xp: 1200, level: 3),
      'gravity': CategoryProgress(xp: 800, level: 2),
      'frame': CategoryProgress(xp: 450, level: 2),
      'scarcity': CategoryProgress(xp: 300, level: 1),
      'composed_authority': CategoryProgress(xp: 200, level: 1),
      'hidden_dynamics': CategoryProgress(xp: 100, level: 1),
    },
    unlockedLessons: {
      'charisma-world1-lesson1',
      'charisma-world1-lesson2',
      'charisma-world1-lesson3',
      'charisma-world2-lesson6',
    },
  );
}
