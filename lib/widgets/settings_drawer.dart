import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class SettingsDrawer extends StatefulWidget {
  final AIService aiService;
  final VoidCallback onClearHistory;

  const SettingsDrawer({
    Key? key,
    required this.aiService,
    required this.onClearHistory,
  }) : super(key: key);

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  final _apiKeyController = TextEditingController();
  String _selectedModel = 'gemini-1.5-flash';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final apiKey = await widget.aiService.getApiKey();
    if (apiKey != null) {
      _apiKeyController.text = apiKey;
    }
    setState(() {
      _selectedModel = widget.aiService.selectedModel;
    });
  }

  Future<void> _saveSettings() async {
    await widget.aiService.saveApiKey(_apiKeyController.text.trim());
    await widget.aiService.saveModel(_selectedModel);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres enregistrés avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.settings_suggest_rounded, size: 32, color: Colors.indigo),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Paramètres du Chatbot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Configuration API & IA',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Clé API Google Gemini',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Collez votre clé API (ex: AIzaSy...)',
                      prefixIcon: const Icon(Icons.key_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Obtenez une clé gratuite sur aistudio.google.com',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Modèle d\'IA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedModel,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'gemini-1.5-flash',
                        child: Text('Gemini 1.5 Flash (Rapide & Gratuit)'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-1.5-pro',
                        child: Text('Gemini 1.5 Pro (Avancé)'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-2.0-flash',
                        child: Text('Gemini 2.0 Flash (Nouvelle génération)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedModel = value);
                      }
                    },
                  ),
                  const Divider(height: 32),
                  ListTile(
                    leading: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                    title: const Text('Effacer l\'historique', style: TextStyle(color: Colors.redAccent)),
                    subtitle: const Text('Supprime les messages en cours'),
                    onTap: () {
                      widget.onClearHistory();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Historique effacé.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Enregistrer les modifications'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
