import 'package:flutter/material.dart';
import '../services/post_api_service.dart';
import 'edit_post_page.dart'; // Importez la page d'édition

class CurrentUserPostsPage extends StatefulWidget {
  final int userId;
  final String userEmail;

  const CurrentUserPostsPage({
    super.key,
    required this.userId,
    required this.userEmail,
  });

  @override
  State<CurrentUserPostsPage> createState() => _CurrentUserPostsPageState();
}

class _CurrentUserPostsPageState extends State<CurrentUserPostsPage> {
  final PostApiService _postService = PostApiService();
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print("📥 Chargement des posts de l'utilisateur: ${widget.userId}");
      final response = await _postService.getPostsByUser(widget.userId);

      if (response["status"] == true) {
        setState(() {
          _posts = response["posts"] ?? [];
        });
        print("✅ ${_posts.length} posts chargés pour l'utilisateur");
      } else {
        setState(() {
          _errorMessage = response["message"] ?? "Erreur inconnue";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  void _deletePost(int postId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la publication"),
        content: const Text("Voulez-vous vraiment supprimer cette publication ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(postId);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int postId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      print("🗑️ Tentative de suppression du post: $postId");
      final response = await _postService.deletePost(postId, widget.userId);

      if (response["status"] == true) {
        // Supprimer le post de la liste locale
        setState(() {
          _posts.removeWhere((post) => post['id'] == postId);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Publication supprimée avec succès"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        print("✅ Post supprimé avec succès");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Erreur lors de la suppression"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        print("❌ Erreur suppression: ${response["message"]}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print("❌ Exception suppression: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editPost(Map<String, dynamic> post) {
    print("✏️ Modification du post: ${post['id']}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPostPage(
          post: post,
          userId: widget.userId,
          onPostUpdated: _loadUserPosts, // Rafraîchir la liste après modification
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int postId, String postTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation de suppression"),
        content: Text("Êtes-vous sûr de vouloir supprimer \"$postTitle\" ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(postId);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Publications"),
        backgroundColor: const Color(0xFF1A4D8C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserPosts,
            tooltip: "Actualiser",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement de vos publications...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadUserPosts,
                          child: const Text("Réessayer"),
                        ),
                      ],
                    ),
                  ),
                )
              : _posts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                            const SizedBox(height: 20),
                            const Text(
                              "Vous n'avez pas encore publié d'objets",
                              style: TextStyle(
                                fontSize: 18, 
                                color: Colors.grey,
                                fontWeight: FontWeight.w500
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Utilisez le bouton + pour ajouter votre premier objet",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Retour à l'accueil
                              },
                              child: const Text("Retour à l'accueil"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUserPosts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return _buildPostCard(post);
                        },
                      ),
                    ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec type et catégorie
            Row(
              children: [
                // Type (Perdu/Trouvé)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: post['post_type'] == 'perdu' 
                        ? Colors.orange.withOpacity(0.2) 
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post['post_type'] == 'perdu' ? '🟠 Perdu' : '🟢 Trouvé',
                    style: TextStyle(
                      color: post['post_type'] == 'perdu' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Catégorie
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post['category']?.toString() ?? 'Non catégorisé',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Titre
            Text(
              post['title']?.toString() ?? 'Sans titre',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            if (post['description'] != null && post['description'].toString().isNotEmpty)
              Text(
                post['description'].toString(),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),

            const SizedBox(height: 12),

            // Image
            if (post['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post['image'].toString(),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Image non disponible', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            // Informations localisation et date
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    post['location']?.toString().isNotEmpty == true 
                        ? post['location'].toString() 
                        : "Lieu non précisé",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),

            if (post['date_lost_found'] != null && post['date_lost_found'].toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Perdu/Trouvé le: ${_formatDate(post['date_lost_found'].toString())}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Boutons d'action (Modifier et Supprimer)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Bouton Modifier
                OutlinedButton.icon(
                  onPressed: () => _editPost(post),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Modifier"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A4D8C),
                    side: const BorderSide(color: Color(0xFF1A4D8C)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton Supprimer
                OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmation(post['id'], post['title'] ?? 'ce post'),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Supprimer"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date de publication
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Publié le: ${_formatDate(post['created_at'].toString())}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}