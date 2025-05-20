import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../utils/attendance_log.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  // Filter states
  String _searchQuery = '';
  DateTime? _selectedDate;
  bool _showManualOnly = false;
  String _statusFilter = 'all'; // 'all', 'present', 'absent', 'unknown'

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceLog>(
      builder: (context, attendanceLog, child) {
        final displayList = _getDisplayList(attendanceLog);
        
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.white,
          navigationBar: _buildNavigationBar(),
          child: SafeArea(
            child: Column(
              children: [
                _buildFilterControls(),
                _buildSummaryCards(attendanceLog),
                _buildAttendanceList(displayList, attendanceLog),
              ],
            ),
          ),
        );
      },
    );
  }

  // Navigation bar with actions
  CupertinoNavigationBar _buildNavigationBar() {
    return const CupertinoNavigationBar(
      backgroundColor: CupertinoColors.white,
      middle: Text('Attendance Reports'),
      trailing: _AppBarActions(),
    );
  }

  // Filter controls section
  Widget _buildFilterControls() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.padding),
      child: Column(
        children: [
          CupertinoSearchTextField(
            placeholder: "Search students...",
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: AppDimensions.spacing),
          _buildDateAndManualFilterRow(),
          const SizedBox(height: AppDimensions.spacing),
          _buildStatusFilterButtons(),
        ],
      ),
    );
  }

  Widget _buildDateAndManualFilterRow() {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.buttonColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.calendar, size: 18),
                const SizedBox(width: 4),
                Text(
                  _selectedDate == null
                      ? "All dates"
                      : DateFormat('MMM d, y').format(_selectedDate!),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            onPressed: () => _selectDate(context),
          ),
        ),
        const SizedBox(width: AppDimensions.spacing),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: _showManualOnly ? AppColors.activeButtonColor : AppColors.buttonColor,
          child: const Text("Manual", style: TextStyle(fontSize: 14)),
          onPressed: () => setState(() => _showManualOnly = !_showManualOnly),
        ),
      ],
    );
  }

  Widget _buildStatusFilterButtons() {
    return Row(
      children: [
        _buildFilterButton("Present", 'present'),
        const SizedBox(width: AppDimensions.spacing),
        _buildFilterButton("Absent", 'absent'),
        const SizedBox(width: AppDimensions.spacing),
        _buildFilterButton("Unknown", 'unknown'),
        const SizedBox(width: AppDimensions.spacing),
        _buildFilterButton("All", 'all'),
      ],
    );
  }

  Widget _buildFilterButton(String label, String filter) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 2), // Add small margin
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: _statusFilter == filter 
            ? AppColors.activeButtonColor 
            : AppColors.buttonColor,
        borderRadius: BorderRadius.circular(8), // Add rounded corners
        pressedOpacity: 0.7, // Reduce press effect intensity
        child: Text(
          label, 
          style: TextStyle(
            fontSize: 14,
            color: _statusFilter == filter 
                ? CupertinoColors.white 
                : CupertinoColors.black,
          ),
        ),
        onPressed: () => setState(() => _statusFilter = filter),
      ),
    ),
  );
}

  // Summary statistics cards
  Widget _buildSummaryCards(AttendanceLog attendanceLog) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.padding),
      child: Row(
        children: [
          _SummaryCard("Present", attendanceLog.presentStudents.length, AppColors.presentColor),
          const SizedBox(width: AppDimensions.spacing),
          _SummaryCard("Absent", attendanceLog.absentStudents.length, AppColors.absentColor),
          const SizedBox(width: AppDimensions.spacing),
          _SummaryCard("Unknown", attendanceLog.unknownCount, AppColors.unknownColor),
        ],
      ),
    );
  }

  // Attendance records list
  Widget _buildAttendanceList(List<AttendanceRecord> displayList, AttendanceLog attendanceLog) {
    return Expanded(
      child: displayList.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final record = displayList[index];
                return _AttendanceRecordTile(record, attendanceLog);
              },
            ),
    );
  }

  // Date picker
  Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
  );
  if (picked != null) {
    setState(() {
      // If same date is selected again, clear the filter
      _selectedDate = _selectedDate != null && 
          _selectedDate!.year == picked.year &&
          _selectedDate!.month == picked.month &&
          _selectedDate!.day == picked.day
          ? null
          : picked;
    });
  }
}

  // Data processing
  List<AttendanceRecord> _getDisplayList(AttendanceLog attendanceLog) {
  final filteredRecords = attendanceLog.filterRecords(
    nameFilter: _searchQuery,
    dateFilter: _selectedDate,
    showManualEntries: _showManualOnly ? true : null,
    showUnknownOnly: _statusFilter == 'unknown',
  );

  final recordsMap = {
    for (var r in filteredRecords.where((r) => r.name.toLowerCase() != 'unknown')) 
      r.name: r
  };

  switch (_statusFilter) {
    case 'present':
      return attendanceLog.presentStudents
          .where((name) => _searchQuery.isEmpty || 
              name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .map((name) => recordsMap[name] ?? 
              AttendanceRecord(name: name, timestamp: _selectedDate ?? DateTime.now()))
          .toList();
    case 'absent':
      return attendanceLog.absentStudents
          .where((name) => _searchQuery.isEmpty || 
              name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .map((name) => AttendanceRecord(
                name: name, 
                timestamp: _selectedDate ?? DateTime.now(), 
                isAbsent: true))
          .toList();
    case 'unknown':
  return filteredRecords
      .where((r) => r.name.toLowerCase() == 'unknown')
      .map((r) => AttendanceRecord(
            name: r.name,
            timestamp: r.timestamp,
            isAbsent: false, // Explicitly set isAbsent to false for unknown
          ))
      .toList();
    case 'all':
    default:
      return attendanceLog.studentList
          .where((name) => _searchQuery.isEmpty || 
              name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .map((name) {
            final isAbsent = attendanceLog.absentStudents.contains(name);
            final record = recordsMap[name];
            return isAbsent || record == null
                ? AttendanceRecord(
                    name: name, 
                    timestamp: _selectedDate ?? DateTime.now(), 
                    isAbsent: true)
                : record;
          }).toList();
  }
}

 List<AttendanceRecord> _buildExportRecords(AttendanceLog attendanceLog) {
  final filteredRecords = attendanceLog.filterRecords(
    nameFilter: _searchQuery,
    dateFilter: _selectedDate,
    showManualEntries: _showManualOnly ? true : null,
    showUnknownOnly: _statusFilter == 'unknown',
  );

  // For export, include all students with their status
  final recordsMap = {
    for (var r in filteredRecords) r.name: r
  };

  return attendanceLog.studentList.map((name) {
    // Handle unknown records separately
    if (name.toLowerCase() == 'unknown') {
      return filteredRecords.firstWhere(
        (r) => r.name.toLowerCase() == 'unknown',
        orElse: () => AttendanceRecord(
          name: 'Unknown',
          timestamp: _selectedDate ?? DateTime.now(),
          isAbsent: false,
        ),
      );
    }
    
    final isAbsent = attendanceLog.absentStudents.contains(name);
    final record = recordsMap[name];
    
    return isAbsent || record == null
        ? AttendanceRecord(
            name: name,
            timestamp: _selectedDate ?? DateTime.now(),
            isAbsent: isAbsent,
          )
        : record;
  }).toList();
}
}

// App bar actions widget
class _AppBarActions extends StatelessWidget {
  const _AppBarActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.share, color: AppColors.primaryAction),
          onPressed: () => _showExportOptions(context),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add, color: AppColors.primaryAction),
          onPressed: () => _showAddManualDialog(context),
        ),
      ],
    );
  }

  void _showExportOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Export Options"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
  debugPrint("[UI] Export CSV button pressed");
  final attendanceLog = Provider.of<AttendanceLog>(context, listen: false);
  final state = context.findAncestorStateOfType<_ReportsTabState>();
  
  if (state == null) {
    debugPrint("[ERROR] Could not find state");
    return;
  }

  await AttendanceExporter.exportAsCSV(
    context,
    searchQuery: state._searchQuery,
    selectedDate: state._selectedDate,
    showManualOnly: state._showManualOnly,
    statusFilter: state._statusFilter,
    attendanceLog: attendanceLog,
  );
},
            child: const Text("Export as CSV"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showAddManualDialog(BuildContext context) {
    String name = '';
    final studentList = Provider.of<AttendanceLog>(context, listen: false).studentList;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Add Manual Entry"),
        content: CupertinoTextField(
          placeholder: "Student name",
          onChanged: (value) => name = value,
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text("Add"),
            onPressed: () => _handleManualEntry(context, name, studentList),
          ),
        ],
      ),
    );
  }

  void _handleManualEntry(BuildContext context, String name, List<String> studentList) {
    if (name.isNotEmpty && studentList.contains(name)) {
      Provider.of<AttendanceLog>(context, listen: false).addManualEntry(name);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      _showInvalidNameDialog(context);
    }
  }

  void _showInvalidNameDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => const _InvalidNameDialog(),
    );
  }
}

