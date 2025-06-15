import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String image;

  @HiveField(4)
  String? displayName;

  @HiveField(5)
  String? provider;

  // constructor
  UserModel({
    required this.uid,
    required this.name,
    this.email,
    required this.image,
    this.displayName,
    this.provider,
  });
}
