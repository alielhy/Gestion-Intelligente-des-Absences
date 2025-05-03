import 'package:flutter/cupertino.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      child: ListView(
        children: [
          Container(
            color: CupertinoColors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0084FF).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      size: 50,
                      color: Color(0xFF0084FF),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Teacher Name',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'math@school.edu',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.pencil),
                      SizedBox(width: 8),
                      Text('Edit Profile'),
                    ],
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildProfileSection(
            [
              _buildProfileTile(
                icon: CupertinoIcons.bell_fill,
                iconColor: const Color(0xFF0084FF),
                title: 'Notifications',
                showBadge: true,
              ),
              _buildProfileTile(
                icon: CupertinoIcons.lock_fill,
                iconColor: const Color(0xFF0084FF),
                title: 'Privacy',
              ),
              _buildProfileTile(
                icon: CupertinoIcons.chat_bubble_fill,
                iconColor: const Color(0xFF0084FF),
                title: 'Chats',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileSection(
            [
              _buildProfileTile(
                icon: CupertinoIcons.info_circle_fill,
                iconColor: const Color(0xFF0084FF),
                title: 'About',
              ),
              _buildProfileTile(
                icon: CupertinoIcons.question_circle_fill,
                iconColor: const Color(0xFF0084FF),
                title: 'Help',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileSection(
            [
              _buildProfileTile(
                icon: CupertinoIcons.power,
                iconColor: CupertinoColors.systemRed,
                title: 'Log Out',
                showChevron: false,
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Attendance App v1.0',
              style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    bool showChevron = true,
    bool showBadge = false,
  }) {
    return CupertinoListTile(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBadge)
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
          if (showChevron) const SizedBox(width: 8),
          if (showChevron)
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey3,
            ),
        ],
      ),
    );
  }
}