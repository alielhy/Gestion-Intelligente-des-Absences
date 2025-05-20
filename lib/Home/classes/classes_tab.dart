import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/attendance_log.dart';
import '../scan/scan_tab.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

class ClassesTab extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ClassesTab({super.key, required this.cameras});

  @override
  State<ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<ClassesTab> {
  Future<void> handleImport() async {
    print("Import initiated.");
    try {
      if (!await _requestStoragePermission()) {
        showErrorDialog("Storage permission required to import files");
        return;
      }

      final typeGroup = XTypeGroup(label: 'documents', extensions: ['pdf']);
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) {
        print("User canceled the picker");
        return;
      }

      print("File selected: ${file.path}");
      final response = await _uploadPdf(file);
      print("Upload response status: ${response.statusCode}");

      if (response.statusCode == 201) {
        final List<String> names = List<String>.from(json.decode(response.body));
        Provider.of<AttendanceLog>(context, listen: false).setStudentList(names);
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (dialogContext) {
              print("Showing success dialog with context: $dialogContext");
              return CupertinoAlertDialog(
                title: const Text("Import Successful"),
                content: const Text("Student list imported. Navigate to Scan tab to start scanning."),
                actions: [
                  CupertinoDialogAction(
                    child: const Text("OK"),
                    onPressed: () {
                      print("Attempting to pop dialog with context: $dialogContext");
                      if (Navigator.canPop(dialogContext)) {
                        Navigator.pop(dialogContext);
                      } else {
                        print("Cannot pop dialog: Navigator stack is empty");
                      }
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        showErrorDialog("Failed to import PDF: ${response.body}");
      }
    } catch (e) {
      print("Error during import: $e");
      showErrorDialog("Failed to process the file. Please try another file.");
    }
  }

  Future<bool> _requestStoragePermission() async {
    try {
      if (await Permission.storage.isGranted) {
        return true;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  Future<http.Response> _uploadPdf(XFile file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://172.20.10.6:5000/upload-pdf'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['filiere'] = 'Your Filiere Here';
    return await request.send().then((response) => http.Response.fromStream(response));
  }

  void showErrorDialog(String message) {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (dialogContext) {
          print("Showing error dialog with context: $dialogContext");
          return CupertinoAlertDialog(
            title: const Text("Import Failed"),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () {
                  print("Attempting to pop error dialog with context: $dialogContext");
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.pop(dialogContext);
                  } else {
                    print("Cannot pop error dialog: Navigator stack is empty");
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentList = Provider.of<AttendanceLog>(context).studentList;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Classes'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: handleImport,
          child: const Icon(CupertinoIcons.add, color: Color(0xFF0084FF)),
        ),
      ),
      child: Center(
        child: studentList.isEmpty
            ? const Text(
                "No classes displayed.\nTap + to import a student list",
                textAlign: TextAlign.center,
                style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
              )
            : ListView.builder(
                itemCount: studentList.length,
                itemBuilder: (context, index) {
                  return CupertinoListTile(
                    title: Text(studentList[index]),
                  );
                },
              ),
      ),
    );
  }
}