import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> copyFileToAppDir(String? sourceFilePath) async {
  if (sourceFilePath == null) return null;

  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;

  File sourceFile = File(sourceFilePath);
  String fileName = sourceFile.uri.pathSegments.last;
  File destFile = File('$appDocPath/$fileName');

  if (await sourceFile.exists()) {
    await sourceFile.copy(destFile.path);
    print('文件已复制到: ${destFile.path}');
    return destFile.path;
  } else {
    print('源文件不存在');
    return null;
  }
}
