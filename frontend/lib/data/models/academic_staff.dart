class AcademicStaff {
  final String title;
  final String name;
  final String email;
  final String phone;
  final String room;
  final String department;

  const AcademicStaff({
    required this.title,
    required this.name,
    required this.email,
    required this.phone,
    required this.room,
    required this.department,
  });

  factory AcademicStaff.fromJson(Map<String, dynamic> json) {
    return AcademicStaff(
      title: json['unvan']?.toString() ?? '',
      name: json['ad_soyad']?.toString() ?? 'İsimsiz Akademisyen',
      email: json['eposta']?.toString() ?? 'E-posta yok',
      phone: json['dahili_tel']?.toString() ?? '-',
      room: json['oda_no']?.toString() ?? '-',
      department: json['anabilim_dali']?.toString() ?? 'Bilişim MYO',
    );
  }
}
