import 'package:flutter/services.dart';
import 'dart:convert';

const configFileName = 'config/config.json';

Future<Map> getConfigFile() async {
  String jsonString = await rootBundle.loadString(configFileName);
  return jsonDecode(jsonString);
}
