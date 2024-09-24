import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Globals2 {
  late String documentsPath;
  late String nojcastsPath;
  late String podcastPath;
  late String imagePath;

  static final Globals2 _globals = Globals2._create();

  factory Globals2() {
    return _globals;
  }

  Globals2._create() {
    getApplicationDocumentsDirectory().then((Directory dir) {
      documentsPath = dir.path;
      nojcastsPath = '$documentsPath/nojcasts';
      podcastPath = '$nojcastsPath/podcasts';
      imagePath = '$nojcastsPath/images';
    });
  }
}

class Globals {
  late String documentsPath;
  late String nojcastsPath;
  late String podcastPath;
  late String imagePath;

  static Globals? _globals;

  Globals(this.documentsPath, this.nojcastsPath, this.podcastPath, this.imagePath);

  static Globals? getGlobals() {
    return _globals;
  }

  static Future<void> initGlobals() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String documentsPath = documentsDir.path;
    String nojcastsPath = '$documentsPath/nojcasts';
    String podcastPath = '$nojcastsPath/podcasts';
    String imagePath = '$nojcastsPath/images';
    _globals = Globals(documentsPath, nojcastsPath, podcastPath, imagePath);
  }
}
