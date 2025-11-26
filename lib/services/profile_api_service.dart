import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart';

class ProfileApiService {
  Future<Map<String, dynamic>> updateProfile({
    required int id,
    required String fullname,
    required String email,
    required String currentPassword,
    required String newPassword,
    required String telephone,
    required String filiere,
    required String niveau,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_current_profile.php'),
        body: {
          'id': id.toString(),
          'fullname': fullname,
          'email': email,
          'current_password': currentPassword,
          'new_password': newPassword,
          'telephone': telephone,
          'filiere': filiere,
          'niveau': niveau,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': false,
          'message': 'Erreur serveur ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Erreur de connexion: $e'
      };
    }
  }
}