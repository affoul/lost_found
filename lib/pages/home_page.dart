import 'package:flutter/material.dart';
import 'login_page.dart';
import 'profile_page.dart';
import '../services/auth_api_service.dart';

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({super.key, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? currentUser;
  bool isLoading = true;
  String errorMessage = '';
  final AuthApiService _authService = AuthApiService();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final response = await _authService.getUser(widget.email);
    setState(() {
      if (response['status'] == true && response['user'] != null) {
        currentUser = response['user'];
      } else {
        errorMessage = response['message'] ?? "Erreur lors du chargement";
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil ISET'),
        backgroundColor: const Color(0xFF1A4D8C),
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : _buildWelcomeMessage(),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône de bienvenue
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1A4D8C),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.school,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Message de bienvenue principal
          Text(
            'Bienvenue sur',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
              fontWeight: FontWeight.w300,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'ISET CAMPUS',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A4D8C),
              letterSpacing: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sous-titre
          const Text(
            'Votre plateforme étudiante',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Message personnalisé
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 40,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isLoading 
                        ? 'Chargement de votre profil...'
                        : currentUser != null
                            ? 'Heureux de vous revoir, ${currentUser!['fullname']}!'
                            : 'Bienvenue dans votre espace personnel!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A4D8C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Utilisez le menu de navigation pour explorer les fonctionnalités',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Indication pour le menu
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu, color: Color(0xFF1A4D8C)),
              SizedBox(width: 8),
              Text(
                'Ouvrez le menu pour naviguer',
                style: TextStyle(
                  color: Color(0xFF1A4D8C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              currentUser?['fullname'] ?? 'Profil Utilisateur',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(currentUser?['email'] ?? widget.email),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF1A4D8C),
              ),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1A4D8C),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF1A4D8C)),
            title: const Text('Accueil'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF1A4D8C)),
            title: const Text('Profil'),
            onTap: () async {
              Navigator.pop(context);
              // Recharger les données avant d'ouvrir le profil
              await _loadCurrentUser();
              
              if (currentUser != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      id: currentUser!['id'],
                      fullname: currentUser!['fullname'] ?? '',
                      email: currentUser!['email'] ?? '',
                      telephone: currentUser!['telephone'] ?? '',
                      filiere: currentUser!['filiere'] ?? '',
                      niveau: currentUser!['niveau'] ?? '',
                    ),
                  ),
                );
                // Rafraîchir les données après retour du profil
                await _loadCurrentUser();
              }
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}