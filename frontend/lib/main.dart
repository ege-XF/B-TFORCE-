// ATÜ OBS – Single-file Flutter UI + Live API Integration
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/models/academic_staff.dart';
import 'data/models/announcement.dart';
import 'data/repositories/academic_repository.dart';
import 'data/repositories/feed_repository.dart';

void main() => runApp(const AtuObsApp());

/* ───────────────────────── THEME & TOKENS ───────────────────────── */

class AppColors {
  static const navy = Color(0xFF0F172A);
  static const royal = Color(0xFF1E3A8A);
  static const accent = Color(0xFF3B82F6);
  static const accentDeep = Color(0xFF2563EB);
  static const darkBg = Color(0xFF111827);
  static const green = Color(0xFF22C55E);
  static const violet = Color(0xFF8B5CF6);
  static const teal = Color(0xFF14B8A6);
  static const amber = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, royal],
  );
}

class Pal {
  final bool dark;
  const Pal(this.dark);
  factory Pal.of(BuildContext c) =>
      Pal(Theme.of(c).brightness == Brightness.dark);

  Color get text => dark ? Colors.white : AppColors.navy;
  Color get sub => dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get glass =>
      dark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.72);
  Color get glassBorder =>
      dark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06);

  /// Input / hücre / segment gibi iç yüzeylerde ortak dolgu rengi.
  Color get fill =>
      dark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05);

  TextStyle h(double size, {FontWeight w = FontWeight.w600, Color? color}) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: w, color: color ?? text);

  TextStyle body(double size, {FontWeight w = FontWeight.w400, Color? color}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: color ?? sub);
}

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
final notifEnabled = ValueNotifier<bool>(true);
final syncing = ValueNotifier<bool>(false);
final lastSync = ValueNotifier<String>('2 dk önce');

Future<void> syncNow() async {
  syncing.value = true;
  await Future<void>.delayed(const Duration(milliseconds: 1400));
  lastSync.value = 'Az önce';
  syncing.value = false;
}

Color catColor(String c) {
  switch (c) {
    case 'Haber':
    case 'Proje':
      return AppColors.violet;
    case 'Etkinlik':
      return AppColors.teal;
    case 'Çalışma':
      return AppColors.amber;
    default:
      return AppColors.accent;
  }
}

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      backgroundColor: AppColors.accentDeep,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
}

/* ───────────────────────── APP ROOT ───────────────────────── */

class AtuObsApp extends StatelessWidget {
  const AtuObsApp({super.key});

  ThemeData _build(Brightness b) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme:
          ColorScheme.fromSeed(seedColor: AppColors.accent, brightness: b),
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scaffoldBackgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ATÜ OBS',
        themeMode: mode,
        theme: _build(Brightness.light),
        darkTheme: _build(Brightness.dark),
        home: const HomeShell(),
      ),
    );
  }
}

/* ───────────────────────── SHARED WIDGETS ───────────────────────── */

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: p.dark
                      ? const [
                          AppColors.darkBg,
                          Color(0xFF0F1E4A),
                          AppColors.darkBg
                        ]
                      : const [
                          Color(0xFFF8FAFC),
                          Color(0xFFDBEAFE),
                          Color(0xFFF1F5F9)
                        ],
                ),
              ),
            ),
          ),
          const Positioned(
              top: -90,
              right: -70,
              child: _Glow(color: AppColors.accent, size: 280)),
          const Positioned(
              bottom: 140,
              left: -110,
              child: _Glow(color: AppColors.royal, size: 300)),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    final dark = Pal.of(context).dark;
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            color.withOpacity(dark ? 0.38 : 0.22),
            color.withOpacity(0),
          ]),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: p.glass,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: p.glassBorder),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool compact;
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brand,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.38),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 14 : 18, vertical: compact ? 9 : 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: compact ? 12.5 : 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryTag extends StatelessWidget {
  final String label;
  const CategoryTag(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = catColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 10.5, fontWeight: FontWeight.w700, color: c)),
    );
  }
}

class FilterChipX extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const FilterChipX(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.brand : null,
          color: selected ? null : p.glass,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: selected ? Colors.transparent : p.glassBorder),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : p.sub)),
      ),
    );
  }
}

