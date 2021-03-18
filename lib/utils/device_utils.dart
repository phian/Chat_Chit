import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

class DeviceUtils {
  static Future<String> getDeviceId() async {
    String deviceId = "";
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var device;

    try {
      if (Platform.isAndroid) {
        device = await deviceInfoPlugin.androidInfo;
        deviceId = device.id.toString();
      } else {
        device = await deviceInfoPlugin.iosInfo;
        deviceId = device.identifierForVendor;
      }
    } catch(ex) {
      debugPrint("Get platform failed");
    }

    return deviceId;
  }
}