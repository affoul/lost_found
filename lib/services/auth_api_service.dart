import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart';

class AuthApiService {
  // 🔹 GET CURRENT USER INFO - VERSION DEBUG
  Future<Map<String, dynamic>> getUser(String email) async {
    final url = Uri.parse("$baseUrl/get_user.php");
    print("🔍 Envoi requête getUser avec email: $email");
    print("🔍 URL: $url");
    
    try {
      final response = await http.post(url, body: {"email": email});
      
      print("🔍 Statut HTTP: ${response.statusCode}");
      print("🔍 Body brut: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔍 Données décodées: $data");
        
        // Vérifier la structure exacte des données
        if (data['status'] == true) {
          // Essayer différentes structures possibles
          if (data['fullname'] != null) {
            // Structure directe: {status: true, fullname: "...", email: "...", ...}
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
            // Structure avec user: {status: true, user: {...}}
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
    } catch (e) {
      print("❌ Erreur getUser: $e");
      return {"status": false, "message": "Erreur : $e"};
    }
  }

  // 🔹 LOGIN (inchangé)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login.php");
    try {
      final response = await http.post(url, body: {
        "email": email,
        "password": password,
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Erreur : $e"};
    }
  }

  // 🔹 REGISTER (inchangé)
  Future<Map<String, dynamic>> register({
    required String fullname,
    required String email,
    required String password,
    required String telephone,
    required String filiere,
    required String niveau,
  }) async {
    final url = Uri.parse("$baseUrl/register.php");
    try {
      final response = await http.post(url, body: {
        "fullname": fullname,
        "email": email,
        "password": password,
        "telephone": telephone,
        "filiere": filiere,
        "niveau": niveau,
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Erreur : $e"};
    }
  }
}