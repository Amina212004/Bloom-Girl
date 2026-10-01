import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';
import 'time_organizer_screen.dart';
import 'cycle_tracker_screen.dart';
import 'pain_relief_screen.dart';
import 'profile_screen.dart';
import 'auth_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  const HomeNavigationScreen({Key? key}) : super(key: key);

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _currentIndex = 0;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _userService.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    _userService.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    if (mounted) setState(() {});
  }

  String _getSubtitleForIndex(int index, String userName) {
    switch (index) {
      case 0:
        return 'Bonjour $userName • Espace Chat';
      case 1:
        return 'Mon Temps • Organisation & Agenda';
      case 2:
        return 'Mon Cycle • Suivi & Prévisions';
      case 3:
        return 'SOS Respiration • Espace Apaisement';
      case 4:
        return 'Profil Personnel de $userName';
      default:
        return 'Ton espace bien-être & organisation';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_userService.isLoggedIn) {
      return AuthScreen(
        onAuthenticated: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      );
    }

    final profile = _userService.profile;

    final List<Widget> screens = [
      const ChatScreen(),
      const TimeOrganizerScreen(),
      const CycleTrackerScreen(),
      const PainReliefScreen(),
      ProfileScreen(
        onLogout: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA04566).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: const Border(
              bottom: BorderSide(color: Color(0xFFF2C7D0), width: 1.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  // Logo Avatar Femme Papillon
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 4),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA04566), Color(0xFFF2C7D0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA04566).withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2.2),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/woman_butterfly_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFFA04566),
                                size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Titre et sous-titre
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bloom Rose',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA04566),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getSubtitleForIndex(_currentIndex, profile.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8C3A5A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tag Thème
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2C7D0).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF2C7D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            color: Color(0xFFA04566), size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Rose',
                          style: TextStyle(
                            color: Color(0xFFA04566),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Menu Option Profil & Déconnexion
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF8FA),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF2C7D0)),
                      ),
                      child: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFFA04566),
                        size: 20,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (value) async {
                      if (value == 'profile') {
                        setState(() => _currentIndex = 4);
                      } else if (value == 'logout') {
                        await _userService.logout();
                        setState(() => _currentIndex = 0);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            const Icon(Icons.person_rounded,
                                color: Color(0xFFA04566), size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Mon Profil (${profile.name})',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF381242)),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded,
                                color: Colors.redAccent, size: 18),
                            SizedBox(width: 10),
                            Text(
                              'Se déconnecter',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA04566).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFA04566),
          unselectedItemColor: const Color(0xFF9E8492),
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10.5),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'Lily Chat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Mon Temps',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline_rounded),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Mon Cycle',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.air_rounded),
              activeIcon: Icon(Icons.air_rounded),
              label: 'Respiration',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              activeIcon: const Icon(Icons.person_rounded),
              label: profile.name,
            ),
          ],
        ),
      ),
    );
  }
}
