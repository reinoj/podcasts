import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nojcasts/ui/add_page/add_page.dart';
import 'package:nojcasts/ui/home_page/home_page.dart';
import 'package:nojcasts/ui/podcast_page/podcast_page.dart';
import 'package:nojcasts/ui/shared/bottom_navigation_page.dart';

abstract final class Routes {
  static const home = '/';
  static const add = '/add';
  static const podcast = '/podcast/:title';
}

class NavigationHelper {
  static final NavigationHelper _instance = NavigationHelper._internal();

  static NavigationHelper get instance => _instance;

  static late final GoRouter router;

  final AudioPlayer _player = AudioPlayer();

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
                path: Routes.home,
                pageBuilder: (context, state) {
                  return getPage(
                    child: HomePage(
                      player: _player,
                    ),
                    state: state,
                  );
                },
                routes: [
                  GoRoute(
                    path: Routes.podcast,
                    pageBuilder: (context, state) {
                      return getPage(
                        child: PodcastPage(
                          title: state.pathParameters['title']!,
                          player: _player,
                        ),
                        state: state,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: addNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.add,
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
    ];

    router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: Routes.home,
      routes: routes,
    );
  }

  static Page getPage({required Widget child, required GoRouterState state}) {
    return MaterialPage(key: state.pageKey, child: child);
  }
}
