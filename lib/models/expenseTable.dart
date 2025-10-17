import 'package:drift/drift.dart';
@DataClassName('Expense')

class expenseTable extends Table{
  IntColumn get expenseId => integer().autoIncrement()();
  IntColumn get userId => integer()();
  TextColumn get title => text().withLength(max: 128)();
  IntColumn get categoryId => integer()();
  IntColumn get amount => integer()();
  DateTimeColumn get date =>dateTime()();
  TextColumn get description => text().withLength(max: 128)();
  DateTimeColumn get createdAt =>dateTime()();
  DateTimeColumn get updatedAt =>dateTime()();
  DateTimeColumn get deletedAt =>dateTime().nullable()();
}