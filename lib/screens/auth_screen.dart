import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/user_service.dart';

enum AuthViewMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  AuthViewMode _currentMode = AuthViewMode.signIn;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeTerms = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  final UserService _userService = UserService();

  // Animation controller for the smooth wave background
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    // Vitesse ultra fluide, nette et harmonieuse (6.5s)
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  // --- Authentification Actions ---

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentMode == AuthViewMode.signUp && !_agreeTerms) {
      _showSnackbar("Veuillez accepter le traitement des données personnelles", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_currentMode == AuthViewMode.signUp) {
        await _userService.signUp(
          name: _nameController.text.trim().isEmpty ? "Utilisatrice" : _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        _showSnackbar("Inscription réussie ! Bienvenue 🌸");
      } else {
        await _userService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        _showSnackbar("Connexion réussie ! Bon retour 💕");
      }
      widget.onAuthenticated();
    } catch (e) {
      final msg = e.toString().replaceAll("Exception:", "").trim();
      setState(() => _errorMessage = msg);
      _showSnackbar(msg, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final account = await googleSignIn.signIn();
      if (account != null) {
        setState(() => _isLoading = true);
        try {
          await _userService.loginWithGoogle(
            googleEmail: account.email,
            googleName: account.displayName,
          );
          _showSnackbar("Connectée avec succès via Google ! 🌸");
          widget.onAuthenticated();
          return;
        } catch (e) {
          final errMsg = e.toString().replaceAll("Exception:", "").trim();
          _showSnackbar(errMsg.isNotEmpty ? errMsg : "Cette adresse n'est pas encore inscrite. Veuillez créer un compte d'abord.", isError: true);
          return;
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print("Google Sign-In natif indisponible/annulé, ouverture du formulaire modal : $e");
    }

    final googleEmailController = TextEditingController();
    final googleNameController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF2C7D0), Color(0xFFCF8096)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA04566).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 30)),
            ),
            const SizedBox(height: 14),
            Text(
              "Continuer avec Google",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFFA04566)),
            ),
            const SizedBox(height: 6),
            Text(
              "Entrez votre adresse Gmail déjà inscrite",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: googleNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: "Votre prénom",
                hintText: "ex: Amina",
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFA04566)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: googleEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Adresse Gmail",
                hintText: "exemple@gmail.com",
                prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFFA04566)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA04566),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: Text(
                  "Se connecter avec Google",
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final email = googleEmailController.text.trim();
      final name = googleNameController.text.trim();
      if (email.isEmpty) {
        _showSnackbar("Veuillez entrer votre adresse Gmail 🌸", isError: true);
        return;
      }
      setState(() => _isLoading = true);
      try {
        await _userService.loginWithGoogle(
          googleEmail: email,
          googleName: name.isEmpty ? null : name,
        );
        _showSnackbar("Connectée avec succès via Google ! 🌸");
        widget.onAuthenticated();
      } catch (e) {
        final errMsg = e.toString().replaceAll("Exception:", "").trim();
        _showSnackbar(errMsg.isNotEmpty ? errMsg : "Cette adresse n'est pas encore inscrite. Veuillez créer un compte d'abord.", isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? const Color(0xFFD90429) : const Color(0xFFA04566),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = _currentMode == AuthViewMode.signUp;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return SmoothWavesBackground(
            animationValue: _gradientController.value,
            child: child!,
          );
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // LA CARTE EN VERRE DÉPOLI TRANSLUCIDE (Glassmorphism)
                    // Permet aux vagues en mouvement d'être nettement visibles à travers la carte !
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.84),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.85),
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA04566).withOpacity(0.22),
                                blurRadius: 36,
                                offset: const Offset(0, 14),
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. LE LOGO FEMME AVEC PAPILLON (Coloré aux couleurs du background)
                            Center(
                              child: SizedBox(
                                width: 145,
                                height: 145,
                                child: Image.asset(
                                  'assets/images/woman_butterfly_logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, err, stack) => const Center(
                                    child: Icon(Icons.spa_rounded, color: Color(0xFFA04566), size: 64),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // 2. SÉLECTEUR D'ONGLET / TOGGLE (Connexion / Inscription)
                            Container(
                              height: 48,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7ECF0),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFF2C7D0)),
                              ),
                              child: Row(
                                children: [
                                  // Onglet Connexion
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (isSignUp) {
                                          setState(() {
                                            _currentMode = AuthViewMode.signIn;
                                            _errorMessage = null;
                                          });
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: !isSignUp
                                              ? const LinearGradient(
                                                  colors: [Color(0xFFA04566), Color(0xFFCF8096)],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                )
                                              : null,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: !isSignUp
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFFA04566).withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          "Connexion",
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: !isSignUp ? FontWeight.bold : FontWeight.w600,
                                            color: !isSignUp ? Colors.white : const Color(0xFFA04566),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Onglet Inscription
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!isSignUp) {
                                          setState(() {
                                            _currentMode = AuthViewMode.signUp;
                                            _errorMessage = null;
                                          });
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: isSignUp
                                              ? const LinearGradient(
                                                  colors: [Color(0xFFA04566), Color(0xFFCF8096)],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                )
                                              : null,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: isSignUp
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFFA04566).withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          "Inscription",
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: isSignUp ? FontWeight.bold : FontWeight.w600,
                                            color: isSignUp ? Colors.white : const Color(0xFFA04566),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Message d'erreur s'il y en a un
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFECEF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFFFCCD5)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Color(0xFFD90429), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: GoogleFonts.outfit(color: const Color(0xFFD90429), fontSize: 12.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // 3. CHAMPS DU FORMULAIRE

                            // Nom complet (uniquement pour l'inscription)
                            if (isSignUp) ...[
                              _buildInputField(
                                controller: _nameController,
                                label: "Nom complet",
                                hintText: "Ex: Sarah Benali",
                                icon: Icons.person_outline_rounded,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return "Veuillez entrer votre prénom/nom";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Champ Email
                            _buildInputField(
                              controller: _emailController,
                              label: "Email",
                              hintText: "exemple@gmail.com",
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || !val.contains('@') || !val.contains('.')) {
                                  return "Adresse email valide requise";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Champ Mot de passe
                            _buildInputField(
                              controller: _passwordController,
                              label: "Mot de passe",
                              hintText: "••••••••",
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFFA04566),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (val) {
                                if (val == null || val.length < 4) {
                                  return "Le mot de passe doit comporter au moins 4 caractères";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Options supplémentaires (Conditions ou Remember me / Mot de passe oublié)
                            if (isSignUp)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _agreeTerms,
                                      onChanged: (val) => setState(() => _agreeTerms = val ?? true),
                                      activeColor: const Color(0xFFA04566),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "J'accepte le traitement de mes données personnelles",
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: const Color(0xFF6E5664),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                              activeColor: const Color(0xFFA04566),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              "Se souvenir de moi",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF6E5664)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          _showSnackbar("Contactez l'assistance pour réinitialiser le mot de passe");
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          "Mot de passe oublié ?",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFA04566),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 22),

                            // 4. BOUTON PRINCIPAL (Dégradé A04566 -> CF8096)
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFA04566), Color(0xFFCF8096)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFA04566).withOpacity(0.38),
                                    blurRadius: 18,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleEmailAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Text(
                                        isSignUp ? "Créer mon compte" : "Se connecter",
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // SÉPARATEUR
                            Row(
                              children: [
                                const Expanded(child: Divider(color: Color(0xFFF2C7D0), thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(
                                    "ou continuer avec",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF9E8492),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider(color: Color(0xFFF2C7D0), thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // BOUTON GOOGLE
                            OutlinedButton(
                              onPressed: _isLoading ? null : _handleGoogleSignIn,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFFCF8FA),
                                side: const BorderSide(color: Color(0xFFF2C7D0), width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFF2C7D0), Color(0xFFCF8096)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'G',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Continuer avec Google",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFA04566),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                    // LE PAPILLON RÉALISTE EN HAUT À GAUCHE DE LA CARTE (Chevauchant le bord)
                    Positioned(
                      top: -42,
                      left: -28,
                      child: IgnorePointer(
                        child: Transform.rotate(
                          angle: -0.25, // Légèrement penché vers la gauche comme sur la maquette
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA04566).withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(4, 6),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/corner_butterfly.png',
                              width: 110,
                              height: 110,
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, stack) => const SizedBox(),
                            ),
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
      ),
    );
  }

  // Composant Champ de Texte Moderne
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA04566),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF381242)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFFB59AA7)),
            prefixIcon: Icon(icon, color: const Color(0xFFCF8096), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFFDF8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF2C7D0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF2C7D0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFA04566), width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD90429), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD90429), width: 1.8),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

