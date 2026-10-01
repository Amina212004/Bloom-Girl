import 'dart:math';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../widgets/pink_panda_mascot.dart';

class CycleTrackerScreen extends StatefulWidget {
  const CycleTrackerScreen({Key? key}) : super(key: key);

  @override
  State<CycleTrackerScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends State<CycleTrackerScreen>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();

  DateTime _focusedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime.now();

  AnimationController? _glowController;
  late Animation<double> _glowAnimation;

  // Suivi du flux et de l'humeur
  String _selectedFlow = 'Moyen';
  String _selectedMood = 'Calme & Sereine';

  final List<Map<String, dynamic>> _flowOptions = [
    {'id': 'spotting', 'label': 'Spotting', 'icon': Icons.water_drop_outlined},
    {'id': 'leger', 'label': 'Léger', 'icon': Icons.water_drop_rounded},
    {'id': 'moyen', 'label': 'Moyen', 'icon': Icons.opacity_rounded},
    {'id': 'abondant', 'label': 'Abondant', 'icon': Icons.waves_rounded},
  ];

  final List<Map<String, dynamic>> _moodOptions = [
    {'label': 'Épanouie', 'icon': Icons.sentiment_very_satisfied_rounded},
    {'label': 'Calme & Sereine', 'icon': Icons.spa_rounded},
    {'label': 'Sensible / Émotive', 'icon': Icons.favorite_rounded},
    {'label': 'Fatiguée', 'icon': Icons.bedtime_rounded},
    {'label': 'Irritée / Crampes', 'icon': Icons.healing_rounded},
  ];

  final List<Map<String, dynamic>> _symptoms = [
    {'id': 'cramps', 'name': 'Crampes bas-ventre', 'icon': Icons.healing_rounded, 'active': true},
    {'id': 'fatigue', 'name': 'Fatigue / Sommeil', 'icon': Icons.bedtime_rounded, 'active': true},
    {'id': 'headache', 'name': 'Maux de tête', 'icon': Icons.spa_rounded, 'active': false},
    {'id': 'bloating', 'name': 'Ventre gonflé', 'icon': Icons.cloud_rounded, 'active': false},
    {'id': 'cravings', 'name': 'Envie de sucré', 'icon': Icons.favorite_rounded, 'active': true},
    {'id': 'acne', 'name': 'Sensibilité peau', 'icon': Icons.face_retouching_natural_rounded, 'active': false},
  ];

  static const Color _roseBerry = Color(0xFFA04566);
  static const Color _roseSoft = Color(0xFFF2C7D0);
  static const Color _roseLight = Color(0xFFFFF0F4);
  static const Color _roseDeep = Color(0xFF7A2B49);
  static const Color _goldGlow = Color(0xFFE5A93B);

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    if (_glowController == null) {
      _glowController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);

      _glowAnimation = Tween<double>(begin: 4.0, end: 16.0).animate(
        CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _initAnimations();
  }

  @override
  void dispose() {
    _glowController?.dispose();
    super.dispose();
  }

