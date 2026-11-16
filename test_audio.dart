import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://quran.titiktolak.com/api/quran?qurantype=mushaf_standard&page_number=1';
  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);
  final ayahs = data['data'][0]['ayahs'];
  print(ayahs[0]['ayah']['audio'][0]['audio_path']);
}
