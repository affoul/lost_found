import 'package:flutter/material.dart';
import '../services/post_api_service.dart';
import '../services/comment_api_service.dart';

class PostPage extends StatefulWidget {
  final int? userId;
  final int? excludeUserId;
  final String pageTitle;

  const PostPage({
    super.key, 
    this.userId, 
    this.excludeUserId,
    this.pageTitle = "Tous les objets"
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final PostApiService _postService = PostApiService();
  final CommentApiService _commentService = CommentApiService();
  
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  final Map<int, List<dynamic>> _postComments = {};
  final Map<int, bool> _postCommentsLoading = {};
  final Map<int, TextEditingController> _commentControllers = {};
  final Map<int, bool> _showCommentInput = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  void _cleanupResources() {
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    _commentControllers.clear();
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;
    
    _safeSetState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _getPostsBasedOnFilter();
      
      if (!mounted) return;

      if (response["status"] == true) {
        _safeSetState(() {
          _posts = response["posts"] ?? [];
        });
        
        _initializePostData();
        
        print("✅ ${_posts.length} posts chargés avec succès");
      } else {
        _safeSetState(() {
          _errorMessage = response["message"] ?? "Erreur lors du chargement";
        });
      }
    } catch (e) {
      if (!mounted) return;
      _safeSetState(() {
        _errorMessage = "Erreur de connexion: $e";
      });
    } finally {
      if (mounted) {
        _safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _getPostsBasedOnFilter() async {
    if (widget.userId != null) {
      return await _postService.getPostsByUser(widget.userId!);
    } else if (widget.excludeUserId != null) {
      return await _postService.getAllPosts(excludeUserId: widget.excludeUserId);
    } else {
      return await _postService.getAllPosts();
    }
  }

  void _initializePostData() {
    _cleanupResources();
    
    for (final post in _posts) {
      final postId = post['id'];
      _commentControllers[postId] = TextEditingController();
      _showCommentInput[postId] = false;
    }
  }

  Future<void> _loadComments(int postId) async {
    if (!mounted) return;
    
    _safeSetState(() {
      _postCommentsLoading[postId] = true;
    });

    try {
      final response = await _commentService.getComments(postId);
      
      if (!mounted) return;
      
      if (response["status"] == true) {
        _safeSetState(() {
          _postComments[postId] = response["comments"] ?? [];
        });
      }
    } catch (e) {
      print("Erreur chargement commentaires: $e");
      _showSnackBar("Erreur lors du chargement des commentaires", isError: true);
    } finally {
      if (mounted) {
        _safeSetState(() {
          _postCommentsLoading[postId] = false;
        });
      }
    }
  }

  Future<void> _addComment(int postId, int userId) async {
    final content = _commentControllers[postId]?.text.trim();
    if (content == null || content.isEmpty) {
      _showSnackBar("Le commentaire ne peut pas être vide");
      return;
    }

    try {
      final response = await _commentService.addComment(
        postId: postId,
        userId: userId,
        content: content,
      );

      if (!mounted) return;

      if (response["status"] == true) {
        _commentControllers[postId]?.clear();
        
        await _loadComments(postId);
        
        _safeSetState(() {
          _showCommentInput[postId] = false;
        });
        
        _showSnackBar("Commentaire ajouté avec succès");
      } else {
        _showSnackBar(response["message"] ?? "Erreur lors de l'ajout", isError: true);
      }
    } catch (e) {
      _showSnackBar("Erreur: $e", isError: true);
    }
  }

  Future<void> _deleteComment(int commentId, int userId, int postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le commentaire"),
        content: const Text("Voulez-vous vraiment supprimer ce commentaire ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final response = await _commentService.deleteComment(
          commentId: commentId,
          userId: userId,
        );

        if (response["status"] == true) {
          await _loadComments(postId);
          _showSnackBar("Commentaire supprimé avec succès");
        } else {
          _showSnackBar(response["message"] ?? "Erreur lors de la suppression", isError: true);
        }
      } catch (e) {
        _showSnackBar("Erreur: $e", isError: true);
      }
    }
  }

  Future<void> _editComment(int commentId, int userId, int postId, String currentContent) async {
    if (!mounted) return;

    final newContent = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: currentContent);
        return AlertDialog(
          title: const Text("Modifier le commentaire"),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Votre commentaire...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                final content = controller.text.trim();
                if (content.isNotEmpty) {
                  Navigator.of(context).pop(content);
                }
              },
              child: const Text("Modifier"),
            ),
          ],
        );
      },
    );

    if (newContent != null && newContent.isNotEmpty && mounted) {
      try {
        final response = await _commentService.updateComment(
          commentId: commentId,
          userId: userId,
          content: newContent,
        );

        if (response["status"] == true) {
          await _loadComments(postId);
          _showSnackBar("Commentaire modifié avec succès");
        } else {
          _showSnackBar(response["message"] ?? "Erreur lors de la modification", isError: true);
        }
      } catch (e) {
        _showSnackBar("Erreur: $e", isError: true);
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  String _getEmptyStateMessage() {
    if (widget.userId != null) {
      return "Vous n'avez pas encore publié d'objets";
    } else if (widget.excludeUserId != null) {
      return "Aucun objet publié par les autres utilisateurs";
    } else {
      return "Aucune publication pour le moment";
    }
  }

  void _safeSetState(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleCommentInput(int postId) {
    _safeSetState(() {
      _showCommentInput[postId] = !_showCommentInput[postId]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
        backgroundColor: const Color(0xFF1A4D8C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
            tooltip: "Actualiser",
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }
    
    if (_posts.isEmpty) {
      return _buildEmptyState();
    }
    
    return _buildPostsList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Chargement des publications...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
              onPressed: _loadPosts,
              child: const Text("Réessayer"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              _getEmptyStateMessage(),
              style: const TextStyle(
                fontSize: 18, 
                color: Colors.grey,
                fontWeight: FontWeight.w500
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (widget.userId != null)
              const Text(
                "Utilisez le bouton + pour ajouter votre premier objet",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final postId = post['id'];
    final comments = _postComments[postId] ?? [];
    final isLoadingComments = _postCommentsLoading[postId] ?? false;
    final showCommentInput = _showCommentInput[postId] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(post),
            const SizedBox(height: 12),
            _buildPostTitle(post),
            const SizedBox(height: 8),
            _buildPostDescription(post),
            const SizedBox(height: 12),
            _buildPostImage(post),
            const SizedBox(height: 12),
            _buildPostLocationInfo(post),
            const SizedBox(height: 8),
            _buildPostAuthorInfo(post),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _buildCommentsSection(postId, comments, isLoadingComments, showCommentInput),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(Map<String, dynamic> post) {
    return Row(
      children: [
        _buildPostTypeChip(post),
        const SizedBox(width: 8),
        _buildCategoryChip(post),
      ],
    );
  }

  Widget _buildPostTypeChip(Map<String, dynamic> post) {
    final isLost = post['post_type'] == 'perdu';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLost ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isLost ? '🟠 Perdu' : '🟢 Trouvé',
        style: TextStyle(
          color: isLost ? Colors.orange : Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Map<String, dynamic> post) {
    return Container(
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
    );
  }

  Widget _buildPostTitle(Map<String, dynamic> post) {
    return Text(
      post['title']?.toString() ?? 'Sans titre',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPostDescription(Map<String, dynamic> post) {
    final description = post['description']?.toString();
    if (description == null || description.isEmpty) {
      return const SizedBox();
    }
    
    return Text(
      description,
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 14,
      ),
    );
  }

  Widget _buildPostImage(Map<String, dynamic> post) {
    final imageUrl = post['image']?.toString();
    if (imageUrl == null) {
      return const SizedBox();
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
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
    );
  }

  Widget _buildPostLocationInfo(Map<String, dynamic> post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildPostAuthorInfo(Map<String, dynamic> post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Par: ${post['user_name'] ?? 'Utilisateur inconnu'}",
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          "Publié le: ${_formatDate(post['created_at'].toString())}",
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(int postId, List<dynamic> comments, bool isLoadingComments, bool showCommentInput) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentsHeader(postId, comments, isLoadingComments),
        if (comments.isNotEmpty) _buildCommentsList(comments, postId),
        if (isLoadingComments) _buildCommentsLoadingIndicator(),
        _buildCommentInputSection(postId, showCommentInput, isLoadingComments),
      ],
    );
  }

  Widget _buildCommentsHeader(int postId, List<dynamic> comments, bool isLoadingComments) {
    if (comments.isEmpty && !isLoadingComments) {
      return TextButton.icon(
        onPressed: () => _loadComments(postId),
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: const Text("Commenter"),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: Colors.grey[600],
        ),
      );
    } else if (comments.isNotEmpty) {
      return TextButton.icon(
        onPressed: () => _loadComments(postId),
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: Text("${comments.length} commentaire${comments.length > 1 ? 's' : ''}"),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: Colors.grey[600],
        ),
      );
    }
    
    return const SizedBox();
  }

  Widget _buildCommentsList(List<dynamic> comments, int postId) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return _buildCommentItem(comment, postId);
      },
    );
  }

  Widget _buildCommentsLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildCommentInputSection(int postId, bool showCommentInput, bool isLoadingComments) {
    if (showCommentInput) {
      return _buildCommentInputField(postId);
    } else if (!isLoadingComments) {
      return _buildAddCommentButton(postId);
    }
    
    return const SizedBox();
  }

  Widget _buildCommentInputField(int postId) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentControllers[postId],
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Écrivez un commentaire...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () => _addComment(postId, 1), // Remplacez par l'ID utilisateur réel
                tooltip: "Envoyer",
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => _toggleCommentInput(postId),
                tooltip: "Annuler",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddCommentButton(int postId) {
    return TextButton.icon(
      onPressed: () => _toggleCommentInput(postId),
      icon: const Icon(Icons.add_comment, size: 18),
      label: const Text("Ajouter un commentaire"),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment, int postId) {
    final isCurrentUser = comment['user_id'] == 1; // Remplacez par l'ID utilisateur réel

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comment['user_fullname'] ?? 'Utilisateur',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (isCurrentUser)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 16),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text("Modifier"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Supprimer", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    await Future.delayed(const Duration(milliseconds: 50));
                    
                    if (value == 'edit' && mounted) {
                      await _editComment(
                        comment['id'],
                        comment['user_id'],
                        postId,
                        comment['content'],
                      );
                    } else if (value == 'delete' && mounted) {
                      await _deleteComment(
                        comment['id'],
                        comment['user_id'],
                        postId,
                      );
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment['content'],
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(comment['created_at']),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}