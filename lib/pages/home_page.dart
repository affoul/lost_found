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
        title: const Text('Accueil'),
        backgroundColor: const Color(0xFF1A4D8C),
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                currentUser != null
                    ? 'Bienvenue, ${currentUser!['fullname']} !'
                    : errorMessage,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A4D8C),
                ),
                textAlign: TextAlign.center,
              ),
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
            onTap: () {
              Navigator.pop(context);
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      id: currentUser!['id'], // CORRECTION: Passer l'ID
                      fullname: currentUser!['fullname'] ?? '',
                      email: currentUser!['email'] ?? '',
                      telephone: currentUser!['telephone'] ?? '',
                      filiere: currentUser!['filiere'] ?? '',
                      niveau: currentUser!['niveau'] ?? '',
                    ),
                  ),
                );
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