// ====================================================================
// WIDGET D'ARRIÈRE-PLAN : VAGUES FLUIDES DE DROITE À GAUCHE 🌊🌸
// Couleurs : CF8096, A04566, F2C7D0
// Mouvement : fluide, modéré (ni trop rapide, ni trop lent)
// ====================================================================

class SmoothWavesBackground extends StatelessWidget {
  final double animationValue; // 0.0 à 1.0
  final Widget child;

  const SmoothWavesBackground({
    super.key,
    required this.animationValue,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond animé avec vagues glissant doucement de droite à gauche
        Positioned.fill(
          child: CustomPaint(
            painter: HorizontalWavesPainter(progress: animationValue),
          ),
        ),
        // Contenu principal au-dessus
        child,
      ],
    );
  }
}

class HorizontalWavesPainter extends CustomPainter {
  final double progress; // 0.0 à 1.0

  HorizontalWavesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Phase angulaire basée sur le temps (0 à 2*pi)
    final shift = progress * 2 * math.pi;

    // 1. Fond dégradé fluide dynamique avec rotation d'angle progressive
    final bgShader = LinearGradient(
      begin: Alignment(math.cos(shift) * 0.8, math.sin(shift) * 0.8 - 0.5),
      end: Alignment(-math.cos(shift) * 0.8, -math.sin(shift) * 0.8 + 0.5),
      colors: const [
        Color(0xFF8A2E4B), // Deep Framboise
        Color(0xFFA04566), // Rose Prune
        Color(0xFFC76D85), // Rose Médium
        Color(0xFFE598AA), // Rose Soft
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = bgShader);

    // 2. ORBES DE LUMIÈRE AMBIANTE (BOKEH ANIMEES - Effet 3D & Profondeur Créative)
    _drawGlowingOrb(
      canvas: canvas,
      center: Offset(
        w * 0.25 + 40 * math.cos(shift),
        h * 0.20 + 30 * math.sin(shift * 1.2),
      ),
      radius: 130,
      color: Colors.white.withOpacity(0.28),
    );

    _drawGlowingOrb(
      canvas: canvas,
      center: Offset(
        w * 0.80 + 35 * math.sin(shift),
        h * 0.45 + 45 * math.cos(shift * 0.9),
      ),
      radius: 150,
      color: const Color(0xFFFFD1DC).withOpacity(0.35),
    );

    _drawGlowingOrb(
      canvas: canvas,
      center: Offset(
        w * 0.20 + 50 * math.cos(shift * 0.8),
        h * 0.75 + 35 * math.sin(shift),
      ),
      radius: 140,
      color: const Color(0xFFF2C7D0).withOpacity(0.30),
    );

    // 3. VAGUES FLUIDES AVEC DEGRADES & LIGNES DE CRÊTE BRILLANTES
    // Vague 1 : Vague haute fluide claire
    _drawFluidRibbonWave(
      canvas: canvas,
      size: size,
      baseY: h * 0.22,
      amplitude: 45,
      frequency: 1.1,
      phase: shift,
      gradientColors: [
        const Color(0xFFFFF0F3).withOpacity(0.50),
        const Color(0xFFF2C7D0).withOpacity(0.40),
      ],
      crestColor: Colors.white.withOpacity(0.95),
      crestWidth: 3.0,
    );

    // Vague 2 : Vague médiane satinée
    _drawFluidRibbonWave(
      canvas: canvas,
      size: size,
      baseY: h * 0.45,
      amplitude: 52,
      frequency: 1.25,
      phase: shift + 1.8,
      gradientColors: [
        const Color(0xFFE890A7).withOpacity(0.45),
        const Color(0xFFCF8096).withOpacity(0.55),
      ],
      crestColor: const Color(0xFFFFF5F7).withOpacity(0.90),
      crestWidth: 2.8,
    );

    // Vague 3 : Vague profonde riche
    _drawFluidRibbonWave(
      canvas: canvas,
      size: size,
      baseY: h * 0.68,
      amplitude: 48,
      frequency: 0.95,
      phase: shift + 3.4,
      gradientColors: [
        const Color(0xFFA04566).withOpacity(0.60),
        const Color(0xFF8A2E4B).withOpacity(0.65),
      ],
      crestColor: const Color(0xFFF2C7D0).withOpacity(0.85),
      crestWidth: 2.5,
    );

    // Vague 4 : Voile de bas lumineux
    _drawFluidRibbonWave(
      canvas: canvas,
      size: size,
      baseY: h * 0.86,
      amplitude: 38,
      frequency: 1.35,
      phase: shift + 0.9,
      gradientColors: [
        const Color(0xFFF2C7D0).withOpacity(0.55),
        Colors.white.withOpacity(0.40),
      ],
      crestColor: Colors.white.withOpacity(0.95),
      crestWidth: 3.2,
    );

    // 4. MICRO-ÉTINCELLES ET PARTICULES LUMINEUSES EN FLOTTAISON
    _drawFloatingSparkles(canvas, size, shift);
  }

