import 'package:auto_route/auto_route.dart';

import '../page/control_page/control_page.dart';
import '../page/dashboard_page/page.dart';
import '../page/main_page/page.dart';
import '../page/device_page/device_page.dart';
import '../page/alert_page/alert_page.dart';
import '../page/ebilling_page/ebilling_page.dart';
import '../page/export_page/export_page.dart';
import '../page/plant_detail_page/plant_detail_page.dart';
import '../page/setting_page/setting_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        CustomRoute(
          initial: true,
          page: MainRoute.page,
          transitionsBuilder: TransitionsBuilders.noTransition,
          children: <AutoRoute>[
            CustomRoute(
              initial: true,
              path: 'dashboard',
              page: DashboardRoute.page,
              durationInMilliseconds: 0,
              reverseDurationInMilliseconds: 1,
              transitionsBuilder: TransitionsBuilders.noTransition,
            ),
            CustomRoute(
              path: 'control',
              page: ControlRoute.page,
              durationInMilliseconds: 0,
              reverseDurationInMilliseconds: 1,
              transitionsBuilder: TransitionsBuilders.noTransition,
            ),
            CustomRoute(
              path: 'device',
              page: DeviceRoute.page,
              durationInMilliseconds: 0,
              reverseDurationInMilliseconds: 1,
              transitionsBuilder: TransitionsBuilders.noTransition,
            ),
            CustomRoute(
              path: 'alert',
              page: AlertRoute.page,
              durationInMilliseconds: 0,
              reverseDurationInMilliseconds: 1,
              transitionsBuilder: TransitionsBuilders.noTransition,
            ),
            CustomRoute(
              path: 'ebilling',
              page: EBillingRoute.page,
              durationInMilliseconds: 0,
              reverseDurationInMilliseconds: 1,
              transitionsBuilder: TransitionsBuilders.noTransition,
            ),
            CustomRoute(
              path: 'export',
              page: ExportRoute.page,
              durationInMilliseconds: 0,
              reverseDurationInMilliseconds: 1,
              transitionsBuilder: TransitionsBuilders.noTransition,
            ),
            CustomRoute(
              path: 'plantdetail',
              page: PlantDetailRoute.page,
              durationInMilliseconds: 0,
              reverseDurationInMilliseconds: 1,
              transitionsBuilder: TransitionsBuilders.noTransition,
            ),
            CustomRoute(
              path: 'setting',
              page: SettingRoute.page,
              durationInMilliseconds: 0,
              reverseDurationInMilliseconds: 1,
              transitionsBuilder: TransitionsBuilders.noTransition,
            ),
          ],
        ),
      ];
}
