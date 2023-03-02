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
        "https://raw.githubusercontent.com/RT-Group-Tech/app_updater/master/app_versions_check/versions.json"));
    return jsonDecode(response);
  }

  static Future downloadAndInstallNewVersion(String appPath) async {
    final fileName = appPath.split("/").last;

    /*app script path*/
    final scriptDir = File(Platform.script.toFilePath()).parent;

    /* temp downloaded save path */
    final downloadFileSavePath =
        '${(await getTemporaryDirectory()).path}/$fileName';

    /*Dio creating instance*/
    final dio = Dio();

    /* Download process */
    await dio.download(
      "https://github.com/RT-Group-Tech/app_updater/blob/master/app_versions_check/installers/windows/$fileName",
      downloadFileSavePath,
      onReceiveProgress: (count, total) {
        final progress = (count / total) * 100;
        print('progress:* ${progress.toStringAsFixed(1)}%');
      },
    );
    if (Platform.isWindows) {
      await unzipContentNewAppFile(
          downloadFileSavePath, '${scriptDir.path}/app_versions_check/');
    }
  }

  static Future<void> openExeFile(String path) async {
    await Process.start(path, ["-t", "-l", "1000"]).then((value) {});
  }

  static Future unzipContentNewAppFile(
      String filePath, String zipDestination) async {
    print(filePath);
    print(zipDestination);
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
