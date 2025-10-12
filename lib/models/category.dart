import 'package:drift/drift.dart';

@DataClassName('Categories')

class Categories extends Table{
  IntColumn get categoryId => integer().autoIncrement()();
  TextColumn get categoryName => text().withLength(max: 128)();
  DateTimeColumn get createdAt =>dateTime()();
  DateTimeColumn get updatedAt =>dateTime()();
  DateTimeColumn get deletedAt =>dateTime().nullable()();
}
