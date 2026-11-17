import 'package:material_ui/material_ui.dart';

/// Parejas de color de acento (`fg` + `bg` soft) según la sección 3.1.
enum HuAccent {
  teal,
  coral,
  sun,
  lav,
  sky,
  ok,
  bad,
  muted;

  static HuAccent fromKey(String key) => switch (key) {
        'teal' => HuAccent.teal,
        'coral' => HuAccent.coral,
        'sun' => HuAccent.sun,
        'lav' => HuAccent.lav,
        'sky' => HuAccent.sky,
        'ok' => HuAccent.ok,
        'bad' => HuAccent.bad,
        _ => HuAccent.muted,
      };

  String get key => name;

  Color get fg => switch (this) {
        HuAccent.teal => const Color(0xFF1F9E8F),
        HuAccent.coral => const Color(0xFFF2775E),
        HuAccent.sun => const Color(0xFFD99A1E),
        HuAccent.lav => const Color(0xFF8B7BD8),
        HuAccent.sky => const Color(0xFF3D9BE9),
        HuAccent.ok => const Color(0xFF2E9E6B),
        HuAccent.bad => const Color(0xFFD9483B),
        HuAccent.muted => const Color(0xFF6E7A8A),
      };

  Color get bg => switch (this) {
        HuAccent.teal => const Color(0xFFE1F4F1),
        HuAccent.coral => const Color(0xFFFDE8E3),
        HuAccent.sun => const Color(0xFFFEF3DC),
        HuAccent.lav => const Color(0xFFEEEBFB),
        HuAccent.sky => const Color(0xFFE3F1FC),
        HuAccent.ok => const Color(0xFFE2F5EC),
        HuAccent.bad => const Color(0xFFFCE6E3),
        HuAccent.muted => const Color(0xFFF3F6F8),
      };

  Color get tagFg => switch (this) {
        HuAccent.teal => const Color(0xFF157A6F),
        HuAccent.coral => const Color(0xFFD9583F),
        HuAccent.sun => const Color(0xFFA86F0C),
        HuAccent.lav => const Color(0xFF5E4FB0),
        HuAccent.sky => const Color(0xFF3D9BE9),
        HuAccent.ok => const Color(0xFF2E9E6B),
        HuAccent.bad => const Color(0xFFD9483B),
        HuAccent.muted => const Color(0xFF6E7A8A),
      };

  List<Color> get petCardTopGradient => switch (this) {
        HuAccent.teal => const [Color(0xFF8ED6CB), Color(0xFF5DBFB2)],
        HuAccent.coral => const [Color(0xFFFBD0C6), Color(0xFFF6AE9F)],
        HuAccent.lav => const [Color(0xFFD7D0F7), Color(0xFFB6AAEE)],
        HuAccent.sun => const [Color(0xFFFCE2A8), Color(0xFFF8C870)],
        _ => const [Color(0xFF8ED6CB), Color(0xFF5DBFB2)],
      };

  Color get petCardBottomBg => switch (this) {
        HuAccent.teal => const Color(0xFF2FA596),
        HuAccent.coral => const Color(0xFFF28C78),
        HuAccent.lav => const Color(0xFF8F80DA),
        HuAccent.sun => const Color(0xFFEFA83C),
        _ => const Color(0xFF2FA596),
      };

  Color get petCardPillFg => switch (this) {
        HuAccent.teal => const Color(0xFF1F9E8F),
        HuAccent.coral => const Color(0xFFE9644B),
        HuAccent.lav => const Color(0xFF6E5FC6),
        HuAccent.sun => const Color(0xFFB7790F),
        _ => const Color(0xFF1F9E8F),
      };

  Color get petAvatarRingBg => switch (this) {
        HuAccent.teal => const Color(0xFF8ED6CB),
        HuAccent.coral => const Color(0xFFF9C3B7),
        HuAccent.lav => const Color(0xFFCFC6F5),
        HuAccent.sun => const Color(0xFFFBD993),
        _ => const Color(0xFF8ED6CB),
      };

  Color get petSummaryCircleBg => switch (this) {
        HuAccent.teal => const Color(0xFFCDEDE8),
        HuAccent.coral => const Color(0xFFFCE0D9),
        HuAccent.lav => const Color(0xFFE6E1FA),
        HuAccent.sun => const Color(0xFFFDEDCB),
        _ => const Color(0xFFCDEDE8),
      };

  Color get serviceCardBg => switch (this) {
        HuAccent.teal => const Color(0xFFE6F5F2),
        HuAccent.sun => const Color(0xFFFDF3E1),
        HuAccent.lav => const Color(0xFFEFEDFB),
        HuAccent.coral => const Color(0xFFFDECE7),
        HuAccent.sky => const Color(0xFFE7F2FC),
        _ => const Color(0xFFE6F5F2),
      };
}