// Summary card widget
class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SummaryCard(this.title, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.padding),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
            ),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// Attendance record tile widget
class _AttendanceRecordTile extends StatelessWidget {
  final AttendanceRecord record;
  final AttendanceLog attendanceLog;

  const _AttendanceRecordTile(this.record, this.attendanceLog);

  @override
  Widget build(BuildContext context) {
    final isAbsent = record.isAbsent || attendanceLog.absentStudents.contains(record.name);
    final status = _RecordStatus.fromRecord(record, isAbsent);

    return CupertinoListTile(
      title: Text(record.name),
      subtitle: Text(
        isAbsent ? "Not detected" : DateFormat('MMM d, y • h:mm a').format(record.timestamp),
      ),
      leading: _RecordIcon(record, isAbsent),
      trailing: Text(
        status.label,
        style: TextStyle(color: status.color),
      ),
    );
  }
}

// Record icon widget
class _RecordIcon extends StatelessWidget {
  final AttendanceRecord record;
  final bool isAbsent;

  const _RecordIcon(this.record, this.isAbsent);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getIcon(),
        size: 18,
        color: _getIconColor(),
      ),
    );
  }

  IconData _getIcon() {
    if (record.name.toLowerCase() == 'unknown') return CupertinoIcons.question;
    if (record.isManualEntry) return CupertinoIcons.pencil;
    if (isAbsent) return CupertinoIcons.xmark;
    return CupertinoIcons.checkmark;
  }

  Color _getIconColor() {
    if (record.name.toLowerCase() == 'unknown') return AppColors.unknownColor;
    if (record.isManualEntry) return AppColors.manualColor;
    if (isAbsent) return AppColors.absentColor;
    return AppColors.presentColor;
  }

  Color _getBackgroundColor() {
    if (record.name.toLowerCase() == 'unknown') return AppColors.unknownColor.withOpacity(0.1);
    if (record.isManualEntry) return AppColors.manualColor.withOpacity(0.1);
    if (isAbsent) return AppColors.absentColor.withOpacity(0.1);
    return AppColors.presentColor.withOpacity(0.1);
  }
}

