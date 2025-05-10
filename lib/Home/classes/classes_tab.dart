import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:camera/camera.dart';
import '../scan/scan_tab.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_selector/file_selector.dart';

class ClassesTab extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ClassesTab({super.key, required this.cameras});

  @override
  State<ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<ClassesTab> {
  Future<List<String>?> importStudentListFromFile() async {
    try {
      print('Requesting storage permission...');
      if (!await _requestStoragePermission()) {
        print('Permission denied');
        showErrorDialog("Storage permission required to import files");
        return null;
      }

      print('Opening file picker...');
      final typeGroup = XTypeGroup(
        label: 'documents',
        extensions: ['pdf', 'csv'],
      );

      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) {
        print('User cancelled file picker');
        return null;
      }
      print('File picked: ${file.name}');

      final extension = file.name.split('.').last.toLowerCase();

      if (extension == 'csv') {
        final content = await file.readAsString();
        final rows = const CsvToListConverter().convert(content);
        return rows
            .where((row) => row.isNotEmpty && row[0].toString().trim().isNotEmpty)
            .map((row) => row[0].toString().trim())
            .toList();
      } else if (extension == 'pdf') {
        return await extractTextFromPdf(file);
      } else {
        print('Unsupported file type: $extension');
        showErrorDialog("Unsupported file type. Please select a PDF or CSV file.");
        return null;
      }
    } catch (e, stack) {
      debugPrint('Import error: $e');
      debugPrint('Stack trace: $stack');
      showErrorDialog("Failed to process the file. Please try another file.");
      return null;
    }
  }

  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        if (await Permission.storage.isGranted) return true;
        if (await Permission.photos.isGranted) return true;
        if (await Permission.videos.isGranted) return true;
        if (await Permission.audio.isGranted) return true;

        // Request all at once
        final statuses = await [
          Permission.storage,
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();

        return statuses.values.any((status) => status.isGranted);
      } else if (Platform.isIOS) {
        // iOS only needs permission for photos
        return true;
      }
      return true;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  void handleImportAndScan() async {
    try {
      final importedStudents = await importStudentListFromFile();
      
      if (!mounted) return;

      // No file was selected (user cancelled)
      if (importedStudents == null) {
        return;
      }
      // File was selected but empty/invalid
      else if (importedStudents.isEmpty) {
        showErrorDialog("The selected file contains no valid student names.\n\n"
            "For CSV: Ensure names are in the first column\n"
            "For PDF: Ensure one name per line");
        return;
      }

      // Success - proceed to scan
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => ScanTab(
            cameras: widget.cameras,
            studentList: importedStudents,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showErrorDialog("Failed to process the file. Please try another file.");
    }
  }

  void showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Import Failed"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> pickAndReadFile() async {
    // Allow only PDF and CSV files
    final typeGroup = XTypeGroup(
      label: 'documents',
      extensions: ['pdf', 'csv'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) {
      // User canceled the picker
      return;
    }

    // For CSV: read as string
    if (file.name.endsWith('.csv')) {
      final content = await file.readAsString();
      print('CSV content: $content');
      // Parse CSV as needed
    } else if (file.name.endsWith('.pdf')) {
      final bytes = await file.readAsBytes();
      print('PDF file picked, size: ${bytes.length}');
      // Use your PDF parsing logic here
    }
  }

  Future<List<String>> extractTextFromPdf(XFile file) async {
    final bytes = await file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final String text = PdfTextExtractor(document).extractText();
    document.dispose();
    // Split by lines and trim
    return text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Classes'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: handleImportAndScan,
          child: const Icon(CupertinoIcons.add, color: Color(0xFF0084FF)),
        ),
      ),
      child: const Center(
        child: Text(
          "No classes displayed.\nTap + to import a student list",
          textAlign: TextAlign.center,
          style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
        ),
      ),
    );
  }
}