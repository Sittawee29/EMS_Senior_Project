// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    ControlRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ControlPage(),
      );
    },
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardPage(),
      );
    },
    MainRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MainPage(),
      );
    },
    DeviceRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DevicePage(),
      );
    },
    AlertRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AlertPage(),
      );
    },
    EBillingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const EBillingPage(),
      );
    },
    ExportRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ExportPage(),
      );
    },
    PlantDetailRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PlantDetailPage(),
      );
    },
    SettingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingPage(),
      );
    },
  };
}

class ControlRoute extends PageRouteInfo<void> {
  const ControlRoute({List<PageRouteInfo>? children})
      : super(
          ControlRoute.name,
          initialChildren: children,
        );
  static const String name = 'ControlRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );
  static const String name = 'DashboardRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );
  static const String name = 'MainRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

class DeviceRoute extends PageRouteInfo<void> {
  const DeviceRoute({List<PageRouteInfo>? children})
      : super(
          DeviceRoute.name,
          initialChildren: children,
        );
  static const String name = 'DeviceRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

class AlertRoute extends PageRouteInfo<void> {
  const AlertRoute({List<PageRouteInfo>? children})
      : super(
          AlertRoute.name,
          initialChildren: children,
        );
  static const String name = 'AlertRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

class EBillingRoute extends PageRouteInfo<void> {
  const EBillingRoute({List<PageRouteInfo>? children})
      : super(
          EBillingRoute.name,
          initialChildren: children,
        );
  static const String name = 'EBillingRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

class ExportRoute extends PageRouteInfo<void> {
  const ExportRoute({List<PageRouteInfo>? children})
      : super(
          ExportRoute.name,
          initialChildren: children,
        );
  static const String name = 'ExportRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

class PlantDetailRoute extends PageRouteInfo<void> {
  const PlantDetailRoute({List<PageRouteInfo>? children})
      : super(
          PlantDetailRoute.name,
          initialChildren: children,
        );
  static const String name = 'PlantDetailRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

class SettingRoute extends PageRouteInfo<void> {
  const SettingRoute({List<PageRouteInfo>? children})
      : super(
          SettingRoute.name,
          initialChildren: children,
        );
  static const String name = 'SettingRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}