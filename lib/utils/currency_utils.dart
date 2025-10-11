import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  return formatter.format(amount);
}
