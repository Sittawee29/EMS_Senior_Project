part of '../page.dart';

class _NavigationMenu extends StatefulWidget {
  final Function(String) onPlantChanged; 
  const _NavigationMenu({super.key, required this.onPlantChanged}); 

  @override
  State<_NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<_NavigationMenu> {
  bool _isListenerAdded = false;
  
  String _selectedPlant = 'UTI';

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
        const SizedBox(height: 10), // ปรับระยะห่างให้พอดีขึ้น
        
        // 2. เพิ่ม UI สำหรับ Switch Plant
        Center(
          child: Container(
            width: 180, // กำหนดความกว้างให้ใกล้เคียงกับเมนู
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Palette.dirtyWhite.withOpacity(0.1), // สีพื้นหลังจางๆ
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Palette.dirtyWhite.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPlant,
                dropdownColor: Palette.lightBlue, // สีพื้นหลังตอนกาง Dropdown ออก
                icon: Icon(
                  Icons.arrow_drop_down, 
                  color: Palette.dirtyWhite.withOpacity(0.8)
                ),
                isExpanded: true,
                style: TextStyles.myriadProSemiBold12DirtyWhite, // ใช้ Style เดิมของโปรเจกต์
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPlant = newValue;
                    });
                    
                    // เรียกใช้งานฟังก์ชันเพื่อเปลี่ยน Plant ใน Service
                    MqttService().changePlant(newValue);
                    widget.onPlantChanged(newValue);
                  }
                },
                items: <String>['UTI', 'TPI']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
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
                Icon(
                  icon,
                  size: 20,
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