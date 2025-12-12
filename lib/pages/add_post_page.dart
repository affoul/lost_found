import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/post_api_service.dart';

class AddPostPage extends StatefulWidget {
  final int userId;
  final String userEmail;

  const AddPostPage({super.key, required this.userId, required this.userEmail});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final PostApiService _postService = PostApiService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  String title = "";
  String description = "";
  String location = "";
  String category = "";
  String postType = "perdu";
  DateTime? dateLostFound;

  bool _isLoading = false;

  // --------------------------
  // Sélection image
  // --------------------------
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la sélection d'image")),
      );
    }
  }

  // --------------------------
  // Publication - 
  // --------------------------
  Future<void> submitPost() async {
    if (!_formKey.currentState!.validate()) {
      print("❌ Validation du formulaire échouée");
      return;
    }
    
    if (_selectedImage == null) {
      print("❌ Aucune image sélectionnée");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une image")),
      );
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });

  
    try {
      // Test de connexion d'abord
      print("🔍 Test de connexion...");
      final testResult = await _postService.testConnection();
      print("🔍 Résultat test connexion: $testResult");

      if (!testResult["status"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Problème de connexion: ${testResult["message"]}")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Envoi du post
      print("📤 Envoi du post...");
      final response = await _postService.addPost(
        userId: widget.userId,
        title: title,
        description: description,
        category: category,
        postType: postType,
        location: location,
        dateLostFound: dateLostFound != null ? DateFormat("yyyy-MM-dd").format(dateLostFound!) : "",
        imageFile: _selectedImage!,
      );

      print("📨 Réponse finale reçue: $response");

      if (response["status"] == true) {
        print("✅ Publication réussie!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Publication ajoutée avec succès")),
        );
        Navigator.pop(context, true); // Retour avec succès
      } else {
        print("❌ Échec publication: ${response["message"]}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Erreur inconnue"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("💥 ERREUR CRITIQUE dans submitPost: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur critique: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --------------------------
  // UI
  // --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une publication"),
        backgroundColor: const Color(0xFF1A4D8C),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // IMAGE
                  GestureDetector(
                    onTap: _isLoading ? null : pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                        color: _isLoading ? Colors.grey[200] : null,
                      ),
                      child: _selectedImage == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text("Cliquez pour choisir une image"),
                                ],
                              ),
                            )
                          : Stack(
                              children: [
                                Image.file(_selectedImage!, fit: BoxFit.cover),
                                if (_isLoading)
                                  Container(
                                    color: Colors.black54,
                                    child: const Center(
                                      child: CircularProgressIndicator(color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TITRE
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Titre*",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                    onSaved: (v) => title = v!,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 15),

                  // DESCRIPTION
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    onSaved: (v) => description = v ?? "",
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 15),

                  // LIEU
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Lieu*",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                    onSaved: (v) => location = v!,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 15),

                  // CATÉGORIE
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Catégorie* (ex: smartphone, carte étudiant...)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                    onSaved: (v) => category = v!,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 15),

                  // TYPE : perdu / trouvé
                  DropdownButtonFormField<String>(
                    value: postType,
                    decoration: const InputDecoration(
                      labelText: "Type*",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "perdu", child: Text("Objet perdu")),
                      DropdownMenuItem(value: "trouve", child: Text("Objet trouvé")),
                    ],
                    onChanged: _isLoading ? null : (v) => setState(() => postType = v!),
                  ),
                  const SizedBox(height: 15),

                  // DATE
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Date",
                      border: const OutlineInputBorder(),
                      suffixIcon: _isLoading 
                          ? const Icon(Icons.lock)
                          : IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                  initialDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => dateLostFound = picked);
                                }
                              },
                            ),
                    ),
                    controller: TextEditingController(
                      text: dateLostFound == null
                          ? ""
                          : DateFormat("yyyy-MM-dd").format(dateLostFound!),
                    ),
                    enabled: false, // Toujours en lecture seule
                  ),
                  const SizedBox(height: 25),

                  // BOUTON
                  ElevatedButton(
                    onPressed: _isLoading ? null : submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A4D8C),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("Publier"),
                  ),
                ],
              ),
            ),
          ),

          // Overlay de chargement
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Publication en cours...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}