import 'dart:developer' show log;
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:nojcasts/pages/add_page.dart';
import 'package:nojcasts/components/bottom_sheet_player.dart';
import 'package:nojcasts/globals.dart';
import 'package:nojcasts/pages/main_page.dart';
import 'package:nojcasts/db/podcast_db.dart';

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
          secondary: const Color.fromARGB(255, 225, 150, 75),
          onSecondary: const Color.fromARGB(255, 70, 50, 100),
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
  final AudioPlayer _player = AudioPlayer();
  bool _showNavBar = true;
  PodcastDb? _podcastDb;

  int _currentPageIndex = 0;
  late List<Widget> _pageOptions;

  void updateShowNavBar(bool val) {
    setState(() {
      _showNavBar = val;
    });
  }

  void initFolderAndProfile() async {
    await Globals.initGlobals();
    Globals? globals = Globals.getGlobals();
    if (globals == null) {
      return;
    }

    _podcastDb = await PodcastDb.getInstance();

    Directory nojcastsDir = Directory(globals.nojcastsPath);
    if (!nojcastsDir.existsSync()) {
      Directory podDir = Directory(globals.podcastPath);
      podDir.createSync(recursive: true);
      Directory imgDir = Directory(globals.imagePath);
      imgDir.createSync(recursive: true);
      log('Created nojcasts, podcasts, and images directories.');
    }
  }

  @override
  void initState() {
    initFolderAndProfile();
    _pageOptions = [
      MainPage(player: _player, updateShowNavBar: updateShowNavBar),
      const AddPage(),
    ];

    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    if (_podcastDb != null) {
      await _podcastDb?.closeDb();
    }
  }

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (int newIndex) {
        setState(() {
          _currentPageIndex = newIndex;
        });
      },
      currentIndex: _currentPageIndex,
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
    );
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
        child: _pageOptions[_currentPageIndex],
      ),
      bottomNavigationBar: _showNavBar ? bottomNavigationBar() : null,
      bottomSheet: showBottomSheetPlayer(_player.state) ? BottomSheetPlayer(player: _player) : null,
    );
  }
}
