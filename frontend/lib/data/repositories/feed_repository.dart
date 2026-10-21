import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/announcement.dart';

class FeedRepository {
  Future<List<Announcement>> fetchLiveFeed() async {
    final response = await http
        .get(Uri.parse(ApiConstants.feedEndpoint))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<Announcement> items = [];

      if (data is Map<String, dynamic>) {
        if (data['duyurular'] is List) {
          for (var item in data['duyurular']) {
            if (item is Map<String, dynamic>) {
              items.add(Announcement.fromJson(item, 'Duyuru'));
            }
          }
        }
        if (data['haberler'] is List) {
          for (var item in data['haberler']) {
            if (item is Map<String, dynamic>) {
              items.add(Announcement.fromJson(item, 'Haber'));
            }
          }
        }
      }
      return items;
    } else {
      throw Exception('Sunucu yanıt vermedi (${response.statusCode})');
    }
  }
}