  void _drawGlowingOrb({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawFluidRibbonWave({
    required Canvas canvas,
    required Size size,
    required double baseY,
    required double amplitude,
    required double frequency,
    required double phase,
    required List<Color> gradientColors,
    required Color crestColor,
    required double crestWidth,
  }) {
    final path = Path();
    final crestPath = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h);
    path.lineTo(0, baseY);

    const int steps = 60;
    for (int i = 0; i <= steps; i++) {
      final x = (i / steps) * w;
      // Double sinusoïde harmonique pour un mouvement fluide et créatif
      final waveFactor = math.sin((x / w) * 2 * math.pi * frequency + phase) +
          0.25 * math.cos((x / w) * 4 * math.pi * frequency - phase);
      final y = baseY + amplitude * waveFactor;

      path.lineTo(x, y);

      if (i == 0) {
        crestPath.moveTo(x, y);
      } else {
        crestPath.lineTo(x, y);
      }
    }

    path.lineTo(w, h);
    path.close();

    // Remplissage en dégradé vertical doux
    final fillShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: gradientColors,
    ).createShader(Rect.fromLTWH(0, math.max(0, baseY - amplitude * 1.5), w, h));

    final fillPaint = Paint()..shader = fillShader;
    canvas.drawPath(path, fillPaint);

    // Ombre douce sous la crête pour accentuer le relief 3D
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.10)
      ..strokeWidth = crestWidth + 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(crestPath, shadowPaint);

