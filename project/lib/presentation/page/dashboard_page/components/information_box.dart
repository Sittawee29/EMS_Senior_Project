part of '../page.dart';

class _InformationBox extends StatelessWidget {
  const _InformationBox({
    required this.icon,
    required this.backgroundColor,
    required this.number,
    required this.percent,
    required this.text,
    required this.haveIncreased,
    // ignore: unused_element_parameter
    this.showPercent = false,
  });

  final Widget icon;
  final Color backgroundColor;

  final double number;

  final bool showPercent;

  final double percent;

  final bool haveIncreased;

  final String text;

  String formatNumber(double number, {String unit = ''}) {
  String formatted;
  
  if (number.abs() >= 1000000000) { // ตัวเลขใหญ่
    formatted = NumberFormat.compact().format(number);
  } else {
    formatted = NumberFormat.decimalPattern()
        .format(number)
        .replaceAll(',', ' ');
  }

  // ต่อหน่วยด้านหลัง ถ้า unit ไม่ว่าง
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
            children: <Widget>[
              Text(
                showPercent ? '$number%' : _formatNumber(number,'kW'),
                style: TextStyles.myriadProSemiBold24Dark,
              ),
              const SizedBox(width: 5),
              Icon(
                haveIncreased ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 20,
                color: haveIncreased ? Palette.green : Palette.red,
              ),
              Text(
                '$percent%',
                style: haveIncreased
                    ? TextStyles.myriadProSemiBold12Green
                    : TextStyles.myriadProSemiBold12Red,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(text, style: TextStyles.myriadProRegular16DarkGrey),
        ],
      ),
    );
  }
}
