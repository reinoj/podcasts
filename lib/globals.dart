import 'dart:io';

import 'package:path_provider/path_provider.dart';

class GlobalObjs {
  final String _documentsPath;
  final String _nojcastsPath;
  final String _podcastPath;
  final String _imagePath;

  String get documentsPath => _documentsPath;
  String get nojcastsPath => _nojcastsPath;
  String get podcastPath => _podcastPath;
  String get imagePath => _imagePath;

  GlobalObjs(
    this._documentsPath,
    this._nojcastsPath,
    this._podcastPath,
    this._imagePath,
  );
}

class Globals {
  static GlobalObjs? _globals;

  GlobalObjs? get globals => _globals;
  Future<void> get ready async => _globals ??= await initGlobals();

  Future<GlobalObjs> initGlobals() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String documentsPath = documentsDir.path;
    String nojcastsPath = '$documentsPath/nojcasts';
    String podcastPath = '$nojcastsPath/podcasts';
    String imagePath = '$nojcastsPath/images';

    _globals = GlobalObjs(documentsPath, nojcastsPath, podcastPath, imagePath);
    return _globals!;
  }
}
