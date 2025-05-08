import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:absent_detector/Home/scan/scan_tab.dart';
import 'package:camera/camera.dart';

class ClassesTab extends StatefulWidget {
  final List<CameraDescription> cameras; // Required for camera integration

  const ClassesTab({super.key, required this.cameras});

  @override
  State<ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<ClassesTab> {
  // Replace this with your real backend logic
  Future<List<String>> importStudentListFromBackend() async {
    // TODO: Call your backend API to fetch list of student names
    // Simulating empty list for now until backend is ready
    return [];
  }

  void handleImportAndScan() async {
    final importedStudents = await importStudentListFromBackend();

    if (!mounted) return;

    if (importedStudents.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Import Failed"),
          content: const Text("No students found. Make sure your list is uploaded to the server."),
          actions: [
            CupertinoDialogAction(child: const Text("OK"), onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
      return;
    }

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ScanTab(
          cameras: widget.cameras,
          studentList: importedStudents,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: const Text('Classes', style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.doc_on_clipboard_fill, color: Color(0xFF0084FF)),
          onPressed: handleImportAndScan,
        ),
      ),
      child: const Center(
        child: Text(
          "No classes displayed.\nUse the import button to begin scanning.",
          textAlign: TextAlign.center,
          style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
        ),
      ),
    );
  }
}
