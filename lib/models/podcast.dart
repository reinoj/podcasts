import 'package:cv/cv.dart';

const String columnId = 'id';
const String columnTitle = 'title';
const String columnRssUrl = 'rssUrl';

class Podcast extends CvModelBase {
  final id = CvField<String>(columnId);
  final title = CvField<String>(columnTitle);
  final rssUrl = CvField<String>(columnRssUrl);

  @override
  List<CvField> get fields => [id, title, rssUrl];
}
