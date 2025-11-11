// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<http.Response> registerUser({
  required String name,
  required String email,
  required String school,
  required String program,
  required int year,
}) {
  return http.post(
    Uri.parse('https://nl5ekmyl0h.execute-api.eu-north-1.amazonaws.com/poskus'),
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': 'poskusni API',
    },
    body: jsonEncode({
      'name': name,
      'email': email,
      'school': school,
      'program': program,
      'year': year,
    }),
  );
}

Future<void> posljiPodatke() async {
  final response = await http.post(
    Uri.parse('https://nl5ekmyl0h.execute-api.eu-north-1.amazonaws.com/poskus'),
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': 'TVOJ_KLJUC_TUKAJ',
    },
    body: jsonEncode({
      'name': 'Ana',
      'email': 'ana@example.com',
      'school': 'FERI',
      'program': 'Računalništvo',
      'year': 2,
    }),
  );

  if (response.statusCode == 200) {
    print('Uspešno poslano: ${response.body}');
  } else {
    print('Napaka: ${response.statusCode} - ${response.body}');
  }
}

