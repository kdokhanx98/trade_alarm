import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class TradeHttpService {
  final String apiKEY = '00f887c2d6864b193deb9d4e19153150';

  Future<List<String>> getCodes() async {
    List<String> codeList = [];
    try {
      var response = await http.get(Uri.parse(
          'https://financialmodelingprep.com/api/v3/financial-statement-symbol-lists?apikey=$apiKEY'));
      if (response.statusCode == 200) {
        var res = (jsonDecode(response.body) as List<dynamic>).cast<String>();
        log('res is $res');
        codeList = res;

        return codeList;
      } else {
        log('failed to get coded ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      log('error getting codes => ${e.toString()}');
    }
    return codeList;
  }

  Future<double?> getCodeLivePrice(String code) async {
    if (code == '') return null;
    double? codePrice;
    try {
      var response = await http.get(Uri.parse(
          'https://financialmodelingprep.com/api/v3/quote-short/$code?apikey=$apiKEY'));
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body) as List<dynamic>;
        log('res is $res');
        codePrice = res[0]['price'].toDouble();

        return codePrice;
      } else {
        log('failed to get code price ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      log('error getting code price => ${e.toString()}');
    }
    return codePrice;
  }
}
