import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';

import 'add_page.dart';
import 'home_page.dart';
import 'globals.dart';
import 'podcast_overview.dart';
import 'profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          surface: Colors.grey.shade900,
          onSurface: Colors.grey.shade200,
          primary: Colors.blueGrey.shade600,
          onPrimary: Colors.grey.shade400,
          inversePrimary: Colors.grey.shade800,
          outline: Colors.blueGrey.shade200,
        ),
        useMaterial3: true,
      ),
      home: const MainScaffold(title: 'nojcasts'),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, required this.title});

  final String title;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentBottomIndex = 0;
  final List<Widget> _navigationOptions = [
    const HomePage(),
    const AddPage(),
  ];
  Profile? _profile;

  void updateProfile(Profile newProfile, File wFile) {
    setState(() {
      _profile = newProfile;
    });
    wFile.writeAsStringSync(jsonEncode(_profile!.toJson()));
  }

  void initFolderAndProfile() async {
    await Globals.initGlobals();
    Globals? globals = Globals.getGlobals();
    if (globals == null) {
      return;
    }

    Directory nojcastsDir = Directory(globals.nojcastsPath);
    if (nojcastsDir.existsSync()) {
      Directory podDir = Directory(globals.podcastPath);
      podDir.createSync(recursive: true);
      Directory imgDir = Directory(globals.imagePath);
      imgDir.createSync(recursive: true);
      developer.log('Created nojcasts, podcasts, and images directories.');
    }

    File profileFile = File('${globals.nojcastsPath}/profile.json');
    if (!profileFile.existsSync()) {
      updateProfile(Profile(podcasts: []), profileFile);
    } else {
      _profile = Profile.fromJson(await getProfile());
    }
  }

  @override
  void initState() {
    initFolderAndProfile();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: _navigationOptions[_currentBottomIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int newIndex) {
          setState(() {
            _currentBottomIndex = newIndex;
          });
        },
        currentIndex: _currentBottomIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
        ],
      ),
    );
  }
}
