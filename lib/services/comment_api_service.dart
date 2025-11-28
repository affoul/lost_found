import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart';

class CommentApiService {
  // 🔹 RÉCUPÉRER LES COMMENTAIRES D'UN POST
  Future<Map<String, dynamic>> getComments(int postId) async {
    try {
      final url = Uri.parse("$baseUrl/get_comments.php?post_id=$postId");
      print("📥 Chargement des commentaires pour le post: $postId");

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print("📤 Réponse commentaires - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == true) {
          print("✅ ${data['count'] ?? 0} commentaires chargés avec succès");
          return {
            "status": true,
            "comments": data['comments'] ?? [],
            "message": data['message'] ?? "Commentaires récupérés",
            "count": data['count'] ?? 0
          };
        } else {
          return {
            "status": false,
            "comments": [],
            "message": data['message'] ?? "Erreur inconnue",
            "count": 0
          };
        }
      } else if (response.statusCode == 404) {
        return {
          "status": false,
          "comments": [],
          "message": "Erreur 404 - Fichier API non trouvé",
          "count": 0
        };
      } else {
        return {
          "status": false,
          "comments": [],
          "message": "Erreur HTTP ${response.statusCode}",
          "count": 0
        };
      }
    } on TimeoutException {
      return {
        "status": false,
        "comments": [],
        "message": "Timeout - Le serveur met trop de temps à répondre",
        "count": 0
      };
    } catch (e) {
      print("❌ Erreur getComments: $e");
      return {
        "status": false,
        "comments": [],
        "message": "Erreur de connexion: ${e.toString()}",
        "count": 0
      };
    }
  }

  // 🔹 AJOUTER UN COMMENTAIRE
  Future<Map<String, dynamic>> addComment({
    required int postId,
    required int userId,
    required String content,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/add_comment.php");
      print("💬 Ajout d'un commentaire - Post: $postId, User: $userId");

      // Préparer les données
      final Map<String, dynamic> commentData = {
        'post_id': postId,
        'user_id': userId,
        'content': content,
      };
      
      print("📝 Données du commentaire: $commentData");
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(commentData),
      ).timeout(const Duration(seconds: 15));

      print("📤 Réponse ajout commentaire - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          "status": false,
          "message": "Erreur HTTP ${response.statusCode}"
        };
      }
    } on TimeoutException {
      return {
        "status": false,
        "message": "Timeout - Le serveur met trop de temps à répondre"
      };
    } catch (e) {
      print("❌ Erreur addComment: $e");
      return {
        "status": false,
        "message": "Erreur: ${e.toString()}"
      };
    }
  }

  // 🔹 MODIFIER UN COMMENTAIRE
  Future<Map<String, dynamic>> updateComment({
    required int commentId,
    required int userId,
    required String content,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/update_comment.php");
      print("✏️ Modification du commentaire: $commentId par l'utilisateur: $userId");

      // Préparer les données
      final Map<String, dynamic> commentData = {
        'comment_id': commentId,
        'user_id': userId,
        'content': content,
      };
      
      print("📝 Données de modification: $commentData");
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(commentData),
      ).timeout(const Duration(seconds: 15));

      print("📤 Réponse modification commentaire - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          "status": false,
          "message": "Erreur HTTP ${response.statusCode}"
        };
      }
    } on TimeoutException {
      return {
        "status": false,
        "message": "Timeout - Le serveur met trop de temps à répondre"
      };
    } catch (e) {
      print("❌ Erreur updateComment: $e");
      return {
        "status": false,
        "message": "Erreur: ${e.toString()}"
      };
    }
  }

  // 🔹 SUPPRIMER UN COMMENTAIRE
  Future<Map<String, dynamic>> deleteComment({
    required int commentId,
    required int userId,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/delete_comment.php");
      print("🗑️ Suppression du commentaire: $commentId par l'utilisateur: $userId");

      // Préparer les données
      final Map<String, dynamic> commentData = {
        'comment_id': commentId,
        'user_id': userId,
      };
      
      print("📝 Données de suppression: $commentData");
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(commentData),
      ).timeout(const Duration(seconds: 15));

      print("📤 Réponse suppression commentaire - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          "status": false,
          "message": "Erreur HTTP ${response.statusCode}"
        };
      }
    } on TimeoutException {
      return {
        "status": false,
        "message": "Timeout - Le serveur met trop de temps à répondre"
      };
    } catch (e) {
      print("❌ Erreur deleteComment: $e");
      return {
        "status": false,
        "message": "Erreur: ${e.toString()}"
      };
    }
  }

  // 🔹 TEST DE CONNEXION DES COMMENTAIRES
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = Uri.parse("$baseUrl/get_comments.php?post_id=1");
      print("🔍 Test connexion commentaires à: $url");
      
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'}
      ).timeout(const Duration(seconds: 10));
      
      stopwatch.stop();
      
      print("📊 Résultat test commentaires:");
      print("   - Status: ${response.statusCode}");
      print("   - Temps: ${stopwatch.elapsedMilliseconds}ms");
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {
            "status": true,
            "message": "✅ Connexion commentaires réussie (${stopwatch.elapsedMilliseconds}ms)",
            "comments_count": data['comments']?.length ?? 0,
          };
        } catch (e) {
          return {
            "status": false,
            "message": "❌ Réponse invalide (non-JSON)"
          };
        }
      } else {
        return {
          "status": false,
          "message": "❌ Erreur HTTP ${response.statusCode}"
        };
      }
    } on TimeoutException {
      return {
        "status": false,
        "message": "⏰ Timeout - Serveur commentaires inaccessible"
      };
    } catch (e) {
      return {
        "status": false,
        "message": "❌ Erreur: ${e.toString()}"
      };
    }
  }
}