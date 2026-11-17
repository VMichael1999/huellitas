/// Formateadores de moneda, fechas relativas y horas en español neutro (`es_419`),
/// idénticos a las funciones del prototipo HTML.
class Money {
  /// `$35` cuando es entero y `$54.90` cuando lleva centavos (`usd` en HTML).
  static String usd(num n) {
    final d = n.toDouble();
    if (d == d.roundToDouble()) {
      return '\$${d.toInt()}';
    }
    return '\$${d.toStringAsFixed(2)}';
  }

  /// Siempre con dos decimales (`usd2` en HTML, usado en tienda/carrito/checkout).
  static String usd2(num n) => '\$${n.toDouble().toStringAsFixed(2)}';
}

class HuFormat {
  static const List<String> dow = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'];
  static const List<String> dowLong = [
    'domingo',
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
  ];
  static const List<String> mon = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  static const List<String> monLong = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  static const List<String> wdn = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  static String pad2(int n) => n.toString().padLeft(2, '0');

  /// Índice 0=dom..6=sáb como `Date.getDay()` en JS.
  static int jsDay(DateTime d) => d.weekday % 7;

  static String iso(DateTime d) =>
      '${d.year}-${pad2(d.month)}-${pad2(d.day)}';

  static DateTime fromIso(String s) {
    final parts = s.split('-');
    if (parts.length != 3) return DateTime(2026, 11, 14);
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static DateTime addDays(DateTime d, int n) =>
      DateTime(d.year, d.month, d.day + n);

  static String rd(DateTime today, int n) => iso(addDays(today, n));

  static String fShort(String s) {
    final d = fromIso(s);
    return '${dow[jsDay(d)]} ${d.day} ${mon[d.month - 1]}';
  }

  static String fLong(String s) {
    final d = fromIso(s);
    return '${dowLong[jsDay(d)]} ${d.day} de ${monLong[d.month - 1]}';
  }

  static String fDate(String s) {
    final d = fromIso(s);
    return '${d.day} ${mon[d.month - 1]} ${d.year}';
  }

  static String cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String hm(int minutes) =>
      '${pad2(minutes ~/ 60)}:${pad2(minutes % 60)}';

  static String ampm(String hhmm) {
    if (!hhmm.contains(':')) return hhmm;
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final h12 = ((h + 11) % 12) + 1;
    final suffix = h < 12 ? 'a. m.' : 'p. m.';
    return '$h12:${pad2(m)} $suffix';
  }

  static int toMin(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return h * 60 + m;
  }

  static int daysFrom(DateTime today, String isoDate) {
    final d = fromIso(isoDate);
    final t = DateTime(today.year, today.month, today.day);
    return d.difference(t).inDays;
  }

  static String rel(DateTime today, String isoDate) {
    final n = daysFrom(today, isoDate);
    if (n == 0) return 'hoy';
    if (n == 1) return 'mañana';
    if (n == -1) return 'ayer';
    if (n > 1) return 'en $n días';
    return 'hace ${-n} días';
  }

  static String ageOf(DateTime today, String bornIso) {
    final d = fromIso(bornIso);
    int m = (today.year - d.year) * 12 + today.month - d.month;
    if (today.day < d.day) m--;
    if (m < 12) {
      final safe = m < 0 ? 0 : m;
      return '$safe ${m == 1 ? 'mes' : 'meses'}';
    }
    final y = m ~/ 12;
    return '$y ${y == 1 ? 'año' : 'años'}';
  }

  static String nfLabel(DateTime today, ({String d, int t})? nf) {
    if (nf == null) return 'Sin horas';
    final dayPart = daysFrom(today, nf.d) < 2
        ? rel(today, nf.d)
        : fShort(nf.d);
    return '${cap(dayPart)} ${ampm(hm(nf.t))}';
  }

  /// Normaliza tildes conservando ñ, igual que `norm(s)` del HTML.
  static String norm(String s) {
    const map = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
    };
    final lower = s.toLowerCase();
    final sb = StringBuffer();
    for (int i = 0; i < lower.length; i++) {
      final ch = lower[i];
      sb.write(map[ch] ?? ch);
    }
    return sb.toString();
  }
}
