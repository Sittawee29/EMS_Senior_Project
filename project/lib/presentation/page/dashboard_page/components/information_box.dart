part of '../page.dart';

class _InformationBox extends StatelessWidget {
  const _InformationBox({
    required this.icon,
    required this.backgroundColor,
    required this.number,
    required this.text,
    this.unit = '',
    // ignore: unused_element_parameter
  });

  final Widget icon;
  final Color backgroundColor;
  final double number;
  final String text;
  final String unit;

  String _formatNumber(double number) {
    String formatted;
    if (number.abs() >= 1000000000) {
      formatted = NumberFormat.compact().format(number);
    } else {
      formatted = NumberFormat.decimalPattern().format(number).replaceAll(',', ' '); 
    }
    if (unit.isNotEmpty) {
      formatted = '$formatted $unit';
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 268,
      padding: const EdgeInsets.only(top: 22, bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: backgroundColor,
            child: icon,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            
          ),
          const SizedBox(height: 7),
          Text(text, style: TextStyles.myriadProRegular16DarkGrey),
        ],
      ),
    );
  }
}