/// Yatay kaydırılabilir filtre çipleri (Ana Sayfa, Gruplar, Grup oluşturma).
class FilterBar extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  const FilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final o in options)
            FilterChipX(
              label: o,
              selected: selected == o,
              onTap: () => onSelected(o),
            ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(text, style: p.h(16))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  const InitialsAvatar(this.initials, {super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brand,
        boxShadow: [
          BoxShadow(color: AppColors.accent.withOpacity(0.35), blurRadius: 14),
        ],
      ),
      child: Text(initials,
          style: GoogleFonts.poppins(
              fontSize: size * 0.34,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    );
  }
}

Future<void> showGlassSheet(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final p = Pal.of(ctx);
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: p.dark
                  ? AppColors.navy.withOpacity(0.88)
                  : Colors.white.withOpacity(0.94),
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: p.sub.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(title, style: p.h(18)),
                    const SizedBox(height: 14),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

InputDecoration glassField(Pal p, String hint) => InputDecoration(
      hintText: hint,
      hintStyle: p.body(14),
      filled: true,
      fillColor: p.fill,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

/* ───────────────────────── SHELL + GLASS BOTTOM BAR ───────────────────────── */

class NavItemData {
  final IconData icon;
  final String label;
  final int badge;
  final Color badgeColor;
  const NavItemData(this.icon, this.label,
      {this.badge = 0, this.badgeColor = AppColors.green});
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomePage(),
    GroupsPage(),
    SettingsPage(),
  ];

  static const _items = <NavItemData>[
    NavItemData(Icons.home_outlined, 'Ana Sayfa',
        badge: 3, badgeColor: AppColors.accent),
    NavItemData(Icons.groups_outlined, 'Gruplar', badge: 2),
    NavItemData(Icons.settings_outlined, 'Ayarlar'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(index: _index, children: _pages),
        ),
      ),
      bottomNavigationBar: GlassBottomBar(
        index: _index,
        items: _items,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class GlassBottomBar extends StatelessWidget {
  final int index;
  final List<NavItemData> items;
  final ValueChanged<int> onTap;
  const GlassBottomBar(
      {super.key,
      required this.index,
      required this.items,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, math.max(bottom, 12) + 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(p.dark ? 0.45 : 0.12),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: p.dark
                    ? const Color(0xFF0B1220).withOpacity(0.55)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: p.glassBorder),
              ),
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavButton(
                        data: items[i],
                        active: i == index,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavItemData data;
  final bool active;
  final VoidCallback onTap;
  const _NavButton(
      {required this.data, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            width: active ? 76 : 48,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              gradient: active
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accent.withOpacity(0.38),
                        AppColors.accent.withOpacity(0.10),
                      ],
                    )
                  : null,
              border: Border.all(
                  color: active
                      ? AppColors.accent.withOpacity(0.5)
                      : Colors.transparent),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.35),
                        blurRadius: 16,
                      ),
                    ]
                  : const [],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  scale: active ? 1.12 : 1,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    data.icon,
                    size: 24,
                    color: active
                        ? (p.dark ? Colors.white : AppColors.accentDeep)
                        : p.sub,
                  ),
                ),
                if (data.badge > 0)
                  Positioned(
                    top: -4,
                    right: active ? 8 : 0,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 17, minHeight: 17),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: data.badgeColor,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                              color: data.badgeColor.withOpacity(0.55),
                              blurRadius: 8),
                        ],
                      ),
                      child: Text('${data.badge}',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? p.text : p.sub,
            ),
            child: Text(data.label),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── 1) ANA SAYFA ───────────────────────── */

class QuickItem {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final List<String> lines;
  const QuickItem(this.icon, this.label, this.colors, this.lines);
}

