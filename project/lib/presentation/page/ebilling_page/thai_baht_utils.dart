class ThaiBahtUtils {
  static const _thaiNum = ["ศูนย์", "หนึ่ง", "สอง", "สาม", "สี่", "ห้า", "หก", "เจ็ด", "แปด", "เก้า"];
  static const _place = ["", "สิบ", "ร้อย", "พัน", "หมื่น", "แสน", "ล้าน"];

  static String convert(String amountStr) {
    String cleanAmount = amountStr.replaceAll(',', '');
    double? amount = double.tryParse(cleanAmount);

    if (amount == null) return "";
    if (amount == 0) return "ศูนย์บาทถ้วน";
    
    if (amount < 0) return "ลบ${convert(amount.abs().toString())}";

    String numberStr = amount.toStringAsFixed(2);
    List<String> parts = numberStr.split('.');
    
    String bahtPart = _convertInteger(parts[0]);
    String satangPart = _convertInteger(parts[1]);

    String result = "";
    if (bahtPart.isNotEmpty) {
      result += "$bahtPartบาท";
    }
    
    if (parts[1] == "00" || satangPart.isEmpty || satangPart == "ศูนย์") {
      result += "ถ้วน";
    } else {
      result += "$satangPartสตางค์";
    }

    return result;
  }

  static String _convertInteger(String numberStr) {
    String result = "";
    int length = numberStr.length;
    
    for (int i = 0; i < length; i++) {
      String char = numberStr[i];
      int digit = int.parse(char);
      int pos = length - i - 1; 
      
      if (digit != 0) {
        int placeIndex = pos % 6; 
        
        if (placeIndex == 0 && digit == 1 && length > 1) {
           result += "เอ็ด";
        }
        else if (placeIndex == 1 && digit == 2) {
           result += "ยี่";
        }
        else if (placeIndex == 1 && digit == 1) {
        }
        else {
           result += _thaiNum[digit];
        }

        result += _place[placeIndex];
      }

      if (pos % 6 == 0 && pos > 0) {
        result += "ล้าน";
      }
    }
    
    if (result.isEmpty && numberStr == "0") return "ศูนย์";
    return result;
  }
}