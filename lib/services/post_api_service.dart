import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../globals.dart';

class PostApiService {
 

  // 🔹 RÉCUPÉRER TOUS LES POSTS (avec option d'exclusion)
  Future<Map<String, dynamic>> getAllPosts({int? excludeUserId}) async {
    try {
      String url = "$baseUrl/get_posts.php";
      
      // Ajouter le paramètre current_user_id si spécifié
      if (excludeUserId != null) {
        url += "?current_user_id=$excludeUserId";
      }
      
      final uri = Uri.parse(url);
      print("📥 Chargement des posts depuis: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print("📤 Réponse reçue - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == true) {
          print("✅ ${data['count'] ?? 0} posts chargés avec succès");
          return {
            "status": true,
            "posts": data['posts'] ?? [],
            "message": data['message'] ?? "Posts récupérés"
          };
        } else {
          return {
            "status": false,
            "posts": [],
            "message": data['message'] ?? "Erreur inconnue"
          };
        }
      } else if (response.statusCode == 404) {
        return {
          "status": false,
          "posts": [],
          "message": "Erreur 404 - Fichier API non trouvé"
        };
      } else {
        return {
          "status": false,
          "posts": [],
          "message": "Erreur HTTP ${response.statusCode}"
        };
      }
    } on TimeoutException {
      return {
        "status": false,
        "posts": [],
        "message": "Timeout - Le serveur met trop de temps à répondre"
      };
    } catch (e) {
      print("❌ Erreur getAllPosts: $e");
      return {
        "status": false,
        "posts": [],
        "message": "Erreur de connexion: ${e.toString()}"
      };
    }
  }

  // 🔹 RÉCUPÉRER LES POSTS D'UN UTILISATEUR
  Future<Map<String, dynamic>> getPostsByUser(int userId) async {
    try {
      final url = Uri.parse("$baseUrl/get_user_posts.php");
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {"user_id": userId.toString()}
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "status": data['status'] ?? false,
          "posts": data['posts'] ?? [],
          "message": data['message'] ?? "Posts utilisateur récupérés"
        };
      } else {
        return {
          "status": false,
          "posts": [],
          "message": "Erreur serveur ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "status": false,
        "posts": [],
        "message": "Erreur: $e"
      };
    }
  }

  // 🔹 AJOUTER UN POST
  Future<Map<String, dynamic>> addPost({
    required int userId,
    required String title,
    required String category,
    required String postType,
    String? description,
    String? location,
    String? dateLostFound,
    File? imageFile,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/add_post.php");
      var request = http.MultipartRequest("POST", url);

      // Ajouter les champs texte
      request.fields['user_id'] = userId.toString();
      request.fields['title'] = title;
      request.fields['category'] = category;
      request.fields['post_type'] = postType;
      
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }
      if (location != null && location.isNotEmpty) {
        request.fields['location'] = location;
      }
      if (dateLostFound != null && dateLostFound.isNotEmpty) {
        request.fields['date_lost_found'] = dateLostFound;
      }

      // Ajouter l'image si elle existe
      if (imageFile != null && await imageFile.exists()) {
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final fileExtension = mimeType.split('/')[1];
        
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
          filename: 'post_${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      return responseBody;

    } catch (e) {
      return {
        "status": false, 
        "message": "Erreur technique: ${e.toString()}"
      };
    }
  }

  // 🔹 SUPPRIMER UN POST
  Future<Map<String, dynamic>> deletePost(int postId, int userId) async {
    try {
      final url = Uri.parse("$baseUrl/delete_post.php");
      print("🗑️ Suppression du post $postId par l'utilisateur $userId");
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'post_id': postId,
          'user_id': userId,
        }),
      ).timeout(const Duration(seconds: 15));

      print("📤 Réponse suppression - Status: ${response.statusCode}");

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
      print("❌ Erreur deletePost: $e");
      return {
        "status": false,
        "message": "Erreur: ${e.toString()}"
      };
    }
  }

  // 🔹 METTRE À JOUR UN POST
  Future<Map<String, dynamic>> updatePost({
    required int postId,
    required int userId,
    required String title,
    required String category,
    required String postType,
    String? description,
    String? location,
    String? dateLostFound,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/update_post.php");
      print("✏️ Mise à jour du post $postId par l'utilisateur $userId");
      
      // Préparer les données
      final Map<String, dynamic> postData = {
        'post_id': postId,
        'user_id': userId,
        'title': title,
        'category': category,
        'post_type': postType,
      };
      
      // Ajouter les champs optionnels s'ils existent
      if (description != null && description.isNotEmpty) {
        postData['description'] = description;
      }
      if (location != null && location.isNotEmpty) {
        postData['location'] = location;
      }
      if (dateLostFound != null && dateLostFound.isNotEmpty) {
        postData['date_lost_found'] = dateLostFound;
      }
      
      print("📝 Données de mise à jour: $postData");
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(postData),
      ).timeout(const Duration(seconds: 15));

      print("📤 Réponse mise à jour - Status: ${response.statusCode}");

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
      print("❌ Erreur updatePost: $e");
      return {
        "status": false,
        "message": "Erreur: ${e.toString()}"
      };
    }
  }

  // 🔹 METTRE À JOUR UN POST AVEC IMAGE
  Future<Map<String, dynamic>> updatePostWithImage({
    required int postId,
    required int userId,
    required String title,
    required String category,
    required String postType,
    String? description,
    String? location,
    String? dateLostFound,
    File? imageFile,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/update_post.php");
      print("🖼️ Mise à jour du post $postId avec image");
      
      var request = http.MultipartRequest("POST", url);

      // Ajouter les champs texte
      request.fields['post_id'] = postId.toString();
      request.fields['user_id'] = userId.toString();
      request.fields['title'] = title;
      request.fields['category'] = category;
      request.fields['post_type'] = postType;
      
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }
      if (location != null && location.isNotEmpty) {
        request.fields['location'] = location;
      }
      if (dateLostFound != null && dateLostFound.isNotEmpty) {
        request.fields['date_lost_found'] = dateLostFound;
      }

      // Ajouter la nouvelle image si elle existe
      if (imageFile != null && await imageFile.exists()) {
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final fileExtension = mimeType.split('/')[1];
        
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
          filename: 'post_${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      return responseBody;

    } catch (e) {
      return {
        "status": false, 
        "message": "Erreur technique: ${e.toString()}"
      };
    }
  }

  // 🔹 TEST DE CONNEXION
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = Uri.parse("$baseUrl/get_posts.php");
      print("🔍 Test connexion à: $url");
      
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'}
      ).timeout(const Duration(seconds: 10));
      
      stopwatch.stop();
      
      print("📊 Résultat test:");
      print("   - Status: ${response.statusCode}");
      print("   - Temps: ${stopwatch.elapsedMilliseconds}ms");
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {
            "status": true,
            "message": "✅ Connexion réussie (${stopwatch.elapsedMilliseconds}ms)",
            "posts_count": data['posts']?.length ?? 0,
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
        "message": "⏰ Timeout - Serveur inaccessible"
      };
    } catch (e) {
      return {
        "status": false,
        "message": "❌ Erreur: ${e.toString()}"
      };
    }
  }
}