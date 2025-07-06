import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:nojcasts/globals.dart';
import 'package:nojcasts/ui/shared/navigation_helper.dart';

void main() {
  runApp(const App());
}

void initFolderAndProfile() async {
  Globals globals = await GlobalsObj().globals;

  Directory nojcastsDir = Directory(globals.nojcastsPath);
  if (!nojcastsDir.existsSync()) {
    Directory podDir = Directory(globals.podcastPath);
    podDir.createSync(recursive: true);
    Directory imgDir = Directory(globals.imagePath);
    imgDir.createSync(recursive: true);
    log('Created nojcasts, podcasts, and images directories.');
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    NavigationHelper.instance;
    initFolderAndProfile();

    return MaterialApp.router(
      title: 'nojcasts',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          surface: Colors.grey.shade900,
          onSurface: Colors.grey.shade100,
          primary: Colors.blueGrey.shade600,
          onPrimary: Colors.grey.shade400,
          inversePrimary: Colors.grey.shade800,
          outline: Colors.blueGrey.shade200,
          secondary: const Color.fromARGB(255, 225, 150, 75),
          onSecondary: const Color.fromARGB(255, 70, 50, 100),
        ),
        useMaterial3: true,
      ),
      routerConfig: NavigationHelper.router,
    );
  }
}
