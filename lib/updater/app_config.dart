import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AppConfig {
  static double? currentVersion = 1.2;

  static Future<Map<String, dynamic>> loadJsonGithubAppInfos() async {
    final response = await http.read(Uri.parse(
        "https://raw.githubusercontent.com/RT-Group-Tech/app_updater/master/app_versions_check/versions.json?token=GHSAT0AAAAAAB6SM3LXXICBCS26BUGAJPEMZAA3M5Q"));
    return jsonDecode(response);
  }

  static Future downloadAndInstallNewVersion(String appPath) async {
    final fileName = appPath.split("/").last;
    String downloadFilePath =
        "${(await getApplicationDocumentsDirectory()).path}/$fileName";

    final dio = Dio();

    await dio.download(
      "https://github.com/RT-Group-Tech/app_updater/blob/master/app_versions_check/$appPath",
      downloadFilePath,
      onReceiveProgress: (count, total) {
        final progress = (count / total) * 100;
        print('progress:* $progress%');
      },
    );
    if (Platform.isWindows) {
      await openExeFile(downloadFilePath);
    }
  }

  static Future<void> openExeFile(String path) async {
    await Process.start(path, ["-t", "-l", "1000"]).then((value) {});
  }

  static Future unzipContentNewAppFile(
      String filePath, String zipDestination) async {
    final bytes = File(filePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        /* extract file */
        final data = file.content as List<int>;
        File('$zipDestination/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        /* extract folder */
        Directory('$zipDestination/$filename').create(recursive: true);
      }
    }
  }
}
