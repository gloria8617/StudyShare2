import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://nl5ekmyl0h.execute-api.eu-north-1.amazonaws.com/poskus';
const String apiKey = 'm7KR0SCFnW1ybUdFJ4Sg08UGHaWwcVZh3Y64kBrU'; // zamenjaj z dejanskim ključem

class ApiService {
  /// Pridobi podatke iz poljubne tabele
  Future<List<Map<String, dynamic>>> pridobiTabelo(String imeTabele) async {
    final uri = Uri.parse('$baseUrl/vsebina?table=$imeTabele');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Napaka pri pridobivanju: ${response.statusCode}');
      return [];
    }
  }

  /// Dodaj novega uporabnika v tabelo Customer
  Future<bool> dodajCustomer(int custID, String name) async {
    final uri = Uri.parse('$baseUrl/dodaj');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode({
        'CustID': custID,
        'Name': name,
      }),
    );

    if (response.statusCode == 200) {
      print('Uspešno dodano!');
      return true;
    } else {
      print('Napaka: ${response.body}');
      return false;
    }
  }
}
