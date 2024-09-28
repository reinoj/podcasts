import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:nojcasts/add_page.dart';
import 'package:nojcasts/bottom_sheet_player.dart';
import 'package:nojcasts/globals.dart';
import 'package:nojcasts/main_page.dart';
import 'package:nojcasts/podcast_overview.dart';
import 'package:nojcasts/profile.dart';

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
          onSurface: Colors.grey.shade100,
          primary: Colors.blueGrey.shade600,
          onPrimary: Colors.grey.shade400,
          inversePrimary: Colors.grey.shade800,
          outline: Colors.blueGrey.shade200,
          onSecondary: const Color.fromARGB(255, 70, 50, 100),
          secondary: const Color.fromARGB(255, 225, 150, 75),
          // secondary: const Color.fromARGB(255, 70, 50, 100),
          // onSecondary: const Color.fromARGB(255, 225, 150, 75),
        ),
        useMaterial3: true,
      ),
      home: const MainScaffold(title: 'nojcasts'),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final String title;

  const MainScaffold({super.key, required this.title});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentBottomIndex = 0;
  final AudioPlayer _player = AudioPlayer();
  late List<Widget> _navigationOptions;
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
    if (!nojcastsDir.existsSync()) {
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
    _navigationOptions = [
      MainPage(player: _player),
      const AddPage(),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: showBottomSheetPlayer(_player.state)
            ? const EdgeInsets.only(bottom: bottomSheetHeight)
            : const EdgeInsets.only(bottom: 0.0),
        child: _navigationOptions[_currentBottomIndex],
      ),
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
      bottomSheet: showBottomSheetPlayer(_player.state) ? BottomSheetPlayer(player: _player) : null,
    );
  }
}
