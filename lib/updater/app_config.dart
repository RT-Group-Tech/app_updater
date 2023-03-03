import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AppConfig {
  static double currentVersion = 1.0;

  static Future<Map<String, dynamic>> loadJsonGithubAppInfos() async {
    final response = await http.read(Uri.parse(
        "https://raw.githubusercontent.com/RT-Group-Tech/app_updater/master/app_versions_check/versions.json"));
    return jsonDecode(response);
  }

  static Future downloadAndInstallNewVersion(callback) async {
    var updateInfo = await loadJsonGithubAppInfos();
    String appPath = updateInfo["file_name"];
    final fileName = appPath.split("/").last;

    /*app script path*/
    final scriptDir = File(Platform.script.toFilePath()).parent;

    /* temp downloaded save path */
    final downloadFileSavePath =
        '${(await getTemporaryDirectory()).path}/$fileName';
    double updateVersion = double.parse(updateInfo['app_version'].toString());
    if (currentVersion < updateVersion) {
      /*Dio creating instance*/
      final dio = Dio();
      /* Download process */
      await dio.download(
        "http://verify.edgeverifed.com/$fileName",
        downloadFileSavePath,
        onReceiveProgress: (count, total) {
          final progress = (count / total) * 100;
          callback(
              "downloading ${progress.toStringAsFixed(1)}%  ${scriptDir.path}");
        },
      );
      callback("downloading new version : $updateVersion");
      if (Platform.isWindows) {
        await unzipContentNewAppFile(downloadFileSavePath, scriptDir.path);
        return "Application updated new version : $updateVersion";
      }
    } else {
      return "app already updated version : $updateVersion";
    }
  }

  static Future<void> openExeFile(String path) async {
    await Process.start(path, ["-t", "-l", "1000"]).then((value) {});
  }

  static Future unzipContentNewAppFile(
      String filePath, String zipDestination) async {
    final bytes = File(filePath).readAsBytesSync();
    try {
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
    } catch (e) {
      print(e);
    }
    //final archive = ZipDecoder().decodeBytes(bytes);
  }
}