const _quick = <QuickItem>[
  QuickItem(Icons.event_note_outlined, 'Sınav\nTakvimi', [
    Color(0xFF3B82F6),
    Color(0xFF1D4ED8)
  ], [
    'Veri Yapıları • 27 Eki, 10:00',
    'Matematik II • 29 Eki, 13:30',
    'Web Programlama • 2 Kas, 09:00',
  ]),
  QuickItem(Icons.calendar_view_week_outlined, 'Ders\nProgramı', [
    Color(0xFF6366F1),
    Color(0xFF3730A3)
  ], [
    'Pzt 09:00 • Algoritma',
    'Sal 13:00 • Veri Tabanı',
    'Çar 10:00 • Mobil Programlama',
  ]),
  QuickItem(Icons.restaurant_menu_outlined, 'Yemekhane\nMenüsü', [
    Color(0xFF0EA5E9),
    Color(0xFF1E40AF)
  ], [
    'Çorba • Mercimek',
    'Ana yemek • Tavuk sote',
    'Yan • Pilav & Salata',
    'Tatlı • Sütlaç',
  ]),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _filters = ['Tümü', 'Duyuru', 'Haber'];

  final FeedRepository _repository = FeedRepository();
  String _filter = 'Tümü';
  List<Announcement> _liveAnnouncements = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _repository.fetchLiveFeed();
      if (!mounted) return;
      setState(() {
        _liveAnnouncements = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Backend servisine bağlanılamadı. Lütfen sunucunun çalıştığından emin olun.';
        _isLoading = false;
      });
    }
  }

  Widget _buildFeed(Pal p) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 36, color: AppColors.danger),
            const SizedBox(height: 10),
            Text(_errorMessage!,
                textAlign: TextAlign.center, style: p.body(13)),
            const SizedBox(height: 14),
            GradientButton(
              label: 'Tekrar Dene',
              icon: Icons.refresh_rounded,
              compact: true,
              onTap: _fetchFeed,
            ),
          ],
        ),
      );
    }

    final list = _filter == 'Tümü'
        ? _liveAnnouncements
        : _liveAnnouncements.where((a) => a.category == _filter).toList();

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Henüz duyuru veya haber bulunamadı.', style: p.body(14)),
      );
    }

    return Column(
      children: [
        for (final a in list) ...[
          _AnnouncementCard(a: a),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 130),
      children: [
        // Header (Profil ve Bildirimler)
        Row(
          children: [
            const InitialsAvatar('ET'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hoş Geldin,', style: p.body(13)),
                  Text('Ege Tibek', style: p.h(20, w: FontWeight.w700)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => toast(context, '3 yeni bildirimin var'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GlassCard(
                    radius: 16,
                    padding: const EdgeInsets.all(11),
                    child: Icon(Icons.notifications_none_rounded,
                        color: p.text, size: 22),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: p.dark ? AppColors.darkBg : Colors.white,
                            width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),

        // Hızlı Erişim
        const SectionTitle('Hızlı Erişim'),
        Row(
          children: [
            for (int i = 0; i < _quick.length; i++) ...[
              Expanded(child: _QuickCard(item: _quick[i])),
              if (i != _quick.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 28),

        // Canlı Akış
        SectionTitle(
          'Canlı Akış',
          trailing: GestureDetector(
            onTap: _fetchFeed,
            child: const Icon(Icons.refresh_rounded,
                size: 20, color: AppColors.accent),
          ),
        ),
        FilterBar(
          options: _filters,
          selected: _filter,
          onSelected: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: 14),
        _buildFeed(p),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final QuickItem item;
  const _QuickCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      onTap: () => showGlassSheet(
        context,
        title: item.label.replaceAll('\n', ' '),
        child: Column(
          children: [
            for (final l in item.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          gradient: AppColors.brand, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(l,
                            style:
                                p.body(14, color: p.text, w: FontWeight.w500))),
                  ],
                ),
              ),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: item.colors),
              boxShadow: [
                BoxShadow(
                    color: item.colors.first.withOpacity(0.4), blurRadius: 12),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Text(item.label,
              textAlign: TextAlign.center,
              style: p.body(12, color: p.text, w: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement a;
  const _AnnouncementCard({required this.a});

  void _openDetail(BuildContext context, Pal p) {
    showGlassSheet(
      context,
      title: a.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryTag(a.category),
          const SizedBox(height: 12),
          Text(a.body,
              style: p.body(14.5, color: p.text).copyWith(height: 1.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              gradient: AppColors.brand,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: Column(
              children: [
                Text(a.day,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1)),
                Text(a.month,
                    style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryTag(a.category),
                const SizedBox(height: 7),
                Text(a.title, style: p.h(14.5)),
                const SizedBox(height: 4),
                Text(a.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: p.body(12.5)),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _openDetail(context, p),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Detay',
                            style: p.body(12.5,
                                color: AppColors.accent, w: FontWeight.w700)),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 15, color: AppColors.accent),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── 2) MYO & GRUPLAR ───────────────────────── */

class Group {
  final String name, type, lastActive;
  final int members;
  final IconData icon;
  bool joined;
  Group(this.name, this.type, this.members, this.lastActive, this.icon,
      {this.joined = false});
}

final groupsNotifier = ValueNotifier<List<Group>>([
  Group('Veri Yapıları • 2. Sınıf', 'Ders', 48, 'Bugün',
      Icons.account_tree_outlined,
      joined: true),
  Group('Algoritma Çalışma Topluluğu', 'Çalışma', 32, '2 saat önce',
      Icons.psychology_outlined),
  Group('Mobil Uygulama Projesi', 'Proje', 7, 'Dün', Icons.phone_android),
  Group('Elektronik Devreler', 'Ders', 56, '3 gün önce', Icons.memory_outlined),
  Group('Girişimcilik Topluluğu', 'Çalışma', 120, 'Bu hafta',
      Icons.lightbulb_outline),
]);

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  static const _types = ['Ders', 'Çalışma', 'Proje'];
  static const _filters = ['Tümü', ..._types];

  String _filter = 'Tümü';

  void _openCreate() {
    final p = Pal.of(context);
    final ctrl = TextEditingController();
    String type = 'Çalışma';
    showGlassSheet(
      context,
      title: 'Yeni Grup Oluştur',
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: ctrl,
              style: p.body(14.5, color: p.text),
              decoration: glassField(p, 'Grup adı'),
            ),
            const SizedBox(height: 14),
            Text('Grup türü', style: p.body(12.5, w: FontWeight.w600)),
            const SizedBox(height: 8),
            FilterBar(
              options: _types,
              selected: type,
              onSelected: (t) => setSheet(() => type = t),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                label: 'Grubu Oluştur',
                icon: Icons.add_rounded,
                onTap: () {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;
                  groupsNotifier.value = [
                    Group(name, type, 1, 'Şimdi', Icons.groups_outlined,
                        joined: true),
                    ...groupsNotifier.value,
                  ];
                  Navigator.pop(ctx);
                  toast(context, '“$name” grubu oluşturuldu');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 130),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MYO & Gruplar', style: p.h(22, w: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Toplulukları keşfet, ekibini kur.', style: p.body(13)),
                ],
              ),
            ),
            GradientButton(
              label: 'Grup Oluştur',
              icon: Icons.add_rounded,
              compact: true,
              onTap: _openCreate,
            ),
          ],
        ),
        const SizedBox(height: 20),
        FilterBar(
          options: _filters,
          selected: _filter,
          onSelected: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: 14),
        ValueListenableBuilder<List<Group>>(
          valueListenable: groupsNotifier,
          builder: (_, all, __) {
            final list = _filter == 'Tümü'
                ? all
                : all.where((g) => g.type == _filter).toList();
            return Column(
              children: [
                for (final g in list) ...[
                  _GroupCard(group: g),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Group group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final c = catColor(group.type);
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c, c.withOpacity(0.55)],
                  ),
                  boxShadow: [
                    BoxShadow(color: c.withOpacity(0.35), blurRadius: 12),
                  ],
                ),
                child: Icon(group.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: p.h(14.5)),
                    const SizedBox(height: 6),
                    CategoryTag(group.type),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.people_outline, size: 16, color: p.sub),
              const SizedBox(width: 5),
              Text('${group.members} üye', style: p.body(12.5)),
              const SizedBox(width: 14),
              Icon(Icons.schedule, size: 15, color: p.sub),
              const SizedBox(width: 5),
              Expanded(
                  child: Text(group.lastActive,
                      overflow: TextOverflow.ellipsis, style: p.body(12.5))),
              group.joined
                  ? _ChatButton(
                      onTap: () =>
                          toast(context, '${group.name} sohbeti açılıyor…'))
                  : GradientButton(
                      label: 'Katıl',
                      icon: Icons.login_rounded,
                      compact: true,
                      onTap: () {
                        group.joined = true;
                        groupsNotifier.value = List.of(groupsNotifier.value);
                        toast(context, 'Gruba katıldın');
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withOpacity(0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline,
                size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Text('Sohbet Et',
                style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent)),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────── 3) AYARLAR ───────────────────────── */

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _divider(Pal p) =>
      Divider(height: 1, indent: 64, color: p.glassBorder);

  void _reportBug(BuildContext context) {
    final p = Pal.of(context);
    showGlassSheet(
      context,
      title: 'Hata Bildir',
      child: Column(
        children: [
          TextField(
            maxLines: 4,
            style: p.body(14.5, color: p.text),
            decoration: glassField(p, 'Karşılaştığın sorunu kısaca anlat…'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: 'Gönder',
              icon: Icons.send_rounded,
              onTap: () {
                Navigator.pop(context);
                toast(context, 'Teşekkürler, bildirimin iletildi');
              },
            ),
          ),
        ],
      ),
    );
  }

  static final _academicRepository = AcademicRepository();

  void _academicGuide(BuildContext context) {
    final p = Pal.of(context);
    showGlassSheet(
      context,
      title: 'Akademisyen İletişim Rehberi',
      child: FutureBuilder<List<AcademicStaff>>(
        future: _academicRepository.fetchAcademicStaff(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final staff = snapshot.data;
          if (snapshot.hasError || staff == null || staff.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Akademisyen bilgileri yüklenemedi. Lütfen backend servisini kontrol edin.',
                style: p.body(13),
              ),
            );
          }

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: staff.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _AcademicTile(staff: staff[i]),
            ),
          );
        },
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Güvenli Çıkış',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Hesabından çıkış yapmak istediğine emin misin?',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              toast(context, 'Güvenli çıkış yapıldı');
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 130),
      children: [
        Text('Ayarlar', style: p.h(22, w: FontWeight.w700)),
        const SizedBox(height: 18),

        // Profil özeti
        GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  const InitialsAvatar('ET', size: 62),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ege Tibek', style: p.h(17, w: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Öğrenci No: 2301042017', style: p.body(12.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                      child: _InfoCell('Bölüm', 'Bilgisayar Programcılığı')),
                  SizedBox(width: 10),
                  Expanded(child: _InfoCell('Sınıf', '2. Sınıf')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('AGNO', style: p.body(12.5, w: FontWeight.w600)),
                  const Spacer(),
                  Text('3.42 / 4.00',
                      style:
                          p.h(14, color: AppColors.accent, w: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 3.42 / 4,
                  minHeight: 7,
                  backgroundColor: p.glassBorder,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Tercihler
        const SectionTitle('Tercihler'),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: notifEnabled,
                builder: (_, on, __) => SettingRow(
                  icon: Icons.notifications_active_outlined,
                  title: 'Otomatik Duyuru Bildirimleri',
                  trailing: Switch(
                    value: on,
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.accent,
                    onChanged: (v) => notifEnabled.value = v,
                  ),
                  onTap: () => notifEnabled.value = !on,
                ),
              ),
              _divider(p),
              const SettingRow(
                icon: Icons.contrast_outlined,
                title: 'Tema',
                trailing: _ThemeSegment(),
              ),
              _divider(p),
              ValueListenableBuilder<bool>(
                valueListenable: syncing,
                builder: (_, busy, __) => ValueListenableBuilder<String>(
                  valueListenable: lastSync,
                  builder: (_, last, __) => SettingRow(
                    icon: Icons.cloud_done_outlined,
                    iconColor: AppColors.green,
                    title: 'Supabase Senkronizasyonu',
                    subtitle: busy ? 'Senkronize ediliyor…' : 'Bağlı • $last',
                    trailing: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.sync,
                            color: AppColors.accent, size: 22),
                    onTap: busy ? null : syncNow,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Destek
        const SectionTitle('Destek'),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SettingRow(
                icon: Icons.bug_report_outlined,
                title: 'Hata Bildir',
                onTap: () => _reportBug(context),
              ),
              _divider(p),
              SettingRow(
                icon: Icons.contacts_outlined,
                title: 'Akademisyen İletişim Rehberi',
                onTap: () => _academicGuide(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Çıkış
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: AppColors.danger.withOpacity(0.12),
            child: InkWell(
              onTap: () => _logout(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded,
                        color: AppColors.danger, size: 20),
                    const SizedBox(width: 8),
                    Text('Güvenli Çıkış',
                        style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AcademicTile extends StatelessWidget {
  final AcademicStaff staff;
  const _AcademicTile({required this.staff});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final hasRoom = staff.room.isNotEmpty && staff.room != '-';
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          InitialsAvatar(staff.name.isNotEmpty ? staff.name[0] : 'A', size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${staff.title} ${staff.name}', style: p.h(14)),
                const SizedBox(height: 2),
                Text(staff.department, style: p.body(11.5)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 13, color: p.sub),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(staff.email,
                          overflow: TextOverflow.ellipsis,
                          style: p.body(11.5, color: AppColors.accent)),
                    ),
                    if (hasRoom) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.meeting_room_outlined, size: 13, color: p.sub),
                      const SizedBox(width: 2),
                      Text(staff.room, style: p.body(11.5)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label, value;
  const _InfoCell(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.fill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: p.body(11.5)),
          const SizedBox(height: 3),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: p.body(13, color: p.text, w: FontWeight.w600)),
        ],
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  const SettingRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: p.body(14, color: p.text, w: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: p.body(12)),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded, color: p.sub, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment();

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        Widget seg(String label, IconData icon, ThemeMode m) {
          final sel = mode == m;
          return GestureDetector(
            onTap: () => themeNotifier.value = m,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                gradient: sel ? AppColors.brand : null,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: sel ? Colors.white : p.sub),
                  const SizedBox(width: 4),
                  Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : p.sub)),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: p.fill,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              seg('Koyu', Icons.dark_mode_outlined, ThemeMode.dark),
              seg('Açık', Icons.light_mode_outlined, ThemeMode.light),
            ],
          ),
        );
      },
    );
  }
}
