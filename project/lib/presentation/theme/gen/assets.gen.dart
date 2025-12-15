/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/bell.svg
  SvgGenImage get bell => const SvgGenImage('assets/icons/bell.svg');

  /// File path: assets/icons/chart_purple.svg
  SvgGenImage get chartPurple =>
      const SvgGenImage('assets/icons/chart_purple.svg');

  /// File path: assets/icons/cup.svg
  SvgGenImage get cup => const SvgGenImage('assets/icons/cup.svg');

  /// File path: assets/icons/home.svg
  SvgGenImage get home => const SvgGenImage('assets/icons/home.svg');

  /// File path: assets/icons/new_user_blue.svg
  SvgGenImage get newUserBlue =>
      const SvgGenImage('assets/icons/new_user_blue.svg');

  /// File path: assets/icons/rocket_orange.svg
  SvgGenImage get rocketOrange =>
      const SvgGenImage('assets/icons/rocket_orange.svg');

  /// File path: assets/icons/speedometer_yellow.svg
  SvgGenImage get speedometerYellow =>
      const SvgGenImage('assets/icons/speedometer_yellow.svg');

  /// File path: assets/icons/stack.svg
  SvgGenImage get stack => const SvgGenImage('assets/icons/stack.svg');

  /// File path: assets/icons/ECE_logo.svg
  SvgGenImage get ECELogo => const SvgGenImage('assets/icons/ECE_logo.svg');

  /// File path: assets/icons/ECE_white_logo.svg
  SvgGenImage get ECE_white_Logo =>
      const SvgGenImage('assets/icons/ECE_white_logo.svg');

  SvgGenImage get device =>
      const SvgGenImage('assets/icons/device.svg');
      
  SvgGenImage get alarm =>
      const SvgGenImage('assets/icons/alarm.svg');

  SvgGenImage get ebilling =>
      const SvgGenImage('assets/icons/ebilling.svg');

  SvgGenImage get export =>
      const SvgGenImage('assets/icons/export.svg');

  SvgGenImage get plant =>
      const SvgGenImage('assets/icons/plant.svg');

  SvgGenImage get setting =>
      const SvgGenImage('assets/icons/setting.svg');

  SvgGenImage get dashboard =>
      const SvgGenImage('assets/icons/dashboard.svg');

  SvgGenImage get control =>
      const SvgGenImage('assets/icons/control.svg');

  SvgGenImage get prologic =>
      const SvgGenImage('assets/icons/prologic.svg');

  SvgGenImage get production =>
      const SvgGenImage('assets/icons/production.svg');

  SvgGenImage get gridfeedin =>
      const SvgGenImage('assets/icons/gridfeedin.svg');

  SvgGenImage get carbonprevention =>
      const SvgGenImage('assets/icons/carbonprevention.svg');

  SvgGenImage get coin =>
      const SvgGenImage('assets/icons/coin.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
        bell,
        chartPurple,
        cup,
        home,
        newUserBlue,
        rocketOrange,
        speedometerYellow,
        stack,
        ECELogo,
        ECE_white_Logo,
        device,
        alarm,
        ebilling,
        export,
        plant,
        setting,
        dashboard,
        control,
        prologic,
        production,
        gridfeedin,
        carbonprevention,
        coin,
      ];
}

class ProjectAssets {
  ProjectAssets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
}

class SvgGenImage {
  const SvgGenImage(this._assetName);

  final String _assetName;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    SvgTheme theme = const SvgTheme(),
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    return SvgPicture.asset(
      _assetName,
      key: key,
      matchTextDirection: matchTextDirection,
      bundle: bundle,
      package: package,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      theme: theme,
      colorFilter: colorFilter,
      color: color,
      colorBlendMode: colorBlendMode,
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
