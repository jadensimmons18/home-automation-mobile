import 'package:material_ui/material_ui.dart';

/// The tabs in the bottom navigation bar, in order.
enum AppTab { home, cameras, atlas, security, energy }

class NavState extends ChangeNotifier {
  AppTab tab = AppTab.home;

  void go(AppTab next) {
    if (tab == next) return;
    tab = next;
    notifyListeners();
  }
}
