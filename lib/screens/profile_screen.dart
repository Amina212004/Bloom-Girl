import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late int _cycleLength;
  late int _periodDuration;
  late String _selectedAvatar;
  late bool _waterReminder;
  late bool _periodReminder;
  late DateTime _lastPeriodDate;

  final List<Map<String, dynamic>> _availableAvatars = [
    {
      'id': 'princesse',
      'label': 'Princesse',
      'icon': Icons.auto_awesome_rounded,
      'gradient': [const Color(0xFF8E24AA), const Color(0xFFE5A93B)],
    },
    {
      'id': 'fleur',
      'label': 'Fleur Céleste',
      'icon': Icons.local_florist_rounded,
      'gradient': [const Color(0xFFE56B85), const Color(0xFFFFA07A)],
    },
    {
      'id': 'diamant',
      'label': 'Diamant Rose',
      'icon': Icons.diamond_rounded,
      'gradient': [const Color(0xFFD81B60), const Color(0xFFF48FB1)],
    },
    {
      'id': 'papillon',
      'label': 'Papillon',
      'icon': Icons.favorite_rounded,
      'gradient': [const Color(0xFF805AD5), const Color(0xFFF2C7D0)],
    },
    {
      'id': 'lumiere',
      'label': 'Lumière Gold',
      'icon': Icons.light_mode_rounded,
      'gradient': [const Color(0xFFDD6B20), const Color(0xFFE5A93B)],
    },
    {
      'id': 'deesse',
      'label': 'Déesse',
      'icon': Icons.spa_rounded,
      'gradient': [const Color(0xFF2E7D32), const Color(0xFF81C784)],
    },
  ];

  static const Color _roseBerry = Color(0xFFA04566);
  static const Color _roseSoft = Color(0xFFF2C7D0);
  static const Color _roseLight = Color(0xFFFFF0F4);
  static const Color _roseDeep = Color(0xFF7A2B49);
  static const Color _goldAccent = Color(0xFFE5A93B);

  @override
  void initState() {
    super.initState();
    final profile = _userService.profile;
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _ageController = TextEditingController(text: profile.age.toString());
    _cycleLength = profile.cycleLength;
    _periodDuration = profile.periodDuration;

    // Harmonisation de l'avatar initial
    _selectedAvatar = profile.avatar;
    if (!_availableAvatars.any((a) => a['id'] == _selectedAvatar)) {
      _selectedAvatar = 'princesse';
    }

    _waterReminder = profile.waterReminder;
    _periodReminder = profile.periodReminder;
    // Null-safe : si pas encore configuré, on pré-sélectionne aujourd'hui
    _lastPeriodDate = profile.lastPeriodDate ?? DateTime.now();
  }

  Future<void> _saveChanges() async {
    final updated = _userService.profile.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 19,
      avatar: _selectedAvatar,
      cycleLength: _cycleLength,
      periodDuration: _periodDuration,
      waterReminder: _waterReminder,
      periodReminder: _periodReminder,
      lastPeriodDate: _lastPeriodDate,
      hasSetupCycle: true,
    );

    await _userService.updateProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Ton profil a été mis à jour avec succès ! ✨',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            ],
          ),
          backgroundColor: _roseBerry,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _roseBerry,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF381242),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _lastPeriodDate = picked;
      });
    }
  }

  Map<String, dynamic> _getSelectedAvatarData() {
    for (var av in _availableAvatars) {
      if (av['id'] == _selectedAvatar) return av;
    }
    return _availableAvatars.first;
  }

  @override
  Widget build(BuildContext context) {
    final currentAvatarData = _getSelectedAvatarData();
    final avatarGradient = currentAvatarData['gradient'] as List<Color>;
    final avatarIcon = currentAvatarData['icon'] as IconData;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 95),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🌸 HERO CARD ULTRA-LUXE (SANS MOTS VIP)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7A2B49),
                    _roseBerry,
                    const Color(0xFFD67397),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32.0),
                boxShadow: [
                  BoxShadow(
                    color: _roseBerry.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Halo d'Avatar Majestueux
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _goldAccent,
                          Colors.white,
                          _goldAccent.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: avatarGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        avatarIcon,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nom de l'utilisatrice
                  Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : 'Rose',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    _emailController.text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.90),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 👑 CHOIX DU STYLE D'AVATAR HAUT DE GAMME
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(color: _roseSoft.withOpacity(0.8), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: _roseBerry.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _roseLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.style_rounded,
                            color: _roseBerry, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Style & Aura de ton profil',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: _roseBerry,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Grille des Styles d'Avatars Éléguants
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _availableAvatars.length,
                    itemBuilder: (context, index) {
                      final av = _availableAvatars[index];
                      final id = av['id'] as String;
                      final label = av['label'] as String;
                      final icon = av['icon'] as IconData;
                      final grad = av['gradient'] as List<Color>;
                      final isSelected = _selectedAvatar == id;

                      return InkWell(
                        onTap: () => setState(() => _selectedAvatar = id),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(colors: grad)
                                : null,
                            color: isSelected ? null : _roseLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? _goldAccent : _roseSoft,
                              width: isSelected ? 2.2 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: grad.first.withOpacity(0.40),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icon,
                                size: 28,
                                color: isSelected ? Colors.white : _roseBerry,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected ? Colors.white : _roseDeep,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 👤 INFORMATIONS PERSONNELLES
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(color: _roseSoft.withOpacity(0.8), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: _roseBerry.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _roseLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: _roseBerry, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Informations Personnelles',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: _roseBerry,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF381242)),
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      labelStyle: const TextStyle(color: _roseDeep),
                      prefixIcon: const Icon(Icons.edit_rounded,
                          color: _roseBerry, size: 18),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            const BorderSide(color: _roseBerry, width: 1.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: _roseSoft),
                      ),
                      filled: true,
                      fillColor: _roseLight.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF381242)),
                    decoration: InputDecoration(
                      labelText: 'Âge',
                      labelStyle: const TextStyle(color: _roseDeep),
                      prefixIcon: const Icon(Icons.cake_rounded,
                          color: _roseBerry, size: 18),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            const BorderSide(color: _roseBerry, width: 1.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: _roseSoft),
                      ),
                      filled: true,
                      fillColor: _roseLight.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 💖 PARAMÈTRES DU CYCLE
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(color: _roseSoft.withOpacity(0.8), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: _roseBerry.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _roseLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: _roseBerry, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Paramètres du Cycle',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: _roseBerry,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Durée moyenne du cycle :',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF555555)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _roseLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _roseSoft),
                        ),
                        child: Text(
                          '$_cycleLength jours',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: _roseBerry),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _cycleLength.toDouble(),
                    min: 21,
                    max: 35,
                    divisions: 14,
                    activeColor: _roseBerry,
                    inactiveColor: _roseSoft.withOpacity(0.4),
                    onChanged: (val) =>
                        setState(() => _cycleLength = val.round()),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Durée de tes règles :',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF555555)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _roseLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _roseSoft),
                        ),
                        child: Text(
                          '$_periodDuration jours',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: _roseBerry),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _periodDuration.toDouble(),
                    min: 3,
                    max: 8,
                    divisions: 5,
                    activeColor: _roseBerry,
                    inactiveColor: _roseSoft.withOpacity(0.4),
                    onChanged: (val) =>
                        setState(() => _periodDuration = val.round()),
                  ),

                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _roseLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _roseSoft),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_month_rounded,
                                  color: _roseBerry, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Dernières règles :',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: _roseDeep),
                              ),
                            ],
                          ),
                          Text(
                            '${_lastPeriodDate.day}/${_lastPeriodDate.month}/${_lastPeriodDate.year}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _roseBerry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔔 PRÉFÉRENCES & NOTIFICATIONS
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(color: _roseSoft.withOpacity(0.8), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: _roseBerry.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Rappels d\'hydratation',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.water_drop_rounded,
                          color: Color(0xFF3182CE), size: 18),
                    ),
                    value: _waterReminder,
                    activeColor: _roseBerry,
                    onChanged: (v) => setState(() => _waterReminder = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(color: _roseSoft, height: 1),
                  SwitchListTile(
                    title: const Text('Notification prévision des règles',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _roseLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active_rounded,
                          color: _roseBerry, size: 18),
                    ),
                    value: _periodReminder,
                    activeColor: _roseBerry,
                    onChanged: (v) => setState(() => _periodReminder = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // BOUTON ENREGISTRER ULTRA-LUXE
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 20),
                label: const Text(
                  'Enregistrer mes modifications',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.3,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _roseBerry,
                  elevation: 6,
                  shadowColor: _roseBerry.withOpacity(0.40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // BOUTON DÉCONNEXION ÉLÉGANT
            OutlinedButton.icon(
              onPressed: () async {
                await _userService.logout();
                widget.onLogout();
              },
              icon: const Icon(Icons.logout_rounded,
                  size: 18, color: Color(0xFFCF8096)),
              label: const Text('Se déconnecter / Changer de compte',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFFCF8096))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCF8096)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
