enum BottomItem {
  home,
  appointment,
  encounter,
  payout,
  settings,
  profile,
}

class BottomBarItem {
  final String title;
  final String icon;
  final String activeIcon;
  final String type;

  BottomBarItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.type,
  });
}
