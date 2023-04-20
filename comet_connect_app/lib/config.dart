import 'package:flutter/services.dart';
import 'dart:convert';

// Config file location
const configFileName = 'config/config.json';

// Getting the config file
Future<Map> getConfigFile() async {
  String jsonString = await rootBundle.loadString(configFileName);
  Map checkedConfig = setServerConnectionString(jsonDecode(jsonString));
  return checkedConfig;
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

//
Map setServerConnectionString(Map config) {
  if (config['isServer']) {
    config['server']['uri'] = 'wss://${config['server']['host']}/ws';
  } else {
    config['server']['uri'] =
        'ws://${config['server']['host']}:${config['server']['port']}';
  }
  return config;
}
