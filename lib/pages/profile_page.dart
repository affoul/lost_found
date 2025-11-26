import 'package:flutter/material.dart';
import 'edit_profile_page.dart';


class ProfilePage extends StatelessWidget {
  final String fullname;
  final String email;
  final String telephone;
  final String filiere;
  final String niveau;

  const ProfilePage({
    super.key,
    required this.fullname,
    required this.email,
    required this.telephone,
    required this.filiere,
    required this.niveau,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A4D8C),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    fullname: fullname,
                    email: email,
                    telephone: telephone,
                    filiere: filiere,
                    niveau: niveau,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildInfoSection(context),
            const SizedBox(height: 24),
            _buildAcademicSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    String displayName = fullname.isNotEmpty ? fullname : 'Étudiant ISET';
    String displayEmail = email.isNotEmpty ? email : 'Email non disponible';

    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A4D8C),
            const Color(0xFF1A4D8C).withOpacity(0.9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.school,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF1A4D8C),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  displayEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'ÉTUDIANT ISET',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Informations Personnelles'),
              _buildEditButton(context, 'Modifier les informations personnelles'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.person_outline,
            title: 'Nom complet',
            value: fullname.isNotEmpty ? fullname : 'Non renseigné',
            color: const Color(0xFF1A4D8C),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.email_outlined,
            title: 'Adresse email',
            value: email.isNotEmpty ? email : 'Non renseigné',
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.phone_iphone_outlined,
            title: 'Téléphone',
            value: telephone.isNotEmpty ? telephone : 'Non renseigné',
            color: const Color(0xFFD32F2F),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Informations Académiques'),
              _buildEditButton(context, 'Modifier les informations académiques'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAcademicItem(
                    icon: Icons.school_outlined,
                    title: 'Filière',
                    value: filiere.isNotEmpty ? filiere : 'Non définie',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(height: 16),
                  _buildAcademicItem(
                    icon: Icons.grade_outlined,
                    title: 'Niveau d\'étude',
                    value: niveau.isNotEmpty ? niveau : 'Non défini',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A4D8C),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, String tooltip) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A4D8C).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.edit_outlined,
          size: 18,
          color: Color(0xFF1A4D8C),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfilePage(
              fullname: fullname,
              email: email,
              telephone: telephone,
              filiere: filiere,
              niveau: niveau,
            ),
          ),
        );
      },
      tooltip: tooltip,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: value.contains('Non') ? Colors.grey : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1A4D8C).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1A4D8C),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: value.contains('Non') ? Colors.grey : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Page de modification du profil (à créer dans un fichier séparé edit_profile_page.dart)
class EditProfilePage extends StatefulWidget {
  final String fullname;
  final String email;
  final String telephone;
  final String filiere;
  final String niveau;

  const EditProfilePage({
    super.key,
    required this.fullname,
    required this.email,
    required this.telephone,
    required this.filiere,
    required this.niveau,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullnameController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _filiereController;
  late TextEditingController _niveauController;

  @override
  void initState() {
    super.initState();
    _fullnameController = TextEditingController(text: widget.fullname);
    _emailController = TextEditingController(text: widget.email);
    _telephoneController = TextEditingController(text: widget.telephone);
    _filiereController = TextEditingController(text: widget.filiere);
    _niveauController = TextEditingController(text: widget.niveau);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        backgroundColor: const Color(0xFF1A4D8C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildEditField(
                controller: _fullnameController,
                label: 'Nom complet',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom complet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: _emailController,
                label: 'Adresse email',
                icon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: _telephoneController,
                label: 'Téléphone',
                icon: Icons.phone_iphone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: _filiereController,
                label: 'Filière',
                icon: Icons.school_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre filière';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: _niveauController,
                label: 'Niveau',
                icon: Icons.grade_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre niveau';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sauvegarder les modifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A4D8C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A4D8C), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Ici vous ajouterez la logique pour sauvegarder les modifications
      // Par exemple, appeler une API pour mettre à jour le profil
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _filiereController.dispose();
    _niveauController.dispose();
    super.dispose();
  }
}