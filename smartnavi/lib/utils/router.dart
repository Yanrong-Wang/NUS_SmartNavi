import 'package:auto_route/auto_route.dart';
import 'guard.dart';
import 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: "/auth", page: AuthRoute.page),
    AutoRoute(
      path: "/",
      page: HomeRoute.page,
      initial: true,
      guards: [AuthGuard()],
      children: [
        AutoRoute(
          path: "navigation",
          page: NavigationRoute.page,
          initial: true,
        ),
        AutoRoute(path: "nearby", page: NearbyRoute.page),
        AutoRoute(path: "schedule", page: ScheduleRoute.page),
        AutoRoute(path: "settings", page: SettingRoute.page),
      ],
    ),
  ];
}
