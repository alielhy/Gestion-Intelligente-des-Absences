import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'class_detail.dart';

class ClassesTab extends StatelessWidget {
  const ClassesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: const Text('Classes', style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.search, color: Color(0xFF0084FF)),
              onPressed: () {},
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.ellipsis, color: Color(0xFF0084FF)),
              onPressed: () {},
            ),
          ],
        ),
      ),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Hero(
            tag: 'class_${index + 1}',
            child: Material(
              color: Colors.transparent,
              child: CupertinoListTile(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0084FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Icon(CupertinoIcons.book_fill, color: Color(0xFF0084FF)),
                  ),
                ),
                title: Text(
                  'Class ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Last attendance: ${index % 2 == 0 ? 'All present' : '2 absent'}',
                  style: const TextStyle(color: CupertinoColors.systemGrey),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${9 + index}:00 AM',
                      style: const TextStyle(
                        color: Color(0xFF0084FF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (index % 2 == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0084FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(color: CupertinoColors.white, fontSize: 11),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  // Animation when tapping on a class
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => ClassDetailPage(classIndex: index + 1),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}