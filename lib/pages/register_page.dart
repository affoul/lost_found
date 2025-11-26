import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _filiereController = TextEditingController();
  final _niveauController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final AuthApiService _authService = AuthApiService();

  final List<String> _filieres = [
    'Informatique',
    'Génie Mécanique',
    'Génie Électrique',
    'Gestion',
    'Commerce'
  ];

  final List<String> _niveaux = [
    '1ère année',
    '2ème année',
    '3ème année',
    'Master 1',
    'Master 2'
  ];

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
                'Inscription Étudiant',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A4D8C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rejoignez la communauté ISET',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _buildRegisterForm(),
              const SizedBox(height: 40),
              _buildCopyright(),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Logo Section
  Widget _buildLogoSection() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png', // chemin vers ton logo
          width: 120,
          height: 120,
        ),
        const SizedBox(height: 16),
        const Text(
          'ISET CAMPUS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A4D8C),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Portail Étudiant',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
              controller: _fullnameController,
              label: 'Nom complet',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) return "Veuillez entrer votre nom complet";
                if (value.length < 3) return "Le nom doit contenir au moins 3 caractères";
                return null;
              }),
          const SizedBox(height: 16),
          // Email: n'importe quel email
          _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) return "Veuillez entrer votre email";
                if (!value.contains('@')) return "Email invalide";
                return null;
              }),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _telephoneController,
              label: 'Numéro de téléphone',
              icon: Icons.phone_iphone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) return "Veuillez entrer votre numéro";
                if (value.length < 8) return "Numéro de téléphone invalide";
                return null;
              }),
          const SizedBox(height: 16),
          _buildDropdownField(controller: _filiereController, label: 'Filière', icon: Icons.school, items: _filieres),
          const SizedBox(height: 16),
          _buildDropdownField(controller: _niveauController, label: 'Niveau d\'étude', icon: Icons.grade, items: _niveaux),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A4D8C)))
              : _buildRegisterButton(),
          const SizedBox(height: 20),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: const Color(0xFF1A4D8C)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A4D8C), width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({required TextEditingController controller, required String label, required IconData icon, required List<String> items}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: const Color(0xFF1A4D8C)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A4D8C), width: 2)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => controller.text = v!),
        validator: (value) => value == null || value.isEmpty ? "Veuillez sélectionner $label" : null,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1A4D8C)),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF1A4D8C)),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A4D8C), width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Veuillez entrer un mot de passe";
          if (value.length < 6) return "Le mot de passe doit contenir au moins 6 caractères";
          return null;
        },
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFF1A4D8C), Color(0xFF2E7D32)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text("S'inscrire", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Déjà inscrit ? ", style: TextStyle(color: Colors.grey)),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          child: const Text(
            "Se connecter",
            style: TextStyle(color: Color(0xFF1A4D8C), fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  Widget _buildCopyright() {
    return const Column(
      children: [
        Divider(color: Colors.grey),
        SizedBox(height: 16),
        Text('© 2024 ISET Campus - Tous droits réservés', style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 4),
        Text('Version Étudiant 2.0.0', style: TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final response = await _authService.register(
        fullname: _fullnameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        telephone: _telephoneController.text.trim(),
        filiere: _filiereController.text.trim(),
        niveau: _niveauController.text.trim(),
      );
      setState(() => _isLoading = false);

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Inscription réussie ! Redirection..."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ?? "Erreur lors de l'inscription"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}
