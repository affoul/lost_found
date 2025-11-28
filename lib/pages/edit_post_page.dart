import 'package:flutter/material.dart';
import '../services/post_api_service.dart';

class EditPostPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final int userId;
  final VoidCallback? onPostUpdated;

  const EditPostPage({
    super.key,
    required this.post,
    required this.userId,
    this.onPostUpdated,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final PostApiService _postService = PostApiService();
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de formulaire
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;

  String? _selectedCategory; // Changé en String? nullable
  String _selectedPostType = '';
  bool _isLoading = false;

  // Liste des catégories disponibles
  final List<String> _categories = [
    'Téléphone',
    'Clés',
    'Portefeuille',
    'Sac',
    'Lunettes',
    'Documents',
    'Livre',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs actuelles du post
    _titleController = TextEditingController(text: widget.post['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.post['description'] ?? '');
    _locationController = TextEditingController(text: widget.post['location'] ?? '');
    _dateController = TextEditingController(text: widget.post['date_lost_found'] ?? '');
    
    // CORRECTION ICI : Gérer la valeur nullable
    final categoryFromPost = widget.post['category']?.toString() ?? '';
    _selectedCategory = categoryFromPost.isNotEmpty && _categories.contains(categoryFromPost) 
        ? categoryFromPost 
        : null;
    
    _selectedPostType = widget.post['post_type']?.toString() ?? 'perdu';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;

    // CORRECTION : Valider que la catégorie est sélectionnée
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez choisir une catégorie"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _postService.updatePost(
        postId: widget.post['id'],
        userId: widget.userId,
        title: _titleController.text.trim(),
        category: _selectedCategory!, // On est sûr que ce n'est pas null ici
        postType: _selectedPostType,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        dateLostFound: _dateController.text.trim(),
      );

      if (response["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Post mis à jour avec succès"),
            backgroundColor: Colors.green,
          ),
        );
        
        // Appeler le callback pour rafraîchir la liste
        widget.onPostUpdated?.call();
        
        // Retourner à la page précédente
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Erreur lors de la mise à jour"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier la publication"),
        backgroundColor: const Color(0xFF1A4D8C),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Type de post (Perdu/Trouvé)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Type d'annonce",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                              title: const Text('🟠 Perdu'),
                              value: 'perdu',
                              groupValue: _selectedPostType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPostType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              title: const Text('🟢 Trouvé'),
                              value: 'trouvé',
                              groupValue: _selectedPostType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPostType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CORRECTION : DropdownButtonFormField avec gestion null
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Catégorie *",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Choisir une catégorie",
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        items: [
                          // Ajouter un élément vide pour la sélection initiale
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text("Choisir une catégorie", style: TextStyle(color: Colors.grey)),
                          ),
                          ..._categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez choisir une catégorie';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Titre *",
                  border: OutlineInputBorder(),
                  hintText: "Ex: iPhone 13 perdu",
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  hintText: "Décrivez l'objet en détail...",
                ),
                maxLines: 3,
                maxLength: 500,
              ),

              const SizedBox(height: 16),

              // Localisation
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Lieu",
                  border: OutlineInputBorder(),
                  hintText: "Ex: Bibliothèque, Amphi A, Restaurant...",
                ),
                maxLength: 100,
              ),

              const SizedBox(height: 16),

              // Date
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: "Date de perte/trouvaille",
                  border: OutlineInputBorder(),
                  hintText: "YYYY-MM-DD",
                ),
                maxLength: 10,
              ),

              const SizedBox(height: 24),

              // Bouton de mise à jour
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A4D8C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 8),
                          Text("Mise à jour..."),
                        ],
                      )
                    : const Text("Mettre à jour la publication"),
              ),

              const SizedBox(height: 8),

              // Bouton Annuler
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Annuler"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}