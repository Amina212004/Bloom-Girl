import 'package:flutter/material.dart';
import '../services/user_service.dart';

class TimeOrganizerScreen extends StatefulWidget {
  const TimeOrganizerScreen({Key? key}) : super(key: key);

  @override
  State<TimeOrganizerScreen> createState() => _TimeOrganizerScreenState();
}

class _TimeOrganizerScreenState extends State<TimeOrganizerScreen>
    with TickerProviderStateMixin {
  final UserService _userService = UserService();
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'Ravissante';
  int _waterCups = 5;

  // Controllers d'animation
  AnimationController? _glowController;
  late Animation<double> _glowAnimation;

  AnimationController? _pulseController;
  late Animation<double> _pulseAnimation;

  AnimationController? _starRotateController;

  // Tâches enregistrées par date (AAAA-MM-JJ)
  final Map<String, List<Map<String, dynamic>>> _tasksByDate = {};

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Études & Travail', 'icon': Icons.school_rounded},
    {'name': 'Santé & Hydratation', 'icon': Icons.water_drop_rounded},
    {'name': 'Skincare & Soin', 'icon': Icons.spa_rounded},
    {'name': 'Détente & Sport', 'icon': Icons.fitness_center_rounded},
    {'name': 'Plaisir & Sortie', 'icon': Icons.shopping_bag_rounded},
  ];

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Ravissante', 'icon': Icons.sentiment_very_satisfied_rounded},
    {'name': 'Motivée', 'icon': Icons.bolt_rounded},
    {'name': 'Fatiguée', 'icon': Icons.bedtime_rounded},
    {'name': 'Douleurs', 'icon': Icons.healing_rounded},
    {'name': 'Épanouie', 'icon': Icons.favorite_rounded},
  ];

  static const Color _roseBerry = Color(0xFFA04566);
  static const Color _roseSoft = Color(0xFFF2C7D0);
  static const Color _roseLight = Color(0xFFFFF0F4);
  static const Color _roseDeep = Color(0xFF7A2B49);

  @override
  void initState() {
    super.initState();
    _initDefaultTasks();
    _initAnimations();
  }

  void _initAnimations() {
    if (_glowController == null) {
      _glowController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);

      _glowAnimation = Tween<double>(begin: 4.0, end: 18.0).animate(
        CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
      );
    }

    if (_pulseController == null) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);

      _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
    }

    if (_starRotateController == null) {
      _starRotateController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 8),
      )..repeat();
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
    _pulseController?.dispose();
    _starRotateController?.dispose();
    super.dispose();
  }

  void _initDefaultTasks() {
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final tomorrowKey = _dateKey(today.add(const Duration(days: 1)));
    final inThreeDaysKey = _dateKey(today.add(const Duration(days: 3)));
    final inFiveDaysKey = _dateKey(today.add(const Duration(days: 5)));

    _tasksByDate[todayKey] = [
      {
        'id': 1,
        'text': 'Réviser les cours (30 min)',
        'category': 'Études & Travail',
        'icon': Icons.school_rounded,
        'completed': true
      },
      {
        'id': 2,
        'text': 'Boire 1.5L d\'eau fraîche',
        'category': 'Santé & Hydratation',
        'icon': Icons.water_drop_rounded,
        'completed': false
      },
      {
        'id': 3,
        'text': 'Pause Skincare & Masque hydratant',
        'category': 'Skincare & Soin',
        'icon': Icons.spa_rounded,
        'completed': true
      },
      {
        'id': 4,
        'text': '10 min de méditation ou étirements',
        'category': 'Détente & Sport',
        'icon': Icons.fitness_center_rounded,
        'completed': false
      },
    ];

    _tasksByDate[tomorrowKey] = [
      {
        'id': 5,
        'text': 'Préparer mon Look & Tenue du lendemain',
        'category': 'Plaisir & Sortie',
        'icon': Icons.shopping_bag_rounded,
        'completed': false
      },
      {
        'id': 6,
        'text': 'Séance de marche rapide (20 min)',
        'category': 'Détente & Sport',
        'icon': Icons.fitness_center_rounded,
        'completed': false
      },
    ];

    _tasksByDate[inThreeDaysKey] = [
      {
        'id': 7,
        'text': 'Shopping Skincare & Cosmétiques',
        'category': 'Plaisir & Sortie',
        'icon': Icons.shopping_bag_rounded,
        'completed': false
      },
    ];

    _tasksByDate[inFiveDaysKey] = [
      {
        'id': 8,
        'text': 'Bilan de ma semaine & Rest time',
        'category': 'Détente & Sport',
        'icon': Icons.fitness_center_rounded,
        'completed': false
      },
    ];
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  List<Map<String, dynamic>> _getTasksForSelectedDate() {
    final key = _dateKey(_selectedDate);
    final raw = _tasksByDate[key];
    if (raw == null) return <Map<String, dynamic>>[];
    return List<Map<String, dynamic>>.from(raw);
  }

  void _toggleTask(int id) {
    setState(() {
      final key = _dateKey(_selectedDate);
      final list = _tasksByDate[key];
      if (list != null) {
        for (final item in list) {
          if (item['id'] == id) {
            item['completed'] = !(item['completed'] == true);
            break;
          }
        }
      }
    });
  }

  void _deleteTask(int id) {
    setState(() {
      final key = _dateKey(_selectedDate);
      _tasksByDate[key]?.removeWhere((t) => t['id'] == id);
    });
  }

  IconData _safeIcon(dynamic val, [IconData fallback = Icons.task_alt_rounded]) {
    if (val is IconData) return val;
    return fallback;
  }

  // 💖 Pop-up Modal Éléguant & Épuré (Sans Emojis)
  void _openAddTaskModal({DateTime? targetDate}) {
    final dateToUse = targetDate ?? _selectedDate;
    final textController = TextEditingController();
    String selectedCategory = _categories.first['name'] as String;
    IconData selectedIcon = _safeIcon(_categories.first['icon'], Icons.category_rounded);
    String priority = 'Douceur';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Ajouter une tâche',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim1, anim2) => Container(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFFFF4F7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _roseSoft, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: _roseBerry.withOpacity(0.25),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: StatefulBuilder(
                  builder: (context, setModalState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header du Pop-up avec icône vectorielle élégante
                      Row(
                        children: [
                          RotationTransition(
                            turns: _starRotateController!,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _roseSoft.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_calendar_rounded,
                                  color: _roseBerry, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nouvelle Tâche',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _roseBerry,
                                  ),
                                ),
                                Text(
                                  _formatFullDate(dateToUse),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _roseDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: _roseBerry, size: 22),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Champ de saisie
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _roseSoft, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: _roseBerry.withOpacity(0.06),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: textController,
                          autofocus: true,
                          style: const TextStyle(
                              fontSize: 14.5, color: Color(0xFF381242)),
                          decoration: InputDecoration(
                            hintText:
                                'Que vas-tu accomplir le ${_formatShortDate(dateToUse)} ?',
                            hintStyle: const TextStyle(
                                color: Color(0xFFB59AA7), fontSize: 13.0),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Catégorie avec icônes vectorielles
                      const Text(
                        'Catégorie',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: _roseBerry,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final name = cat['name'] as String;
                            final icon = _safeIcon(cat['icon'], Icons.category_rounded);
                            final isSel = selectedCategory == name;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                avatar: Icon(
                                  icon,
                                  size: 15,
                                  color: isSel ? Colors.white : _roseBerry,
                                ),
                                label: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? Colors.white : _roseBerry,
                                  ),
                                ),
                                selected: isSel,
                                selectedColor: _roseBerry,
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: _roseSoft),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                onSelected: (val) {
                                  if (val) {
                                    setModalState(() {
                                      selectedCategory = name;
                                      selectedIcon = icon;
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Priorités avec Icônes
                      const Text(
                        'Intention & Priorité',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: _roseBerry,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriorityChip('Douceur', Icons.favorite_border_rounded, priority, (val) {
                            setModalState(() => priority = val);
                          }),
                          const SizedBox(width: 8),
                          _buildPriorityChip('Importante', Icons.priority_high_rounded, priority, (val) {
                            setModalState(() => priority = val);
                          }),
                          const SizedBox(width: 8),
                          _buildPriorityChip('Priorité', Icons.star_rounded, priority, (val) {
                            setModalState(() => priority = val);
                          }),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Bouton Valider
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final text = textController.text.trim();
                            if (text.isNotEmpty) {
                              final key = _dateKey(dateToUse);
                              if (!_tasksByDate.containsKey(key)) {
                                _tasksByDate[key] = [];
                              }
                              setState(() {
                                _tasksByDate[key]!.add({
                                  'id': DateTime.now().millisecondsSinceEpoch,
                                  'text': text,
                                  'category': selectedCategory,
                                  'icon': selectedIcon,
                                  'completed': false,
                                });
                                _selectedDate = dateToUse;
                              });
                              Navigator.pop(ctx);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: Colors.white, size: 16),
                                      const SizedBox(width: 8),
                                      const Text('Tâche enregistrée pour le ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      Text(_formatShortDate(dateToUse),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  backgroundColor: _roseBerry,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 18),
                          label: const Text(
                            'Enregistrer cette tâche',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _roseBerry,
                            elevation: 4,
                            shadowColor: _roseBerry.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityChip(
      String label, IconData icon, String selectedPriority, Function(String) onSelect) {
    final isSel = selectedPriority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSel ? _roseBerry.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSel ? _roseBerry : _roseSoft,
              width: isSel ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: _roseBerry),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  color: _roseBerry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations();
    final profile = _userService.profile;
    final tasks = _getTasksForSelectedDate();
    final completedCount = tasks.where((t) => t['completed'] == true).length;
    final progressPercent =
        tasks.isNotEmpty ? (completedCount / tasks.length) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTaskModal(targetDate: _selectedDate),
        backgroundColor: _roseBerry,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: Text(
          'Ajouter pour le ${_formatShortDate(_selectedDate)}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.0),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🌸 CARTE PENSÉE DU JOUR (Sans Emojis)
            _buildHeaderQuoteCard(profile.name),

            const SizedBox(height: 16),

            // 📅 GRAND CALENDRIER DE MOIS COMPLET
            _buildFullMonthCalendarCard(),

            const SizedBox(height: 16),

            // 📋 TÂCHES POUR LE JOUR SÉLECTIONNÉ
            _buildTaskListCard(tasks, completedCount, progressPercent),

            const SizedBox(height: 16),

            // 💖 HUMEUR & HYDRATATION
            _buildMoodAndHydrationCard(),
          ],
        ),
      ),
    );
  }

  // 🌸 CARTE PENSÉE DU JOUR AVEC ANIMATION LUMINEUSE (Sans Emojis)
  Widget _buildHeaderQuoteCard(String userName) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowController!, _pulseController!]),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFF0F5),
                Color(0xFFFFE4EC),
                Color(0xFFFFF8FB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: _roseSoft, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _roseBerry.withOpacity(0.14),
                blurRadius: _glowAnimation.value,
                spreadRadius: _glowAnimation.value * 0.15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RotationTransition(
                    turns: _starRotateController!,
                    child: const Icon(Icons.auto_awesome,
                        color: _roseBerry, size: 18),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'PENSÉE DU JOUR',
                    style: TextStyle(
                      color: _roseBerry,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _roseSoft),
                        boxShadow: [
                          BoxShadow(
                            color: _roseBerry.withOpacity(0.12),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bonjour $userName',
                            style: const TextStyle(
                              color: _roseBerry,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.favorite_rounded,
                              color: _roseBerry, size: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '"Chaque jour est une nouvelle opportunité de fleurir à ton propre rythme, $userName. Prends soin de toi !"',
                style: const TextStyle(
                  color: Color(0xFF5A1E38),
                  fontSize: 13.8,
                  height: 1.42,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 📅 GRAND CALENDRIER DE MOIS COMPLET (Grille 7 jours x 5-6 semaines)
  Widget _buildFullMonthCalendarCard() {
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
            color: _roseBerry.withOpacity(0.09),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête du calendrier
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _roseLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: _roseSoft),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left_rounded,
                      color: _roseBerry, size: 24),
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                          _focusedMonth.year, _focusedMonth.month - 1, 1);
                    });
                  },
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _formatMonthYear(_focusedMonth),
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                        color: _roseBerry,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sélectionne n\'importe quel jour pour planifier',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _roseLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: _roseSoft),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right_rounded,
                      color: _roseBerry, size: 24),
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                          _focusedMonth.year, _focusedMonth.month + 1, 1);
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Jours de la semaine
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
          const SizedBox(height: 10),
          const Divider(color: _roseSoft, height: 1),
          const SizedBox(height: 12),

          // Grille du Mois avec AnimatedSwitcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: GridView.builder(
              key: ValueKey(_focusedMonth),
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
                final isSelected = _isSameDay(cellDate, _selectedDate);
                final isToday = _isSameDay(cellDate, today);
                final dateKey = _dateKey(cellDate);
                final dayTasks = _tasksByDate[dateKey] ?? [];
                final hasTasks = dayTasks.isNotEmpty;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = cellDate;
                    });
                  },
                  onDoubleTap: () {
                    setState(() {
                      _selectedDate = cellDate;
                    });
                    _openAddTaskModal(targetDate: cellDate);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    transform: isSelected
                        ? (Matrix4.identity()..scale(1.06))
                        : Matrix4.identity(),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [_roseBerry, Color(0xFFC76D88)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isToday ? _roseLight : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? _roseBerry
                            : (isToday ? _roseBerry : _roseSoft.withOpacity(0.7)),
                        width: isSelected ? 2.0 : (isToday ? 1.8 : 1.0),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _roseBerry.withOpacity(0.40),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isToday
                                    ? _roseBerry
                                    : const Color(0xFF381242)),
                          ),
                        ),
                        if (hasTasks) ...[
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : _roseBerry.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        isSelected ? _roseBerry : _roseBerry,
                                  ),
                                ),
                                if (dayTasks.length > 1) ...[
                                  const SizedBox(width: 2),
                                  Text(
                                    '${dayTasks.length}',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isSelected ? _roseBerry : _roseBerry,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Bouton aujourd'hui
          InkWell(
            onTap: () {
              setState(() {
                _focusedMonth = DateTime(today.year, today.month, 1);
                _selectedDate = today;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _roseLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _roseSoft),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.today_rounded, color: _roseBerry, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Revenir à Aujourd\'hui',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: _roseBerry,
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

  // 📋 Liste des tâches du jour sélectionné
  Widget _buildTaskListCard(
      List<Map<String, dynamic>> tasks, int completedCount, double progressPercent) {
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: _roseLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_available_rounded,
                    color: _roseBerry, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateHeader(_selectedDate),
                      style: const TextStyle(
                        color: _roseBerry,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${tasks.length} tâche(s) au programme',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF9E8492),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_rounded,
                    color: _roseBerry, size: 30),
                onPressed: () => _openAddTaskModal(targetDate: _selectedDate),
                tooltip: 'Ajouter une tâche',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Barre de progression rosée
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: _roseSoft.withOpacity(0.35),
              valueColor: const AlwaysStoppedAnimation<Color>(_roseBerry),
              minHeight: 9,
            ),
          ),

          const SizedBox(height: 16),

          // Liste des tâches
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.event_note_rounded,
                        color: _roseSoft, size: 38),
                    const SizedBox(height: 8),
                    Text(
                      'Rien de planifié pour le ${_formatShortDate(_selectedDate)}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _roseDeep,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Double-clique sur la case ou appuie sur le bouton ci-dessous !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFB59AA7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _openAddTaskModal(targetDate: _selectedDate),
                      icon: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 18),
                      label: Text(
                          'Planifier pour le ${_formatShortDate(_selectedDate)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _roseBerry,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...tasks.map((task) {
              final isDone = task['completed'] as bool;
              final iconData = _safeIcon(task['icon'], Icons.task_alt_rounded);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDone ? _roseLight.withOpacity(0.5) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDone
                        ? _roseSoft.withOpacity(0.5)
                        : _roseSoft.withOpacity(0.9),
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: GestureDetector(
                    onTap: () => _toggleTask(task['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? _roseBerry : Colors.white,
                        border: Border.all(
                          color: isDone ? _roseBerry : _roseSoft,
                          width: 1.8,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 17)
                          : null,
                    ),
                  ),
                  title: Row(
                    children: [
                      Icon(iconData, size: 15, color: isDone ? const Color(0xFFB59AA7) : _roseBerry),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task['text'],
                          style: TextStyle(
                            color: isDone
                                ? const Color(0xFFB59AA7)
                                : const Color(0xFF381242),
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            fontSize: 14,
                            fontWeight: isDone ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    task['category'] ?? 'Général',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: _roseDeep,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFCF8096), size: 18),
                    onPressed: () => _deleteTask(task['id']),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // 💖 Humeur & Hydratation (Sans Emojis)
  Widget _buildMoodAndHydrationCard() {
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
          // Humeur du jour
          const Row(
            children: [
              Icon(Icons.sentiment_satisfied_alt, color: _roseBerry, size: 20),
              SizedBox(width: 8),
              Text(
                'Ton Humeur du Jour',
                style: TextStyle(
                  color: _roseBerry,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moods.map((m) {
              final name = m['name'] as String;
              final icon = _safeIcon(m['icon'], Icons.sentiment_satisfied_rounded);
              final isSelected = _selectedMood == name;
              return InkWell(
                onTap: () {
                  setState(() => _selectedMood = name);
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _roseBerry : _roseLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _roseBerry : _roseSoft,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected ? Colors.white : _roseBerry,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _roseBerry,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),
          const Divider(color: _roseSoft),
          const SizedBox(height: 10),

          // Objectif Hydratation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.water_drop_rounded,
                          color: Color(0xFF3182CE), size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Objectif Hydratation (1.5L)',
                        style: TextStyle(
                          color: Color(0xFF2B6CB0),
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_waterCups / 8 verres d\'eau bus',
                    style: const TextStyle(
                        color: Color(0xFF4A5568), fontSize: 12.5),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_waterCups < 8) _waterCups++;
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                label: const Text('+1 Verre',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3182CE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
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

  String _formatFullDate(DateTime date) {
    final days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
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
    return "${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}";
  }

  String _formatShortDate(DateTime date) {
    final months = [
      'Janv.',
      'Févr.',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juil.',
      'Août',
      'Sept.',
      'Oct.',
      'Nov.',
      'Déc.'
    ];
    return "${date.day} ${months[date.month - 1]}";
  }

  String _formatDateHeader(DateTime date) {
    final today = DateTime.now();
    if (_isSameDay(date, today)) {
      return "Aujourd'hui";
    } else if (_isSameDay(date, today.add(const Duration(days: 1)))) {
      return "Demain";
    } else {
      return _formatFullDate(date);
    }
  }
}