// Empty state widget
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "No matching records found",
        style: TextStyle(color: CupertinoColors.systemGrey),
      ),
    );
  }
}

// Invalid name dialog widget
class _InvalidNameDialog extends StatelessWidget {
  const _InvalidNameDialog();

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text("Invalid Name"),
      content: const Text("Please enter a name from the imported student list."),
      actions: [
        CupertinoDialogAction(
          child: const Text("OK"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

// Record status helper class
class _RecordStatus {
  final String label;
  final Color color;

  const _RecordStatus(this.label, this.color);

 // In _RecordStatus class:
factory _RecordStatus.fromRecord(AttendanceRecord record, bool isAbsent) {
  if (record.name.toLowerCase() == 'unknown') {
    return _RecordStatus('Unknown', AppColors.unknownColor);
  } else if (record.isManualEntry) {
    return _RecordStatus('Manual', AppColors.manualColor);
  } else if (isAbsent) {
    return _RecordStatus('Absent', AppColors.absentColor);
  }
  return _RecordStatus('Present', AppColors.presentColor);
}
}

// App dimensions constants
class AppDimensions {
  static const double padding = 12.0;
  static const double spacing = 8.0;
}

// App colors constants
class AppColors {
  static const Color buttonColor = CupertinoColors.systemGrey5;
  static const Color activeButtonColor = CupertinoColors.activeBlue;
  static const Color shadowColor = CupertinoColors.systemGrey5;
  static const Color presentColor = CupertinoColors.activeGreen;
  static const Color absentColor = CupertinoColors.systemRed;
  static const Color unknownColor = CupertinoColors.systemGrey;
  static const Color manualColor = CupertinoColors.activeOrange;
  static const Color primaryAction = Color(0xFF0084FF);
}

// Attendance exporter class
class AttendanceExporter {

  static Future<bool> _checkAndRequestStoragePermission(BuildContext context) async {
  if (Platform.isAndroid) {
    debugPrint("[PERMISSION] Checking storage permissions");
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      debugPrint("[PERMISSION] Requesting storage permission");
      final result = await Permission.storage.request();
      if (!result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission required for exports")),
        );
        return false;
      }
    }
  }
  return true;
}
  static Future<void> exportAsCSV(BuildContext context, {
  required String searchQuery,
  required DateTime? selectedDate,
  required bool showManualOnly,
  required String statusFilter,
  required AttendanceLog attendanceLog,
}) async {
    debugPrint("[EXPORT] Starting CSV export process");
    try {
      // Declare and assign attendanceLog here
      final attendanceLog = Provider.of<AttendanceLog>(context, listen: false);
      debugPrint("[EXPORT] Found ${attendanceLog.records.length} records");

      // Build export data using the passed parameters
      final records = attendanceLog.filterRecords(
        nameFilter: searchQuery,
        dateFilter: selectedDate,
        showManualEntries: showManualOnly ? true : null,
        showUnknownOnly: statusFilter == 'unknown',
      );

      debugPrint("[EXPORT] Prepared ${records.length} records for export");

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CupertinoAlertDialog(
          title: Text("Exporting CSV"),
          content: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(),
                SizedBox(height: 16),
                Text("Preparing export..."),
              ],
            ),
          ),
        ),
      );

