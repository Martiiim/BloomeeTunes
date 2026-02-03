import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/utils/audio_tagger.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

/// Model class to hold the result of an MP3 import
class LocalMp3ImportResult {
  final String title;
  final String artist;
  final String album;
  final String filePath;
  final Duration? duration;
  final String? genre;
  final List<int>? albumArt;
  bool importSuccess = false;
  String? errorMessage;

  LocalMp3ImportResult({
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    this.duration,
    this.genre,
    this.albumArt,
  });

  /// Convert to MediaItemDB for storage
  MediaItemDB toMediaItemDB() {
    final fileName = p.basenameWithoutExtension(filePath);

    return MediaItemDB(
      title: title.isNotEmpty ? title : fileName,
      artist: artist.isNotEmpty ? artist : 'Unknown Artist',
      album: album.isNotEmpty ? album : 'Unknown Album',
      artURL: '', // Local files won't have URL art initially
      genre: genre ?? 'Unknown',
      mediaID: filePath, // Use file path as unique ID
      streamingURL: 'file://$filePath', // Local file URL
      source: 'local', // Mark as local source
      duration: duration?.inMilliseconds,
      permaURL: filePath, // Use file path as permanent URL
      language: 'unknown',
      isLiked: false,
    );
  }
}

/// Service for importing local MP3 files
class LocalMp3ImportService {
  /// Extract metadata from a local MP3 file
  static Future<LocalMp3ImportResult> extractMetadata(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // Read metadata using metadata_god
      final metadata = await MetadataGod.readMetadata(
        file: filePath,
      );

      return LocalMp3ImportResult(
        title: metadata?.title ?? '',
        artist: metadata?.artist ?? '',
        album: metadata?.album ?? '',
        filePath: filePath,
        duration: metadata?.durationMs != null
            ? Duration(milliseconds: metadata!.durationMs!.toInt())
            : null,
        genre: metadata?.genre,
        albumArt: metadata?.picture?.data,
      );
    } catch (e) {
      log('Error extracting metadata from $filePath: $e',
          name: 'LocalMp3ImportService');

      // Fallback to file name
      final fileName = p.basenameWithoutExtension(filePath);
      return LocalMp3ImportResult(
        title: fileName,
        artist: 'Unknown',
        album: 'Local Import',
        filePath: filePath,
      );
    }
  }

  /// Extract metadata from multiple MP3 files
  static Future<List<LocalMp3ImportResult>> extractMetadataFromFiles(
    List<String> filePaths,
  ) async {
    final results = <LocalMp3ImportResult>[];

    for (final filePath in filePaths) {
      try {
        final result = await extractMetadata(filePath);
        results.add(result);
      } catch (e) {
        log('Error processing file $filePath: $e',
            name: 'LocalMp3ImportService');
      }
    }

    return results;
  }

  /// Verify that the file is a valid MP3 file
  static bool isValidMp3File(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext != '.mp3') {
      return false;
    }

    // Check MIME type
    final mimeType = lookupMimeType(filePath);
    return mimeType != null && mimeType.contains('audio');
  }

  /// Get all MP3 files from a directory
  static Future<List<String>> getMp3FilesFromDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);

      if (!await directory.exists()) {
        throw Exception('Directory does not exist: $dirPath');
      }

      final files = directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => isValidMp3File(file.path))
          .map((file) => file.path)
          .toList();

      return files;
    } catch (e) {
      log('Error getting MP3 files from directory: $e',
          name: 'LocalMp3ImportService');
      return [];
    }
  }

  /// Copy MP3 file to app's documents directory (optional, for offline support)
  static Future<String?> copyMp3ToAppDirectory(
    String sourcePath,
    String appDocDir,
  ) async {
    try {
      final file = File(sourcePath);

      if (!await file.exists()) {
        throw Exception('Source file does not exist: $sourcePath');
      }

      final fileName = p.basename(sourcePath);
      final destinationPath = p.join(appDocDir, 'local_mp3s', fileName);

      // Create directory if it doesn't exist
      final destinationDir = Directory(p.dirname(destinationPath));
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }

      // Copy file
      final copiedFile = await file.copy(destinationPath);
      return copiedFile.path;
    } catch (e) {
      log('Error copying MP3 file to app directory: $e',
          name: 'LocalMp3ImportService');
      return null;
    }
  }
}
