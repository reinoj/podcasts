import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nojcasts/profile.dart';
import 'package:path_provider/path_provider.dart';

import 'add_page.dart';
import 'home_page.dart';

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

  void initFolderAndProfile() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    Directory nojcastsDir = Directory('${documentsDir.path}/nojcasts');
    if (!nojcastsDir.existsSync()) {
      nojcastsDir.createSync(recursive: true);
      developer.log('Created nojcasts directory in documents directory.');
    }

    File profile = File('${nojcastsDir.path}/profile.json');
    if (!profile.existsSync()) {
      profile.writeAsStringSync(jsonEncode(Profile(podcasts: []).toJson()));
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
