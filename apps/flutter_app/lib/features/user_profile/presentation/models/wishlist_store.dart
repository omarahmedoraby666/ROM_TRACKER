import 'package:flutter/foundation.dart';

class WishlistStore {
  static final ValueNotifier<Set<String>> favorites =
      ValueNotifier<Set<String>>(<String>{});

  static bool isFavorite(String doctorName) {
    return favorites.value.contains(doctorName);
  }

  static void toggle(String doctorName) {
    final next = <String>{...favorites.value};
    if (!next.add(doctorName)) {
      next.remove(doctorName);
    }
    favorites.value = next;
  }
}
