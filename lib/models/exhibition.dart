import 'package:hive/hive.dart';

part 'exhibition.g.dart';

@HiveType(typeId: 1)
class Exhibition {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String imageUrl;

  @HiveField(2)
  final String linkUrl;

  Exhibition({required this.title, required this.imageUrl, required this.linkUrl});
}
