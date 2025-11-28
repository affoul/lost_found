import 'package:flutter/material.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'add_post_page.dart';
import 'post_page.dart';
import 'current_user_posts_page.dart';
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
    print("🔍 Chargement des infos utilisateur pour: ${widget.email}");
    
    try {
      final response = await _authService.getUser(widget.email);

      if (response['status'] == true) {
        setState(() {
          currentUser = response['user'];
          errorMessage = '';
        });
        print("✅ Utilisateur chargé: ${currentUser?['fullname']} (ID: ${currentUser?['id']})");
      } else {
        setState(() {
          errorMessage = response['message'] ?? "Erreur lors du chargement";
        });
        print("❌ Erreur chargement utilisateur: $errorMessage");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur: $e";
      });
      print("❌ Exception chargement utilisateur: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🏠 HomePage - currentUser ID: ${currentUser?['id']}");
    
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.search, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lost & Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'ISET Kairouan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A4D8C),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPostPressed,
        backgroundColor: const Color(0xFF1A4D8C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de votre profil...'),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadCurrentUser,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return PostPage(
      excludeUserId: currentUser?['id'],
      pageTitle: "Objets perdus & trouvés",
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              currentUser?['fullname'] ?? 'Utilisateur',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(currentUser?['email'] ?? widget.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            decoration: const BoxDecoration(color: Color(0xFF1A4D8C)),
          ),

          // Accueil
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF1A4D8C)),
            title: const Text("Accueil"),
            onTap: () {
              Navigator.pop(context);
              setState(() {});
            },
          ),

          // Mes publications
          ListTile(
            leading: const Icon(Icons.list_alt, color: Colors.orange),
            title: const Text("Mes publications"),
            onTap: () {
              Navigator.pop(context);
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CurrentUserPostsPage(
                      userId: currentUser!['id'],
                      userEmail: currentUser!['email'],
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Erreur: utilisateur non chargé")),
                );
              }
            },
          ),

          // Profil
          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text("Profil"),
            onTap: () {
              Navigator.pop(context);
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      id: currentUser!['id'],
                      fullname: currentUser!['fullname'],
                      email: currentUser!['email'],
                      telephone: currentUser!['telephone'],
                      filiere: currentUser!['filiere'],
                      niveau: currentUser!['niveau'],
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Erreur: profil non chargé")),
                );
              }
            },
          ),

          const Spacer(),

          // Déconnexion
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _onAddPostPressed() {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur: utilisateur introuvable")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPostPage(
          userId: currentUser!['id'],
          userEmail: currentUser!['email'],
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}