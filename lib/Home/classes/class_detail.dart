import 'package:flutter/cupertino.dart';

class ClassDetailPage extends StatelessWidget {
  final int classIndex;
  
  const ClassDetailPage({super.key, required this.classIndex});
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: Row(
          children: [
            Hero(
              tag: 'class_$classIndex',
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFF0084FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(17.5),
                ),
                child: const Center(
                  child: Icon(CupertinoIcons.book_fill, color: Color(0xFF0084FF), size: 18),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Class $classIndex',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.video_camera_solid, color: Color(0xFF0084FF)),
              onPressed: () {},
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.phone, color: Color(0xFF0084FF)),
              onPressed: () {},
            ),
          ],
        ),
      ),
      child: Center(
        child: Text('Class $classIndex Details'),
      ),
    );
  }
}