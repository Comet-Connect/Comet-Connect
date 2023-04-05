import 'package:flutter/services.dart';
import 'dart:convert';

const configFileName = 'config/config.json';

Future<Map> getConfigFile() async {
  String jsonString = await rootBundle.loadString(configFileName);
  return jsonDecode(jsonString);
}

Future<Map> getServerConfigFile() async {
  Map fullConfig = await getConfigFile();
  return fullConfig["server"];
}

Future<Map> getDatabaseConfigFile() async {
  Map fullConfig = await getConfigFile();
  return fullConfig["database"];
}
