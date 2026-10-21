import '../../core/utils/html_utils.dart';

enum CategoryType { duyuru, haber, etkinlik, genel }

class Announcement {
  static const _emptyDetail = 'Detay bulunmuyor';

  final String category;
  final String title;
  final String summary;
  final String day;
  final String month;
  final String rawBody;

  const Announcement({
    required this.category,
    required this.title,
    required this.summary,
    required this.day,
    required this.month,
    required this.rawBody,
  });

  /// HTML etiketlerinden arındırılmış detay metni (detay penceresinde gösterilir).
  String get body => summary;

  factory Announcement.fromJson(Map<String, dynamic> json, String category) {
    final rawDetail = json['detay_html']?.toString() ?? '';
    final cleanDetail = stripHtml(rawDetail);

    return Announcement(
      category: category,
      title: json['baslik']?.toString() ?? 'Başlıksız',
      summary: cleanDetail.isNotEmpty ? cleanDetail : _emptyDetail,
      day: json['gun']?.toString() ?? '',
      month: json['ay']?.toString() ?? '',
      rawBody: rawDetail,
    );
  }
}
