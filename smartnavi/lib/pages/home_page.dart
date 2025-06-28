import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:smartnavi/utils/router.gr.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        NavigationRoute(),
        ScheduleRoute(),
        NearbyRoute(),
        SettingRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: (index) {
            tabsRouter.setActiveIndex(index);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.map), label: 'Navigation'),
            NavigationDestination(
              icon: Icon(Icons.calendar_today),
              label: 'Schedule',
            ),
            NavigationDestination(
              icon: Icon(Icons.location_on),
              label: 'Nearby',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      },
    );
  }
}
