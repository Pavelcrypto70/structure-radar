import 'package:intl/intl.dart';

abstract final class SrFormat {
  static final _score = NumberFormat('0');
  static final _compact = NumberFormat.compact();

  static String score(num v) => _score.format(v);

  static String price(num v) {
    final d = v.toDouble();
    if (d >= 1000) return d.toStringAsFixed(2);
    if (d >= 1) return d.toStringAsFixed(4);
    return d.toStringAsFixed(6);
  }

  static String compact(num v) => _compact.format(v);

  static String pct(num v) => '${v.toStringAsFixed(1)}%';
}
