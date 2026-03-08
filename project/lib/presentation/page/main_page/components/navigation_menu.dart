part of '../page.dart';

class _NavigationMenu extends StatefulWidget {
  final Function(String) onPlantChanged; 
  const _NavigationMenu({super.key, required this.onPlantChanged}); 

  @override
  State<_NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<_NavigationMenu> {
  bool _isListenerAdded = false;
  
  late String _selectedPlant;

  @override
  void initState() {
    super.initState();
    _selectedPlant = MqttService().selectedPlant;
  }

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
    return StreamBuilder<dynamic>(
      stream: MqttService().dataStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? MqttService().currentData;
        bool hasAlarm = false;
        //hasAlarm = true;
        if (data != null) {
          try {
            if (_selectedPlant == 'UTI') {
              hasAlarm = (data.BESS_Fault == 1.0) ||
                         (data.BESS_Communication_Fault == 1.0) ||
                         (data.PV1_Fault == 1.0) ||
                         (data.PV1_Communication_Fault == 1.0) ||
                         (data.PV2_Communication_Fault == 1.0) ||
                         (data.PV3_Communication_Fault == 1.0) ||
                         (data.PV4_Communication_Fault == 1.0);
            } else if (_selectedPlant == 'TPI') {
              final racks = data.BESS_RACKS;
              if (racks != null) {
                for (var rack in racks) {
                  if (rack['PSCFAULT'] == 1.0 || 
                      rack['PSCCOMMFAULT'] == 1.0 || 
                      rack['PSCALARM'] == 1.0) {
                    hasAlarm = true;
                    break;
                  }
                }
              }
            }
          } catch (e) {
            debugPrint("Error checking alarm for menu: $e");
          }
        }

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
            const SizedBox(height: 10),
            
            Center(
              child: Container(
                width: 180,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Palette.dirtyWhite.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Palette.dirtyWhite.withOpacity(0.3)),
                ),
                child: PopupMenuButton<String>(
                  initialValue: _selectedPlant,
                  color: Palette.darkBlue,
                  elevation: 8,
                  offset: const Offset(-16, 48),
                  constraints: const BoxConstraints(
                    minWidth: 180,
                    maxWidth: 180,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Palette.dirtyWhite.withOpacity(0.3), width: 1),
                  ),
                  onSelected: (String newValue) {
                    if (newValue != _selectedPlant) {
                      setState(() {
                        _selectedPlant = newValue;
                      });
                      MqttService().changePlant(newValue);
                      widget.onPlantChanged(newValue);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return <String>['UTI', 'TPI'].map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 40, 
                        child: Text(
                          choice,
                          style: TextStyles.myriadProSemiBold12DirtyWhite,
                        ),
                      );
                    }).toList();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedPlant,
                          style: TextStyles.myriadProSemiBold12DirtyWhite,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Palette.dirtyWhite.withOpacity(0.8),
                        ),
                      ],
                    ),
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
              isBlinking: hasAlarm,
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
    );
  }
}

class _MenuItem extends StatefulWidget {
  const _MenuItem({
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.isBlinking = false,
  });

  final IconData icon;
  final String text;
  final void Function() onTap;
  final bool isSelected;
  final bool isBlinking;

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red.withOpacity(1),
    ).animate(_controller);

    if (widget.isBlinking) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _MenuItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlinking != oldWidget.isBlinking) {
      if (widget.isBlinking) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        
        // จัดการสี Background ของปุ่ม
        Color? bgColor;
        
        // ถ้าปกติจะใช้สีฟ้าของเมนูที่ถูกเลือก หรือ Transparent ถ้าไม่ถูกเลือก
        if (widget.isSelected) {
          bgColor = Palette.lightBlue; 
        }

        // 🌟 ถ้ากำลังกระพริบ ให้เอาสีแดงมาผสม
        if (widget.isBlinking) {
          if (widget.isSelected) {
            // ถ้าเลือกอยู่ แล้วกระพริบด้วย -> ผสมสีฟ้ากับสีแดง
            bgColor = Color.lerp(Palette.lightBlue, Colors.red, _controller.value);
          } else {
            // ถ้าไม่ได้เลือก แล้วกระพริบ -> ใช้สีแดงใสๆ สลับกับ Transparent
            bgColor = _colorAnimation.value;
          }
        }

        return Flexible(
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              width: 205,
              height: 42,
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 43.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isSelected
                          ? Palette.dirtyWhite
                          : Palette.dirtyWhite.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.text,
                      style: widget.isSelected
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
      },
    );
  }
}