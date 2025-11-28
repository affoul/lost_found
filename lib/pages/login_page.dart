import 'dart:async';

import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _serverStatus = '🔍 Test de connexion en cours...';

  final AuthApiService _authService = AuthApiService();

  @override
  void initState() {
    super.initState();
    _testServerConnection();
  }

  Future<void> _testServerConnection() async {
    print("🚀 TEST DE CONNEXION SERVEUR...");
    
    try {
      final result = await _authService.testConnection().timeout(const Duration(seconds: 5));
      
      setState(() {
        _serverStatus = result['status'] == true 
            ? '✅ ${result['message']}' 
            : '❌ ${result['message']}';
      });
    } on TimeoutException {
      setState(() {
        _serverStatus = '⚠️ Serveur lent (timeout)';
      });
    } catch (e) {
      setState(() {
        _serverStatus = '❌ Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildLogoSection(),
              const SizedBox(height: 40),
              
              const Text(
                'Connexion Étudiant',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A4D8C),
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Plateforme Lost & Found ISET Kairouan',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              // 🔹 STATUT SERVEUR
              const SizedBox(height: 12),
              _buildServerStatus(),
              
              const SizedBox(height: 32),
              _buildLoginForm(),
              const SizedBox(height: 40),
              _buildCopyright(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerStatus() {
    Color statusColor = Colors.grey;
    if (_serverStatus.contains('✅')) statusColor = Colors.green;
    if (_serverStatus.contains('❌') || _serverStatus.contains('⚠️')) statusColor = Colors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(
            _serverStatus.contains('✅') ? Icons.check_circle : 
            _serverStatus.contains('❌') ? Icons.error : Icons.warning,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _serverStatus,
              style: TextStyle(
                color: statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_serverStatus.contains('❌') || _serverStatus.contains('⚠️'))
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _testServerConnection,
              color: statusColor,
            ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo simplifié sans loadingBuilder
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF1A4D8C).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback si l'image n'est pas trouvée
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A4D8C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 50,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'ISET KAIROUAN',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A4D8C),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
          ),
          child: const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.find_in_page, size: 16, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text('Objets Perdus', style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
                  SizedBox(width: 16),
                  Icon(Icons.search, size: 16, color: Color(0xFF1A4D8C)),
                  SizedBox(width: 8),
                  Text('Objets Trouvés', style: TextStyle(fontSize: 12, color: Color(0xFF1A4D8C))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Champ Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email universitaire',
              prefixIcon: Icon(Icons.email, color: Color(0xFF1A4D8C)),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Email requis";
              if (!value.contains('@')) return "Email invalide";
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Champ Mot de passe
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock, color: Color(0xFF1A4D8C)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF1A4D8C),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Mot de passe requis";
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // Bouton de connexion
          _isLoading
              ? const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Connexion en cours...', style: TextStyle(color: Colors.grey)),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A4D8C),
                    ),
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
          
          const SizedBox(height: 20),
          
          // Lien inscription
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Nouveau étudiant ? "),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: const Text(
                  "Créer un compte",
                  style: TextStyle(color: Color(0xFF1A4D8C), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    return const Column(
      children: [
        Divider(),
        SizedBox(height: 16),
        Text(
          '© 2024 ISET Kairouan - Plateforme Lost & Found', 
          style: TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    print("🔐 DÉBUT LOGIN - ${DateTime.now()}");

    try {
      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ).timeout(const Duration(seconds: 25));

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Connexion réussie"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(email: _emailController.text.trim()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ ${response['message'] ?? "Erreur inconnue"}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Serveur lent. Réessayez."),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erreur: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}