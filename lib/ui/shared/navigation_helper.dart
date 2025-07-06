import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nojcasts/services/podcast_repository.dart';
import 'package:nojcasts/ui/add_page/add_page.dart';
import 'package:nojcasts/ui/main_page/main_page.dart';
import 'package:nojcasts/ui/main_page/podcast_viewmodel.dart';
import 'package:nojcasts/ui/podcast_page/podcast_page.dart';
import 'package:nojcasts/ui/shared/bottom_navigation_page.dart';

class NavigationHelper {
  static final NavigationHelper _instance = NavigationHelper._internal();

  static NavigationHelper get instance => _instance;

  static late final GoRouter router;

  final AudioPlayer _player = AudioPlayer();
  MainViewmodel mainViewmodel = MainViewmodel(
    podcastRepository: PodcastRepository(),
  );

  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  static final GlobalKey<NavigatorState> parentNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> mainNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> addNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> podcastNavigatorKey =
      GlobalKey<NavigatorState>();

  static const String mainPath = '/';
  static const String addPath = '/add';
  // static const String podcastPath = '/podcast';
  static const String podcastPath = '/:title';

  factory NavigationHelper() {
    return _instance;
  }

  NavigationHelper._internal() {
    final routes = [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: parentNavigatorKey,
        branches: [
          StatefulShellBranch(
            navigatorKey: mainNavigatorKey,
            routes: [
              GoRoute(
                path: mainPath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: MainPage(
                      player: _player,
                      mainViewmodel: mainViewmodel,
                    ),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: addNavigatorKey,
            routes: [
              GoRoute(
                path: addPath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: const AddPage(),
                    state: state,
                  );
                },
              ),
            ],
          ),
        ],
        pageBuilder: (context, state, navigationShell) {
          return getPage(
            child: BottomNavigationPage(
              player: _player,
              child: navigationShell,
            ),
            state: state,
          );
        },
      ),
      GoRoute(
        path: podcastPath,
        pageBuilder: (context, state) {
          return getPage(
            child: PodcastPage(
              title: state.pathParameters['title']!,
              viewmodel: mainViewmodel,
              player: _player,
              updateShowPlayer: () {},
            ),
            state: state,
          );
        },
      ),
    ];

    router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: mainPath,
      routes: routes,
    );
  }

  static Page getPage({required Widget child, required GoRouterState state}) {
    return MaterialPage(key: state.pageKey, child: child);
  }
}
