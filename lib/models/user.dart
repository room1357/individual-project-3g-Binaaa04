import '../services/database_service.dart';
import 'package:drift/drift.dart';

@DataClassName('Users')
class Users extends Table{
  IntColumn get userId => integer().autoIncrement()();
  TextColumn get fullname => text().withLength(max: 128)();
  TextColumn get email => text().withLength(max: 128)();
  TextColumn get username => text().withLength(max: 128)();
  TextColumn get password => text().withLength(max: 128)();
  DateTimeColumn get createdAt =>dateTime()();
  DateTimeColumn get updatedAt =>dateTime()();
  // final int id;
  // final String username;
  // final String password;
  // final String? fullName;
  // final String email;

  // User({
  //   required this.id,
  //   required this.username,
  //   required this.password,
  //   this.fullName,
  //   required this.email,
  // });

  // factory User.fromDrift(UsersData data) {
  //   return User(
  //     id: data.id,
  //     username: data.username,
  //     password: data.password,
  //     fullName: data.fullName,
  //     email: data.email,
  //   );
  // }

  // Map<String, dynamic> toJson() => {
  //       'id': id,
  //       'username': username,
  //       'password': password,
  //       'fullName': fullName,
  //       'email': email,
  //     };
}