  // Action interactive : Déclarer le début des règles à la date sélectionnée ou aujourd'hui
  Future<void> _logPeriodStartDate(DateTime date) async {
    final profile = _userService.profile;
    final updated = profile.copyWith(
      lastPeriodDate: date,
      hasSetupCycle: true,
    );
    await _userService.updateProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Début du cycle enregistré le ${date.day}/${date.month}/${date.year} 🌸',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: _roseBerry,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.all(16),
        ),
      );
      setState(() {});
    }
  }

  // Widget d'onboarding pour la première utilisation
  Widget _buildOnboardingSetup(String name) {
    DateTime _pickedDate = DateTime.now();
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE07A9A), Color(0xFFA04566)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _roseBerry.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 52),
              ),
              const SizedBox(height: 28),
              Text(
                'Bonjour $name 🌸',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7A2B49),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Pour personnaliser ton suivi de cycle,\nindique-nous la date de tes dernières règles.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF9E658E),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _roseSoft, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _roseBerry.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: StatefulBuilder(
                  builder: (context, setInnerState) {
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: _roseLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _roseSoft),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, color: _roseBerry, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Dernières règles : ${_pickedDate.day}/${_pickedDate.month}/${_pickedDate.year}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7A2B49),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now().subtract(const Duration(days: 90)),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) => Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: _roseBerry,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Color(0xFF381242),
                                        ),
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) {
                                    setInnerState(() => _pickedDate = picked);
                                  }
                                },
                                child: const Text('Modifier', style: TextStyle(color: _roseBerry, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => _logPeriodStartDate(_pickedDate),
                            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                            label: const Text(
                              'Commencer mon suivi 🌸',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _roseBerry,
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modal interactif de saisie quotidienne
  void _openDailyLogModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle de tirage
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _roseSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_calendar_rounded,
                                color: _roseBerry, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Journal du ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: _roseBerry,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(color: _roseLight, height: 1),
                    const SizedBox(height: 14),

                    // 1. Bouton rapide : Déclarer Règles aujourd'hui
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _logPeriodStartDate(_selectedDate);
                      },
                      icon: const Icon(Icons.water_drop_rounded,
                          color: Colors.white, size: 18),
                      label: Text(
                        'Marquer le début de mes règles (${_selectedDate.day}/${_selectedDate.month})',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE56B85),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. Flux de Règles
                    const Text(
                      'Intensité du flux :',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _roseDeep),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _flowOptions.map((opt) {
                        final label = opt['label'] as String;
                        final icon = opt['icon'] as IconData;
                        final isSelected = _selectedFlow == label;
                        return InkWell(
                          onTap: () {
                            setModalState(() => _selectedFlow = label);
                            setState(() => _selectedFlow = label);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? _roseBerry : _roseLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: isSelected ? _roseBerry : _roseSoft),
                            ),
                            child: Row(
                              children: [
                                Icon(icon,
                                    size: 16,
                                    color: isSelected ? Colors.white : _roseBerry),
                                const SizedBox(width: 6),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected ? Colors.white : _roseDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // 3. Humeur du jour
                    const Text(
                      'Humeur & Énergie :',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _roseDeep),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _moodOptions.map((m) {
                        final label = m['label'] as String;
                        final icon = m['icon'] as IconData;
                        final isSelected = _selectedMood == label;
                        return InkWell(
                          onTap: () {
                            setModalState(() => _selectedMood = label);
                            setState(() => _selectedMood = label);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? _roseBerry : _roseLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: isSelected ? _roseBerry : _roseSoft),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon,
                                    size: 16,
                                    color: isSelected ? Colors.white : _roseBerry),
                                const SizedBox(width: 6),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected ? Colors.white : _roseDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Journal de bord enregistré avec succès ! 💕',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                              backgroundColor: _roseBerry,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_rounded,
                            color: Colors.white, size: 18),
                        label: const Text(
                          'Enregistrer mon suivi',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _roseBerry,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations();
    final profile = _userService.profile;

    // Si l'utilisatrice n'a pas encore configuré son cycle → écran d'onboarding
    if (!profile.hasSetupCycle || profile.lastPeriodDate == null) {
      return _buildOnboardingSetup(profile.name.isNotEmpty ? profile.name : 'belle');
    }

    final lastPeriod = profile.lastPeriodDate!;
    final nextPeriod = lastPeriod.add(Duration(days: profile.cycleLength));

    int daysLeft = nextPeriod.difference(DateTime.now()).inDays;
    if (daysLeft < 0) daysLeft = 0;

    final currentDayOfCycle =
        (DateTime.now().difference(lastPeriod).inDays % profile.cycleLength) + 1;

    String currentPhase;
    Color phaseColor;

    if (currentDayOfCycle <= profile.periodDuration) {
      currentPhase = "Phase Menstruelle";
      phaseColor = const Color(0xFFE56B85);
    } else if (currentDayOfCycle <= 11) {
      currentPhase = "Phase Folliculaire";
      phaseColor = const Color(0xFFD67397);
    } else if (currentDayOfCycle <= 16) {
      currentPhase = "Phase Ovulatoire";
      phaseColor = _goldGlow;
    } else {
      currentPhase = "Phase Lutéale";
      phaseColor = const Color(0xFF9E658E);
    }

    // Calcul réactif de la phase et de l'énergie selon la date SÉLECTIONNÉE
    final selectedDiffDays = _selectedDate.difference(lastPeriod).inDays;
    final selectedCycleDay = (selectedDiffDays % profile.cycleLength) + 1;

    String selectedPhase;
    String selectedAdvice;
    double selectedEnergy;

    if (selectedDiffDays < 0) {
      selectedPhase = "Historique Ancien";
      selectedAdvice = "Données antérieures à l'enregistrement de ton cycle.";
      selectedEnergy = 0.50;
    } else if (selectedCycleDay <= profile.periodDuration) {
      selectedPhase = "Phase Menstruelle";
      selectedAdvice = "Phase Menstruelle 🩸 : Repose-toi, hydrate-toi et privilégie le cocooning 🍵";
      selectedEnergy = 0.35;
    } else if (selectedCycleDay <= 11) {
      selectedPhase = "Phase Folliculaire";
      selectedAdvice = "Phase Folliculaire 🌱 : Ton énergie remonte ! C'est le moment d'entreprendre 💪";
      selectedEnergy = 0.70;
    } else if (selectedCycleDay <= 16) {
      selectedPhase = "Phase Ovulatoire";
      selectedAdvice = "Phase Ovulatoire ✨ : Pic d'éclat et de confiance ! Profite de ta lumière 🌟";
      selectedEnergy = 0.95;
    } else {
      selectedPhase = "Phase Lutéale";
      selectedAdvice = "Phase Lutéale 🌙 : Ralentis le rythme, écoute ton corps et prends soin de toi 💆‍♀️";
      selectedEnergy = 0.50;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openDailyLogModal,
        backgroundColor: _roseBerry,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Enregistrer ma journée',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 105),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🌸 HERO CARD : Statut + Bouton d'Action rapide
                AnimatedBuilder(
                  animation: _glowController!,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(22.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE07A9A), Color(0xFFA04566)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: _roseBerry.withOpacity(0.32),
                            blurRadius: _glowAnimation.value + 6,
                            spreadRadius: _glowAnimation.value * 0.1,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'SUIVI DU CYCLE DE ${profile.name.toUpperCase()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            daysLeft == 0 ? 'Aujourd\'hui' : 'Dans $daysLeft jours',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Prochaines règles prévues le ${nextPeriod.day}/${nextPeriod.month}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: phaseColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'JOUR $currentDayOfCycle • $currentPhase',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Bouton d'action rapide dans la Hero card
                          OutlinedButton.icon(
                            onPressed: () => _logPeriodStartDate(DateTime.now()),
                            icon: const Icon(Icons.water_drop_rounded,
                                color: Colors.white, size: 16),
                            label: const Text(
                              'Déclarer mes règles aujourd\'hui',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white, width: 1.2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🌊 TIMELINE DE LA VAGUE D'ÉNERGIE HORMONALE (Interactive)
                _buildEnergyWaveTimelineCard(
                  selectedCycleDay,
                  profile.cycleLength,
                  selectedAdvice,
                  selectedEnergy,
                  lastPeriod,
                ),

                const SizedBox(height: 20),

                // 🗓️ CALENDRIER INTERACTIF À HALOS COLORÉS
                _buildHalosCalendarCard(lastPeriod, profile.cycleLength, profile.periodDuration),

                const SizedBox(height: 20),

                // 🔍 DÉTAILS DE LA DATE SÉLECTIONNÉE
                _buildSelectedDateDetailsCard(lastPeriod, profile.cycleLength, profile.periodDuration),

                const SizedBox(height: 20),

                // 💖 JOURNAL DES SYMPTÔMES & BIEN-ÊTRE
                _buildSymptomsCard(profile.name),
              ],
            ),
          ),

          // 🧸 MASCOTTE PANDA 3D POSÉE DANS LE COIN DE L'INTERFACE (Hug himself !)
          Positioned(
            bottom: 14,
            left: 14,
            child: PinkPanda3DCornerWidget(
              userName: profile.name,
              currentPhase: selectedPhase,
            ),
          ),
        ],
      ),
    );
  }

  // 🌊 Timeline Visuelle & Vague d'Énergie Interactive
  Widget _buildEnergyWaveTimelineCard(
      int selectedDay, int cycleLength, String adviceText, double currentEnergy, DateTime lastPeriod) {
    final bool isToday = _isSameDay(_selectedDate, DateTime.now());
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.0),
        border: Border.all(color: _roseSoft, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _roseBerry.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: _roseLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.show_chart_rounded,
                    color: _roseBerry, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vague d\'Énergie & Hormones',
                      style: TextStyle(
                        color: _roseBerry,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isToday
                          ? 'Jour $selectedDay du cycle (Aujourd\'hui)'
                          : 'Jour $selectedDay du cycle (${_selectedDate.day}/${_selectedDate.month})',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9E8492), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _roseLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _roseSoft),
                ),
                child: Text(
                  '${(currentEnergy * 100).toInt()}% Énergie',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _roseBerry,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Graphique ondulé interactif : Cliquez sur le graphe pour changer de jour !
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) {
                  final double width = constraints.maxWidth;
                  if (width > 0) {
                    final double ratio = (details.localPosition.dx / width).clamp(0.0, 1.0);
                    final int targetDay = (ratio * (cycleLength - 1)).round() + 1;
                    setState(() {
                      _selectedDate = lastPeriod.add(Duration(days: targetDay - 1));
                    });
                  }
                },
                child: SizedBox(
                  height: 75,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _EnergyWavePainter(
                      currentDayRatio: ((selectedDay - 1) / (cycleLength - 1)).clamp(0.0, 1.0),
                      waveColor: _roseBerry,
                      gradientColor: _roseSoft,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Les 4 Phases résumées et cliquables sous la vague
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPhaseIndicator(
                'Règles',
                'J1-5',
                const Color(0xFFE56B85),
                selectedDay <= 5,
                () {
                  setState(() {
                    _selectedDate = lastPeriod.add(const Duration(days: 0));
                  });
                },
              ),
              _buildPhaseIndicator(
                'Folliculaire',
                'J6-11',
                const Color(0xFFD67397),
                selectedDay >= 6 && selectedDay <= 11,
                () {
                  setState(() {
                    _selectedDate = lastPeriod.add(const Duration(days: 7));
                  });
                },
              ),
              _buildPhaseIndicator(
                'Ovulation',
                'J12-16',
                _goldGlow,
                selectedDay >= 12 && selectedDay <= 16,
                () {
                  setState(() {
                    _selectedDate = lastPeriod.add(const Duration(days: 13));
                  });
                },
              ),
              _buildPhaseIndicator(
                'Lutéale',
                'J17-28',
                const Color(0xFF9E658E),
                selectedDay >= 17,
                () {
                  setState(() {
                    _selectedDate = lastPeriod.add(const Duration(days: 20));
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Carte Conseil du jour personnalisé
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _roseLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _roseSoft),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: _roseBerry, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    adviceText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _roseDeep,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(
      String label, String days, Color color, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? color : Colors.transparent, width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : _roseDeep,
              ),
            ),
            Text(
              days,
              style: TextStyle(
                fontSize: 9.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🗓️ Calendrier à Halos Colorés
  Widget _buildHalosCalendarCard(
      DateTime lastPeriod, int cycleLength, int periodDuration) {
    final today = DateTime.now();

    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);

    final startingWeekday = firstDayOfMonth.weekday;
    final leadingEmptyDays = startingWeekday - 1;
    final totalGridCells = leadingEmptyDays + daysInMonth;

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.0),
        border: Border.all(color: _roseSoft, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _roseBerry.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    color: _roseBerry, size: 24),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month - 1, 1);
                  });
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _formatMonthYear(_focusedMonth),
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: _roseBerry,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Clique sur une date pour voir et modifier les détails',
                      style: TextStyle(
                          fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                    color: _roseBerry, size: 24),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _roseDeep,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          const Divider(color: _roseSoft, height: 1),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalGridCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmptyDays) {
                return const SizedBox.shrink();
              }

              final dayNumber = index - leadingEmptyDays + 1;
              final cellDate = DateTime(
                  _focusedMonth.year, _focusedMonth.month, dayNumber);
              final isToday = _isSameDay(cellDate, today);
              final isSelected = _isSameDay(cellDate, _selectedDate);

              final diffDays = cellDate.difference(lastPeriod).inDays;
              final cycleDay = (diffDays % cycleLength) + 1;

              Color haloColor = Colors.transparent;
              Color textColor = const Color(0xFF381242);
              bool hasHalo = false;

              if (diffDays >= 0) {
                if (cycleDay <= periodDuration) {
                  haloColor = const Color(0xFFFFE4EC);
                  textColor = _roseBerry;
                  hasHalo = true;
                } else if (cycleDay >= 12 && cycleDay <= 16) {
                  haloColor = const Color(0xFFFFF7E6);
                  textColor = const Color(0xFFB87E14);
                  hasHalo = true;
                } else if (cycleDay > 16) {
                  haloColor = const Color(0xFFF7F0F8);
                  textColor = const Color(0xFF7A4574);
                  hasHalo = true;
                }
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = cellDate;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? _roseBerry
                        : (isToday ? _roseLight : haloColor),
                    border: Border.all(
                      color: isSelected
                          ? _roseBerry
                          : (isToday
                              ? _roseBerry
                              : (hasHalo
                                  ? _roseSoft.withOpacity(0.8)
                                  : Colors.transparent)),
                      width: isSelected || isToday ? 1.8 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _roseBerry.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            isSelected || isToday ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : textColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🔍 CARTE INTERACTIVE : DÉTAILS DE LA DATE SÉLECTIONNÉE
  Widget _buildSelectedDateDetailsCard(
      DateTime lastPeriod, int cycleLength, int periodDuration) {
    final diffDays = _selectedDate.difference(lastPeriod).inDays;
    final cycleDay = (diffDays % cycleLength) + 1;

    String phaseName;
    String phaseDetail;
    Color phaseColor;

    if (diffDays < 0) {
      phaseName = "Historique Ancien";
      phaseDetail = "Données antérieures à l'enregistrement de ton cycle.";
      phaseColor = Colors.grey;
    } else if (cycleDay <= periodDuration) {
      phaseName = "Phase Menstruelle 🩸";
      phaseDetail = "Jour $cycleDay de tes règles. Repos et hydratation conseillés.";
      phaseColor = const Color(0xFFE56B85);
    } else if (cycleDay <= 11) {
      phaseName = "Phase Folliculaire 🌱";
      phaseDetail = "Jour $cycleDay. Ta vitalité et ta motivation sont en hausse !";
      phaseColor = const Color(0xFFD67397);
    } else if (cycleDay <= 16) {
      phaseName = "Phase Ovulatoire ✨";
      phaseDetail = "Jour $cycleDay. Pic d'ovulation et fertilité maximale.";
      phaseColor = _goldGlow;
    } else {
      phaseName = "Phase Lutéale 🌙";
      phaseDetail = "Jour $cycleDay. Phase post-ovulatoire, prends du temps pour toi.";
      phaseColor = const Color(0xFF9E658E);
    }

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: _roseSoft, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _roseBerry.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_note_rounded,
                      color: _roseBerry, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDate.day} ${_formatMonthYear(_selectedDate)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _roseBerry,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _openDailyLogModal,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _roseLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _roseSoft),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_rounded, color: _roseBerry, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Modifier',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: _roseBerry),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _roseLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: phaseColor.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: phaseColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      phaseName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: phaseColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  phaseDetail,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _safeIcon(dynamic val, [IconData fallback = Icons.favorite_rounded]) {
    if (val is IconData) return val;
    return fallback;
  }

  // 💖 Symptômes & Journal de Réconfort (Sans Emojis)
  Widget _buildSymptomsCard(String userName) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: _roseSoft, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _roseBerry.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_rounded,
                      color: _roseBerry, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tes symptômes aujourd\'hui',
                    style: const TextStyle(
                      color: _roseBerry,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: _roseBerry, size: 20),
                onPressed: _openDailyLogModal,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptoms.map((symptom) {
              final active = (symptom['active'] as bool?) ?? false;
              final icon = _safeIcon(symptom['icon'], Icons.favorite_rounded);
              final name = (symptom['name'] as String?) ?? 'Symptôme';
              return InkWell(
                onTap: () {
                  setState(() {
                    symptom['active'] = !active;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? _roseBerry : _roseLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? _roseBerry : _roseSoft,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: active ? Colors.white : _roseBerry,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: TextStyle(
                          color: active ? Colors.white : _roseDeep,
                          fontSize: 12.5,
                          fontWeight: active ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Helpers
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return "${months[date.month - 1]} ${date.year}";
  }
}

// 🎨 Custom Painter pour tracer la Vague d'Énergie Hormonale fluide et ultra réactive
class _EnergyWavePainter extends CustomPainter {
  final double currentDayRatio;
  final Color waveColor;
  final Color gradientColor;

  _EnergyWavePainter({
    required this.currentDayRatio,
    required this.waveColor,
    required this.gradientColor,
  });

  static double evaluateWaveY(double ratio, double height) {
    final clamped = ratio.clamp(0.0, 1.0);
    final double rad = clamped * 2 * pi;
    final double baseWave = sin(rad - pi / 2.2);
    final double peakBonus = exp(-pow((clamped - 0.45) * 4.5, 2)) * 0.35;
    final double normalizedY = 0.55 - (baseWave * 0.28 + peakBonus);
    return height * normalizedY.clamp(0.08, 0.90);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const steps = 80;
    for (int i = 0; i <= steps; i++) {
      final r = i / steps;
      final x = size.width * r;
      final y = evaluateWaveY(r, size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          waveColor.withOpacity(0.18),
          gradientColor.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final clampedRatio = currentDayRatio.clamp(0.0, 1.0);
    final pointX = size.width * clampedRatio;
    final pointY = evaluateWaveY(clampedRatio, size.height);

    final outerRing = Paint()
      ..color = waveColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final nodePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(pointX, pointY), 11, outerRing);
    canvas.drawCircle(Offset(pointX, pointY), 7, nodePaint);
    canvas.drawCircle(Offset(pointX, pointY), 3.5, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _EnergyWavePainter oldDelegate) {
    return oldDelegate.currentDayRatio != currentDayRatio;
  }
}
