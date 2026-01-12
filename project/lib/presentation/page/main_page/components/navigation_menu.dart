part of '../page.dart';

class _NavigationMenu extends StatefulWidget {
  const _NavigationMenu();

  @override
  State<_NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<_NavigationMenu> {
  bool _isListenerAdded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isListenerAdded) {
      AutoRouterDelegate.of(context).addListener(() {
        if (mounted) setState(() {});
      });
      _isListenerAdded = true;
    }
  }

  void _onTabTap(PageRouteInfo<dynamic> route) {
    context.pushRoute(route);
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = AutoRouterDelegate.of(context).urlState.path;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: ProjectAssets.icons.prologic.svg(
              height: 120,
              width: 120,
              colorFilter: Palette.white.toColorFilter,
            ),
          ),
        ),
        const SizedBox(height: 40),
        _MenuItem(
          icon: Symbols.bar_chart_4_bars,
          isSelected: currentUrl == '/dashboard',
          onTap: () => _onTabTap(const DashboardRoute()),
          text: 'Dashboard',
        ),
        _MenuItem(
          icon: Icons.memory,
          isSelected: currentUrl == '/device',
          onTap: () => _onTabTap(const DeviceRoute()),
          text: 'Device',
        ),
        _MenuItem(
          icon: Icons.notification_important,
          isSelected: currentUrl == '/alarm',
          onTap: () => _onTabTap(const AlarmRoute()),
          text: 'Alarm',
        ),
        _MenuItem(
          icon: Icons.paid,
          isSelected: currentUrl == '/ebilling',
          onTap: () => _onTabTap(const EBillingRoute()),
          text: 'E-Billing',
        ),
        _MenuItem(
          // --- แก้ไขจุดที่ 1: เอา Icon() ออก ส่งแค่ Symbols.xxx ---
          icon: Symbols.file_export, 
          isSelected: currentUrl == '/export',
          onTap: () => _onTabTap(const ExportRoute()),
          text: 'Export',
        ),
        _MenuItem(
          icon: Icons.factory,
          isSelected: currentUrl == '/plantdetail',
          onTap: () => _onTabTap(const PlantDetailRoute()),
          text: 'Plant Detail',
        ),
        _MenuItem(
          icon: Symbols.settings_account_box,
          isSelected: currentUrl == '/setting',
          onTap: () => _onTabTap(const SettingRoute()),
          text: 'Setting',
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final void Function() onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 205,
          height: 42,
          margin: const EdgeInsets.only(bottom: 25),
          decoration: isSelected
              ? const BoxDecoration(
                  color: Palette.lightBlue,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.only(left: 43.0),
            child: Row(
              children: <Widget>[
                // --- แก้ไขจุดที่ 2 และ 3: เปลี่ยน SvgPicture เป็น Icon ---
                Icon(
                  icon, // ใช้ตัวแปร icon ที่รับมา
                  size: 20, // ปรับขนาดตามความเหมาะสม (ของเดิม svg 16 อาจจะเล็กไปสำหรับ IconData)
                  color: isSelected
                      ? Palette.dirtyWhite
                      : Palette.dirtyWhite.withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: isSelected
                      ? TextStyles.myriadProSemiBold12DirtyWhite
                      : TextStyles.myriadProSemiBold12DirtyWhite.copyWith(
                          color: Palette.dirtyWhite.withOpacity(0.8),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}