@immutable
class HuTokens extends ThemeExtension<HuTokens> {
  const HuTokens({
    this.bg = const Color(0xFFFFFFFF),
    this.surface = const Color(0xFFFFFFFF),
    this.ink = const Color(0xFF1D2A44),
    this.ink2 = const Color(0xFF6E7A8A),
    this.ink3 = const Color(0xFFA3ADBA),
    this.line = const Color(0xFFEDF0F3),
    this.border = const Color(0xFFEEF1F4),
    this.chip = const Color(0xFFF3F6F8),
    this.teal = const Color(0xFF1F9E8F),
    this.tealDeep = const Color(0xFF157A6F),
    this.tealSoft = const Color(0xFFE1F4F1),
    this.mint = const Color(0xFFBFEDE6),
    this.coral = const Color(0xFFF2775E),
    this.coralDeep = const Color(0xFFD9583F),
    this.coralSoft = const Color(0xFFFDE8E3),
    this.sun = const Color(0xFFF5B94A),
    this.sunSoft = const Color(0xFFFEF3DC),
    this.lav = const Color(0xFF8B7BD8),
    this.lavSoft = const Color(0xFFEEEBFB),
    this.sky = const Color(0xFF3D9BE9),
    this.skySoft = const Color(0xFFE3F1FC),
    this.ok = const Color(0xFF2E9E6B),
    this.okSoft = const Color(0xFFE2F5EC),
    this.bad = const Color(0xFFD9483B),
    this.badSoft = const Color(0xFFFCE6E3),
  });

  final Color bg, surface, ink, ink2, ink3, line, border, chip;
  final Color teal, tealDeep, tealSoft, mint;
  final Color coral, coralDeep, coralSoft;
  final Color sun, sunSoft, lav, lavSoft, sky, skySoft;
  final Color ok, okSoft, bad, badSoft;

  static const String font = 'Poppins';

  TextStyle _t(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
    double letterSpacing = 0,
  }) =>
      TextStyle(
        fontFamily: font,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // Tipografía sección 3.2
  TextStyle get h1 => _t(24, FontWeight.w600, ink, height: 1.32, letterSpacing: -0.24);
  TextStyle get h1Large => _t(26, FontWeight.w600, ink, height: 1.2, letterSpacing: -0.26);
  TextStyle get title => _t(23, FontWeight.w600, ink, height: 1.2, letterSpacing: -0.23);
  TextStyle get topTitle => _t(20, FontWeight.w600, ink, height: 1.2);
  TextStyle get h3 => _t(18, FontWeight.w600, ink, height: 1.2);
  TextStyle get cardTitle => _t(16, FontWeight.w600, ink, height: 1.3);
  TextStyle get petName => _t(21, FontWeight.w600, Colors.white, height: 1.15);
  TextStyle get metric => _t(19, FontWeight.w600, ink, height: 1.3);
  TextStyle get body => _t(15, FontWeight.w400, ink, height: 1.45);
  TextStyle get label => _t(13.5, FontWeight.w500, ink, height: 1.3);
  TextStyle get small => _t(13, FontWeight.w400, ink2, height: 1.4);
  TextStyle get button => _t(16, FontWeight.w600, Colors.white, height: 1.0);

  TextStyle style(
    double size,
    FontWeight weight, [
    Color? color,
    double? height,
    double letterSpacing = 0,
  ]) =>
      _t(size, weight, color ?? ink, height: height, letterSpacing: letterSpacing);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x291D2A44),
      offset: Offset(0, 8),
      blurRadius: 22,
      spreadRadius: -12,
    ),
  ];

  static const List<BoxShadow> headerButtonShadow = [
    BoxShadow(
      color: Color(0x4D1D2A44),
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -8,
    ),
  ];

  static const List<BoxShadow> primaryButtonShadow = [
    BoxShadow(
      color: Color(0xCC157A6F),
      offset: Offset(0, 14),
      blurRadius: 24,
      spreadRadius: -14,
    ),
  ];

  static const List<BoxShadow> coralButtonShadow = [
    BoxShadow(
      color: Color(0xCCD9583F),
      offset: Offset(0, 14),
      blurRadius: 24,
      spreadRadius: -14,
    ),
  ];

  @override
  HuTokens copyWith() => const HuTokens();

  @override
  HuTokens lerp(ThemeExtension<HuTokens>? other, double t) => this;
}

extension HuContext on BuildContext {
  HuTokens get hu => Theme.of(this).extension<HuTokens>() ?? const HuTokens();
}

ThemeData buildHuTheme() {
  const t = HuTokens();
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: HuTokens.font,
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.bg,
    colorScheme: ColorScheme.light(
      primary: t.teal,
      onPrimary: Colors.white,
      secondary: t.coral,
      onSecondary: Colors.white,
      surface: t.surface,
      onSurface: t.ink,
      error: t.bad,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: TextSelectionThemeData(cursorColor: t.teal),
    extensions: const [t],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: HuTokens.font,
      bodyColor: t.ink,
      displayColor: t.ink,
    ),
  );
}

class HuLayout {
  static const double side = 22;

  static double top(BuildContext context, double prototypeTop) {
    final inset = MediaQuery.paddingOf(context).top;
    // En pruebas golden o simulador de 440x956 sin safeArea superior, conserva prototypeTop.
    if (inset == 0) return prototypeTop;
    final extra = prototypeTop >= 110 ? 16.0 : 0.0;
    return prototypeTop - 54 + (inset < 24 ? 24 : inset) + extra;
  }
}
