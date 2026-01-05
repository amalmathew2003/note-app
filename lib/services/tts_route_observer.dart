import 'package:flutter/material.dart';
import 'tts_manager.dart';

class TtsRouteObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    TtsManager().stop(); // 🔥 STOP BEFORE SCREEN CHANGES
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    TtsManager().stop();
    super.didPush(route, previousRoute);
  }
}
