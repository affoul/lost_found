import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart';

class AuthApiService {
  // ⏱️ Timeout de 8 secondes pour toutes les requêtes
  static const Duration timeoutDuration = Duration(seconds: 20);

  // 🔹 GET CURRENT USER INFO - OPTIMISÉ AVEC TIMEOUT
  Future<Map<String, dynamic>> getUser(String email) async {
    final url = Uri.parse("$baseUrl/get_user.php");
    final stopwatch = Stopwatch()..start();
    
    print("🔍 Envoi requête getUser avec email: $email");
    print("🔍 URL: $url");
    
    try {
      final response = await http.post(
        url, 
        body: {"email": email}
      ).timeout(timeoutDuration);
      
      stopwatch.stop();
      print("✅ Réponse reçue en ${stopwatch.elapsedMilliseconds}ms");
      print("🔍 Statut HTTP: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == true) {
          if (data['fullname'] != null) {
            print("✅ Structure directe détectée");
            return {
              "status": true,
              "user": {
                "id": data['id'] ?? '',
                "fullname": data['fullname'] ?? '',
                "email": data['email'] ?? '',
                "telephone": data['telephone'] ?? '',
                "filiere": data['filiere'] ?? '',
                "niveau": data['niveau'] ?? '',
              }
            };
          } else if (data['user'] != null) {
            print("✅ Structure avec 'user' détectée");
            return data;
          } else {
            print("❌ Structure inconnue");
            return {
              "status": false,
              "message": "Structure de données inattendue"
            };
          }
        } else {
          return {
            "status": false,
            "message": data['message'] ?? "Utilisateur non trouvé"
          };
        }
      } else {
        return {
          "status": false,
          "message": "Erreur serveur ${response.statusCode}"
        };
      }
    } on TimeoutException {
      print("❌ TIMEOUT - getUser a pris plus de ${timeoutDuration.inSeconds}s");
      return {
        "status": false, 
        "message": "Timeout - Serveur trop lent"
      };
    } catch (e) {
      print("❌ Erreur getUser: $e");
      return {"status": false, "message": "Erreur : $e"};
    }
  }

  // 🔹 LOGIN OPTIMISÉ AVEC TIMEOUT
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login.php");
    final stopwatch = Stopwatch()..start();
    
    print("🔐 Tentative de connexion pour: $email");
    
    try {
      final response = await http.post(
        url, 
        body: {
          "email": email,
          "password": password,
        }
      ).timeout(timeoutDuration);
      
      stopwatch.stop();
      print("✅ Login traité en ${stopwatch.elapsedMilliseconds}ms");
      
      return jsonDecode(response.body);
    } on TimeoutException {
      print("❌ TIMEOUT - Login a pris plus de ${timeoutDuration.inSeconds}s");
      return {
        "status": false, 
        "message": "Timeout - Serveur trop lent"
      };
    } catch (e) {
      print("❌ Erreur login: $e");
      return {"status": false, "message": "Erreur : $e"};
    }
  }

  // 🔹 REGISTER OPTIMISÉ AVEC TIMEOUT
  Future<Map<String, dynamic>> register({
    required String fullname,
    required String email,
    required String password,
    required String telephone,
    required String filiere,
    required String niveau,
  }) async {
    final url = Uri.parse("$baseUrl/register.php");
    final stopwatch = Stopwatch()..start();
    
    print("👤 Tentative d'inscription pour: $email");
    
    try {
      final response = await http.post(
        url, 
        body: {
          "fullname": fullname,
          "email": email,
          "password": password,
          "telephone": telephone,
          "filiere": filiere,
          "niveau": niveau,
        }
      ).timeout(timeoutDuration);
      
      stopwatch.stop();
      print("✅ Register traité en ${stopwatch.elapsedMilliseconds}ms");
      
      return jsonDecode(response.body);
    } on TimeoutException {
      print("❌ TIMEOUT - Register a pris plus de ${timeoutDuration.inSeconds}s");
      return {
        "status": false, 
        "message": "Timeout - Serveur trop lent"
      };
    } catch (e) {
      print("❌ Erreur register: $e");
      return {"status": false, "message": "Erreur : $e"};
    }
  }

  // 🔹 TEST DE CONNEXION RAPIDE
  Future<Map<String, dynamic>> testConnection() async {
    final url = Uri.parse("$baseUrl/login.php");
    final stopwatch = Stopwatch()..start();
    
    print("📡 Test de connexion au serveur...");
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      
      stopwatch.stop();
      print("📊 Test connexion: ${stopwatch.elapsedMilliseconds}ms");
      
      return {
        "status": response.statusCode == 200,
        "message": "Status: ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)",
        "response_time": stopwatch.elapsedMilliseconds
      };
    } on TimeoutException {
      print("❌ TIMEOUT - Serveur inaccessible");
      return {
        "status": false, 
        "message": "Timeout - Serveur inaccessible"
      };
    } catch (e) {
      print("❌ Erreur test connexion: $e");
      return {
        "status": false, 
        "message": "Erreur: $e"
      };
    }
  }
}