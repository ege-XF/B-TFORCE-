import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/academic_staff.dart';

class AcademicRepository {
  static const List<AcademicStaff> _fallbackStaff = [
    AcademicStaff(
      title: 'Dr. Öğr. Üyesi',
      name: 'Ahmet YILMAZ',
      email: 'ayilmaz@atu.edu.tr',
      phone: '1234',
      room: 'B-201',
      department: 'Bilgisayar Programcılığı',
    ),
    AcademicStaff(
      title: 'Öğr. Gör.',
      name: 'Mehmet KAYA',
      email: 'mkaya@atu.edu.tr',
      phone: '1235',
      room: 'B-204',
      department: 'Bilgisayar Teknolojileri',
    ),
  ];

  Future<List<AcademicStaff>> fetchAcademicStaff() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/api/v1/akademisyenler'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<AcademicStaff> staffList = [];

        if (data is Map<String, dynamic> && data['data'] is List) {
          for (var item in data['data']) {
            if (item is Map<String, dynamic>) {
              staffList.add(AcademicStaff.fromJson(item));
            }
          }
        }
        return staffList.isEmpty ? _fallbackStaff : staffList;
      }
      return _fallbackStaff;
    } catch (e) {
      return _fallbackStaff;
    }
  }
}