    // Ligne lumineuse de crête ultra nette pour visualiser le mouvement
    final crestPaint = Paint()
      ..color = crestColor
      ..strokeWidth = crestWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(crestPath, crestPaint);
  }

  void _drawFloatingSparkles(Canvas canvas, Size size, double shift) {
    final w = size.width;
    final h = size.height;

    final particles = [
      const Offset(0.15, 0.18),
      const Offset(0.35, 0.32),
      const Offset(0.72, 0.22),
      const Offset(0.85, 0.42),
      const Offset(0.22, 0.58),
      const Offset(0.64, 0.68),
      const Offset(0.12, 0.82),
      const Offset(0.78, 0.88),
      const Offset(0.48, 0.12),
      const Offset(0.90, 0.15),
      const Offset(0.30, 0.90),
      const Offset(0.55, 0.48),
    ];

    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final offsetX = (p.dx * w + 20 * math.sin(shift + i)) % w;
      final offsetY = (p.dy * h - (shift / (2 * math.pi)) * 50 + i * 25) % h;
      final sparkleRadius = 1.8 + 1.2 * math.sin(shift * 2 + i);
      final opacity = (0.4 + 0.5 * math.sin(shift + i)).clamp(0.1, 0.9);

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(offsetX, offsetY), sparkleRadius, paint);

      if (i % 3 == 0) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFFF0F5).withOpacity(opacity * 0.45)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(offsetX, offsetY), sparkleRadius * 2.5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HorizontalWavesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
