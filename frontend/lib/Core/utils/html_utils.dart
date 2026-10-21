// lib/core/utils/html_utils.dart
String stripHtml(String htmlString) {
  final RegExp exp =
      RegExp(r'<[^>]*>|&[^;]+;', multiLine: true, caseSensitive: false);
  return htmlString.replaceAll(exp, '').trim();
}

// lib/data/models/announcement.dart
class Announcement {
  final String category, title, summary, day, month, body;

  const Announcement({
    required this.category,
    required this.title,
    required this.summary,
    required this.day,
    required this.month,
    required this.body,
  });

  factory Announcement.fromJson(Map<String, dynamic> json, String category) {
    final rawDetail = json['detay_html']?.toString() ?? '';
    return Announcement(
      category: category,
      title: json['baslik']?.toString() ?? 'Başlıksız',
      summary: stripHtml(rawDetail),
      day: json['gun']?.toString() ?? '',
      month: json['ay']?.toString() ?? '',
      body: rawDetail,
    );
  }
}
