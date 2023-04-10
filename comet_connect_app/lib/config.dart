import 'package:flutter/services.dart';
import 'dart:convert';

// Config file location
const configFileName = 'config/config.json';

// Getting the config file
Future<Map> getConfigFile() async {
  String jsonString = await rootBundle.loadString(configFileName);
  return jsonDecode(jsonString);
}

// Getting Server configuration
Future<Map> getServerConfigFile() async {
  Map fullConfig = await getConfigFile();
  return fullConfig["server"];
}

// Getting Database configuration
Future<Map> getDatabaseConfigFile() async {
  Map fullConfig = await getConfigFile();
  return fullConfig["database"];
}
