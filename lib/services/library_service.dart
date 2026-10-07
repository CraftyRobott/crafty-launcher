import 'package:shared_preferences/shared_preferences.dart';

class LibraryService {
  static const String _romFolderKey = 'rom_folder';
  static const String _favoritesKey = 'favorite_roms';

  static Future<String?> getRomFolder() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_romFolderKey);
  }

  static Future<void> setRomFolder(String folder) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _romFolderKey,
      folder,
    );
  }

  static Future<void> clearRomFolder() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_romFolderKey);
  }

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_favoritesKey) ?? [];
  }

  static Future<bool> isFavorite(String romPath) async {
    final favorites = await getFavorites();

    return favorites.contains(romPath);
  }

  static Future<void> addFavorite(String romPath) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites =
        prefs.getStringList(_favoritesKey) ?? [];

    if (!favorites.contains(romPath)) {
      favorites.add(romPath);
    }

    await prefs.setStringList(
      _favoritesKey,
      favorites,
    );
  }

  static Future<void> removeFavorite(String romPath) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites =
        prefs.getStringList(_favoritesKey) ?? [];

    favorites.remove(romPath);

    await prefs.setStringList(
      _favoritesKey,
      favorites,
    );
  }

  static Future<void> toggleFavorite(String romPath) async {
    final favorite = await isFavorite(romPath);

    if (favorite) {
      await removeFavorite(romPath);
    } else {
      await addFavorite(romPath);
    }
  }
}