import 'package:permission_handler/permission_handler.dart';

Future<void> requestFilePermission() async {
  final status = await Permission.manageExternalStorage.status;
  if (status != PermissionStatus.granted) {
    await Permission.storage.request();
  }
}
