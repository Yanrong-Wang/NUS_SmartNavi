// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:flutter/material.dart' as _i9;
import 'package:smartnavi/pages/add_schedule_screen.dart' as _i1;
import 'package:smartnavi/pages/auth_page.dart' as _i2;
import 'package:smartnavi/pages/edit_schedule_screen.dart' as _i3;
import 'package:smartnavi/pages/home_page.dart' as _i4;
import 'package:smartnavi/pages/homescreens/navigation_screen.dart' as _i5;
import 'package:smartnavi/pages/homescreens/schedule_screen.dart' as _i6;
import 'package:smartnavi/pages/homescreens/setting_screen.dart' as _i7;

/// generated route for
/// [_i1.AddScheduleScreen]
class AddScheduleRoute extends _i8.PageRouteInfo<void> {
  const AddScheduleRoute({List<_i8.PageRouteInfo>? children})
    : super(AddScheduleRoute.name, initialChildren: children);

  static const String name = 'AddScheduleRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i1.AddScheduleScreen();
    },
  );
}

/// generated route for
/// [_i2.AuthPage]
class AuthRoute extends _i8.PageRouteInfo<void> {
  const AuthRoute({List<_i8.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthPage();
    },
  );
}

/// generated route for
/// [_i3.EditScheduleScreen]
class EditScheduleRoute extends _i8.PageRouteInfo<EditScheduleRouteArgs> {
  EditScheduleRoute({
    _i9.Key? key,
    required String scheduleId,
    List<_i8.PageRouteInfo>? children,
  }) : super(
         EditScheduleRoute.name,
         args: EditScheduleRouteArgs(key: key, scheduleId: scheduleId),
         initialChildren: children,
       );

  static const String name = 'EditScheduleRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditScheduleRouteArgs>();
      return _i3.EditScheduleScreen(key: args.key, scheduleId: args.scheduleId);
    },
  );
}

class EditScheduleRouteArgs {
  const EditScheduleRouteArgs({this.key, required this.scheduleId});

  final _i9.Key? key;

  final String scheduleId;

  @override
  String toString() {
    return 'EditScheduleRouteArgs{key: $key, scheduleId: $scheduleId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditScheduleRouteArgs) return false;
    return key == other.key && scheduleId == other.scheduleId;
  }

  @override
  int get hashCode => key.hashCode ^ scheduleId.hashCode;
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i8.PageRouteInfo<void> {
  const HomeRoute({List<_i8.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i4.HomePage();
    },
  );
}

/// generated route for
/// [_i5.NavigationScreen]
class NavigationRoute extends _i8.PageRouteInfo<NavigationRouteArgs> {
  NavigationRoute({
    _i9.Key? key,
    String? prefilledDestination,
    List<_i8.PageRouteInfo>? children,
  }) : super(
         NavigationRoute.name,
         args: NavigationRouteArgs(
           key: key,
           prefilledDestination: prefilledDestination,
         ),
         initialChildren: children,
       );

  static const String name = 'NavigationRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NavigationRouteArgs>(
        orElse: () => const NavigationRouteArgs(),
      );
      return _i5.NavigationScreen(
        key: args.key,
        prefilledDestination: args.prefilledDestination,
      );
    },
  );
}

class NavigationRouteArgs {
  const NavigationRouteArgs({this.key, this.prefilledDestination});

  final _i9.Key? key;

  final String? prefilledDestination;

  @override
  String toString() {
    return 'NavigationRouteArgs{key: $key, prefilledDestination: $prefilledDestination}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NavigationRouteArgs) return false;
    return key == other.key &&
        prefilledDestination == other.prefilledDestination;
  }

  @override
  int get hashCode => key.hashCode ^ prefilledDestination.hashCode;
}

/// generated route for
/// [_i6.ScheduleScreen]
class ScheduleRoute extends _i8.PageRouteInfo<void> {
  const ScheduleRoute({List<_i8.PageRouteInfo>? children})
    : super(ScheduleRoute.name, initialChildren: children);

  static const String name = 'ScheduleRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i6.ScheduleScreen();
    },
  );
}

/// generated route for
/// [_i7.SettingScreen]
class SettingRoute extends _i8.PageRouteInfo<void> {
  const SettingRoute({List<_i8.PageRouteInfo>? children})
    : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i7.SettingScreen();
    },
  );
}
