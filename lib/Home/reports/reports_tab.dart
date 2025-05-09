import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../utils/attendance_log.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  String _searchQuery = '';
  DateTime? _selectedDate;
  bool _showManualOnly = false;
  bool _showUnknownOnly = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showAddManualDialog() {
    String name = '';
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
            onPressed: () {
              if (name.isNotEmpty) {
                Provider.of<AttendanceLog>(context, listen: false)
                    .addManualEntry(name);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Export Options"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AttendanceLog>(context, listen: false)
                  .exportRecords();
            },
            child: const Text("Export as CSV"),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Implement PDF export
            },
            child: const Text("Export as PDF"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceLog = Provider.of<AttendanceLog>(context);
    final filteredRecords = attendanceLog.filterRecords(
      nameFilter: _searchQuery,
      dateFilter: _selectedDate,
      showManualEntries: _showManualOnly ? true : null,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: const Text('Attendance Reports'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.share, color: Color(0xFF0084FF)),
              onPressed: _showExportOptions,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add, color: Color(0xFF0084FF)),
              onPressed: _showAddManualDialog,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  CupertinoSearchTextField(
                    placeholder: "Search students...",
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: CupertinoColors.systemGrey5,
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
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: _showManualOnly 
                            ? CupertinoColors.activeBlue 
                            : CupertinoColors.systemGrey5,
                        child: const Text("Manual", style: TextStyle(fontSize: 14)),
                        onPressed: () => setState(() => _showManualOnly = !_showManualOnly),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: _showUnknownOnly 
                            ? CupertinoColors.activeBlue 
                            : CupertinoColors.systemGrey5,
                        child: const Text("Unknown", style: TextStyle(fontSize: 14)),
                        onPressed: () => setState(() => _showUnknownOnly = !_showUnknownOnly),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Summary cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildSummaryCard(
                    "Present",
                    attendanceLog.recognizedStudents.length,
                    CupertinoColors.activeGreen,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    "Unknown",
                    attendanceLog.unknownCount,
                    CupertinoColors.systemGrey,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    "Total",
                    attendanceLog.records.length,
                    CupertinoColors.activeBlue,
                  ),
                ],
              ),
            ),

            // Attendance records list
            Expanded(
              child: filteredRecords.isEmpty
                  ? const Center(
                      child: Text(
                        "No matching records found",
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        return CupertinoListTile(
                          title: Text(record.name),
                          subtitle: Text(
                            DateFormat('MMM d, y • h:mm a').format(record.timestamp),
                          ),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: record.name.toLowerCase() == 'unknown'
                                  ? CupertinoColors.systemGrey.withOpacity(0.1)
                                  : record.isManualEntry
                                      ? CupertinoColors.activeOrange.withOpacity(0.1)
                                      : const Color(0xFF0084FF).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              record.name.toLowerCase() == 'unknown'
                                  ? CupertinoIcons.question
                                  : record.isManualEntry
                                      ? CupertinoIcons.pencil
                                      : CupertinoIcons.person_fill,
                              size: 18,
                              color: record.name.toLowerCase() == 'unknown'
                                  ? CupertinoColors.systemGrey
                                  : record.isManualEntry
                                      ? CupertinoColors.activeOrange
                                      : const Color(0xFF0084FF),
                            ),
                          ),
                          trailing: Text(
                            record.isManualEntry ? "Manual" : "Detected",
                            style: TextStyle(
                              color: record.isManualEntry
                                  ? CupertinoColors.activeOrange
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey5.withOpacity(0.3),
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
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}