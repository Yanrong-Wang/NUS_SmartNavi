import 'package:auto_route/auto_route.dart';
import 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: "/auth", page: AuthRoute.page),
    AutoRoute(path: "/", page: HomeRoute.page, initial: true),
  ];
}