      // Generate CSV content
      final csvData = [
        ['Name', 'Status', 'Timestamp'],
        ...records.map((record) => [
              record.name,
              _getStatusLabel(record),
              record.isAbsent ? '' : DateFormat('yyyy-MM-dd HH:mm').format(record.timestamp),
            ]),
      ];
      debugPrint("[EXPORT] Generated CSV data");

      // Convert to CSV string
      final csv = const ListToCsvConverter().convert(csvData);
      debugPrint("[EXPORT] Converted to CSV string");

      // Get storage directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/attendance_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      debugPrint("[EXPORT] Will save to: $filePath");

      // Write file
      final file = File(filePath);
      await file.writeAsString(csv);
      debugPrint("[EXPORT] File saved successfully");

      // Verify file exists
      if (await file.exists()) {
        debugPrint("[EXPORT] File exists at path: ${file.path}");
        debugPrint("[EXPORT] File size: ${(await file.length())} bytes");
      } else {
        debugPrint("[EXPORT ERROR] File not created at path: ${file.path}");
        throw Exception("File was not created");
      }

      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success dialog with file path
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Export Successful"),
          content: SingleChildScrollView(
            child: Text("CSV file saved to:\n\n${file.path}"),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Share"),
              onPressed: () async {
                Navigator.pop(context);
                await Share.shareXFiles([XFile(file.path)]);
              },
            ),
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

    } catch (e, stackTrace) {
      debugPrint("[EXPORT ERROR] Exception during CSV export: $e");
      debugPrint("[EXPORT ERROR] Stack trace: $stackTrace");
      Navigator.of(context).pop(); // Close loading dialog if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  static String _getStatusLabel(AttendanceRecord record) {
    if (record.isManualEntry) return 'Manual';
    if (record.isAbsent) return 'Absent';
    return 'Present';
  }
}