import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> storagePermission() async {
  final DeviceInfoPlugin info =
  DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await info.androidInfo;
  final int androidVersion = int.parse(androidInfo.version.release);
  bool havePermission = false;

  if (androidVersion >= 13) {
    final request = await [
      Permission.videos,
      Permission.photos,
    ].request();

    havePermission =
        request.values.every((status) => status == PermissionStatus.granted);
  } else {
    final status = await Permission.storage.request();
    havePermission = status.isGranted;
  }
  if (!havePermission) {
    await openAppSettings();
  }
  return havePermission;
}

void downloadImage(BuildContext context, String url) async {
  final permission = await storagePermission();
  if(permission == true){
    http.Response response = await http.get(
      Uri.parse(url),
    );
    try {
      await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.bodyBytes),
        quality: 100,
        name: (DateTime.now().millisecondsSinceEpoch.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("이미지가 저장되었습니다."),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("이미지를 저장하지 못했습니다."),
      ));
    }
  }
}

void downloadImage_imageBytes(BuildContext context, Uint8List imageBytes) async {
  final permission = await storagePermission();
  if (permission == true) {
    try {
      await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: (DateTime.now().millisecondsSinceEpoch.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("이미지가 저장되었습니다."),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("이미지를 저장하지 못했습니다."),
      ));
    }
  }
}
