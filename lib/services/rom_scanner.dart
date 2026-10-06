import 'dart:io';

class RomSystem {
  final String name;
  final String folderName;
  final List<File> roms;

  RomSystem({
    required this.name,
    required this.folderName,
    required this.roms,
  });
}

class RomScanner {
  static final Map<String, Map<String, dynamic>> systems = {
    'nes': {
      'name': 'NES',
      'extensions': ['nes', 'fds', 'unf'],
    },
    'famicom': {
      'name': 'NES',
      'extensions': ['nes', 'fds', 'unf'],
    },
    'snes': {
      'name': 'SNES',
      'extensions': ['sfc', 'smc', 'fig'],
    },
    'supernintendo': {
      'name': 'SNES',
      'extensions': ['sfc', 'smc', 'fig'],
    },
    'gb': {
      'name': 'GAME BOY',
      'extensions': ['gb'],
    },
    'gameboy': {
      'name': 'GAME BOY',
      'extensions': ['gb'],
    },
    'gbc': {
      'name': 'GAME BOY COLOR',
      'extensions': ['gbc'],
    },
    'gameboycolor': {
      'name': 'GAME BOY COLOR',
      'extensions': ['gbc'],
    },
    'gba': {
      'name': 'GAME BOY ADVANCE',
      'extensions': ['gba'],
    },
    'gameboyadvance': {
      'name': 'GAME BOY ADVANCE',
      'extensions': ['gba'],
    },
    'n64': {
      'name': 'N64',
      'extensions': ['n64', 'z64', 'v64'],
    },
    'nds': {
      'name': 'NINTENDO DS',
      'extensions': ['nds'],
    },
    '3ds': {
      'name': '3DS',
      'extensions': ['3ds', 'cia'],
    },
    'ps1': {
      'name': 'PLAYSTATION',
      'extensions': ['iso', 'bin', 'cue', 'chd', 'pbp'],
    },
    'psx': {
      'name': 'PLAYSTATION',
      'extensions': ['iso', 'bin', 'cue', 'chd', 'pbp'],
    },
    'playstation': {
      'name': 'PLAYSTATION',
      'extensions': ['iso', 'bin', 'cue', 'chd', 'pbp'],
    },
    'psp': {
      'name': 'PSP',
      'extensions': ['iso', 'cso', 'pbp'],
    },
    'genesis': {
      'name': 'GENESIS',
      'extensions': ['md', 'gen', 'bin'],
    },
    'megadrive': {
      'name': 'GENESIS',
      'extensions': ['md', 'gen', 'bin'],
    },
    'dreamcast': {
      'name': 'DREAMCAST',
      'extensions': ['gdi', 'cdi', 'chd'],
    },
  };

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('-', '');
  }

  static Future<List<RomSystem>> scan(String rootPath) async {
    final root = Directory(rootPath);

    if (!await root.exists()) {
      return [];
    }

    final results = <RomSystem>[];

    try {
      await for (final entity in root.list(followLinks: false)) {
        if (entity is! Directory) {
          continue;
        }

        final folderName = entity.path.split(Platform.pathSeparator).last;
        final normalizedName = _normalize(folderName);

        final systemInfo = systems[normalizedName];

        if (systemInfo == null) {
          continue;
        }

        final extensions =
            (systemInfo['extensions'] as List<dynamic>).cast<String>();

        final roms = <File>[];

        await for (final fileEntity in entity.list(
          recursive: true,
          followLinks: false,
        )) {
          if (fileEntity is! File) {
            continue;
          }

          final fileName = fileEntity.path.split(Platform.pathSeparator).last;

          if (!fileName.contains('.')) {
            continue;
          }

          final extension =
              fileName.split('.').last.toLowerCase();

          if (extensions.contains(extension)) {
            roms.add(fileEntity);
          }
        }

        roms.sort(
          (a, b) => a.path.toLowerCase().compareTo(
                b.path.toLowerCase(),
              ),
        );

        if (roms.isNotEmpty) {
          results.add(
            RomSystem(
              name: systemInfo['name'] as String,
              folderName: folderName,
              roms: roms,
            ),
          );
        }
      }
    } catch (e) {
      return [];
    }

    results.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return results;
  }
}