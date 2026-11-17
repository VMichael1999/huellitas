abstract class Clock {
  const Clock();
  DateTime now();

  DateTime get today {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }

  int get nowMinutes {
    final n = now();
    return n.hour * 60 + n.minute;
  }
}

class SystemClock extends Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

class FixedClock extends Clock {
  const FixedClock(this._fixed);
  final DateTime _fixed;

  /// Fecha de las capturas y pruebas: sábado 14 de noviembre de 2026, 3:30 p. m.
  static final FixedClock demo = FixedClock(DateTime(2026, 11, 14, 15, 30));

  @override
  DateTime now() => _fixed;
}
