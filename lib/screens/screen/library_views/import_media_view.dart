// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/utils/external_list_importer.dart';
import 'package:Bloomee/services/import_export_service.dart';
import 'package:Bloomee/services/local_mp3_import_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/import_playlist.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum ImportType {
  spotifyPlaylist,
  spotifySingle,
  spotifyAlbum,
  youtubeVidPlaylist,
  youtubeVidSingle,
  youtubeMusicPlaylist,
  youtubeMusicAlbum,
  youtubeMusicSingle,
  storage,
}

class ImportMediaFromPlatformsView extends StatelessWidget {
  const ImportMediaFromPlatformsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Import Songs',
          textAlign: TextAlign.start,
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
          ImportFromBtn(
            btnName: "Playlist from Spotify",
            btnIcon: FontAwesome.spotify_brand,
            onClickFunc: () {
              getIdAndShowBottomSheet(context,
                  hintText: "https://open.spotify.com/playlist/XXXXX",
                  importType: ImportType.spotifyPlaylist);
            },
          ),
          ImportFromBtn(
              btnName: "Music from Spotify",
              btnIcon: FontAwesome.spotify_brand,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "https://open.spotify.com/track/XXXXXX",
                    importType: ImportType.spotifySingle);
              }),
          ImportFromBtn(
              btnName: "Album from Spotify",
              btnIcon: FontAwesome.spotify_brand,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "https://open.spotify.com/album/XXXXXX",
                    importType: ImportType.spotifyAlbum);
              }),
          ImportFromBtn(
              btnName: "Playlist from Youtube",
              btnIcon: FontAwesome.youtube_brand,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "https://www.youtube.com/playlist?list=XXXXXX",
                    importType: ImportType.youtubeVidPlaylist);
              }),
          ImportFromBtn(
              btnName: "Music from Youtube",
              btnIcon: FontAwesome.youtube_brand,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "https://www.youtube.com/watch?v=XXXXXX",
                    importType: ImportType.youtubeVidSingle);
              }),
          ImportFromBtn(
              btnName: "Music from Youtube-Music",
              btnIcon: FontAwesome.circle_play,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "https://music.youtube.com/watch?v=XXXXXX",
                    importType: ImportType.youtubeMusicSingle);
              }),
          ImportFromBtn(
              btnName: "Playlist from Youtube-Music Playlist",
              btnIcon: FontAwesome.circle_play,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "https://music.youtube.com/playlist?list=XXXXXX",
                    importType: ImportType.youtubeMusicPlaylist);
              }),
          ImportFromBtn(
              btnName: "Playlist from Youtube-Music Album",
              btnIcon: FontAwesome.circle_play,
              onClickFunc: () {
                getIdAndShowBottomSheet(context,
                    hintText: "https://music.youtube.com/playlist?list=XXXXXX",
                    importType: ImportType.youtubeMusicPlaylist);
              }),
          ImportFromBtn(
              btnName: "Import Local MP3 Files",
              btnIcon: MingCute.music_fill,
              onClickFunc: () async {
                _importLocalMp3s(context);
              }),
          ImportFromBtn(
              btnName: "Import Bloomee Files",
              btnIcon: MingCute.file_import_fill,
              onClickFunc: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      "Note",
                      style: TextStyle(
                        color: Default_Theme.primaryColor2,
                      ),
                    ),
                    content: const Text(
                      "You can only import files created by Bloomee. \nIf your file is from another source, it will not work. Continue anyway?",
                      style: TextStyle(
                        color: Default_Theme.primaryColor2,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          FilePicker.platform.pickFiles().then((value) {
                            if (value != null) {
                              log(value.files[0].path.toString(),
                                  name: "Import File");
                              if (value.files[0].path != null) {
                                if (value.files[0].path!.endsWith('.blm') ||
                                    value.files[0].path!.endsWith('.json')) {
                                  SnackbarService.showMessage(
                                      "Importing MediaItems..");
                                  ImportExportService.importJSON(
                                          value.files[0].path!)
                                      .then((v) {
                                    SnackbarService.showMessage(
                                        "Process: Importing completed.");
                                  });
                                } else {
                                  log("Invalid File Format",
                                      name: "Import File");
                                  SnackbarService.showMessage(
                                      "Invalid File Format");
                                }
                              }
                            }
                          });
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }),
          ],
          ),
        ),
      ),
    );
  }
}

class ImportFromBtn extends StatelessWidget {
  final String btnName;
  final IconData btnIcon;
  final VoidCallback onClickFunc;
  const ImportFromBtn({
    Key? key,
    required this.btnName,
    required this.btnIcon,
    required this.onClickFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onClickFunc,
      title: Text(
        btnName,
        style: const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 18,
                fontWeight: FontWeight.w500)
            .merge(Default_Theme.secondoryTextStyle),
      ),
      leading: Icon(
        btnIcon,
        color: Default_Theme.primaryColor1,
        size: 25,
      ),
    );
  }
}

Future getIdAndShowBottomSheet(BuildContext context,
    {String hintText = "Playlist ID", required ImportType importType}) {
  return showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 190,
          color: Default_Theme.accentColor2,
          child: Column(
            children: [
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Default_Theme.themeColor,
                  height: 180,
                  child: Center(
                    child: Wrap(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextField(
                              textInputAction: TextInputAction.done,
                              maxLines: 3,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.center,
                              // focusNode: _focusNode,
                              cursorHeight: 45,
                              showCursor: true,
                              cursorWidth: 5,
                              cursorRadius: const Radius.circular(5),
                              cursorColor: Default_Theme.accentColor2,
                              autofocus: true,

                              style: const TextStyle(
                                      fontSize: 30,
                                      color: Default_Theme.accentColor2)
                                  .merge(
                                      Default_Theme.secondoryTextStyleMedium),
                              decoration: InputDecoration(
                                  hintText: hintText,
                                  hintStyle: TextStyle(
                                      color: Default_Theme.primaryColor2
                                          .withValues(alpha: 0.3)),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(style: BorderStyle.none),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  )),
                              onSubmitted: (value) {
                                switch (importType) {
                                  case ImportType.spotifyPlaylist:
                                    context.pop(context);
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          ImporterDialogWidget(
                                              strm: ExternalMediaImporter
                                                  .sfyPlaylistImporter(
                                                      url: value)),
                                    );
                                    break;
                                  case ImportType.spotifySingle:
                                    context.pop(context);
                                    ExternalMediaImporter.sfyMediaImporter(
                                            value)
                                        .then((value) {
                                      if (value != null) {
                                        BloomeeDBService.addMediaItem(
                                            MediaItem2MediaItemDB(value),
                                            "Spotify Imports");
                                        SnackbarService.showMessage(
                                            "Imported Media: ${value.title}");
                                      } else {
                                        log("Failed to import media",
                                            name: "Import Media");
                                      }
                                    });
                                  case ImportType.spotifyAlbum:
                                    context.pop(context);
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          ImporterDialogWidget(
                                              strm: ExternalMediaImporter
                                                  .sfyAlbumImporter(
                                                      url: value)),
                                    );
                                    break;
                                  case ImportType.youtubeVidPlaylist:
                                    context.pop(context);
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          ImporterDialogWidget(
                                              strm: ExternalMediaImporter
                                                  .ytPlaylistImporter(value)),
                                    );
                                    break;
                                  case ImportType.youtubeVidSingle:
                                    context.pop();
                                    ExternalMediaImporter.ytMediaImporter(value)
                                        .then((value) {
                                      if (value != null) {
                                        BloomeeDBService.addMediaItem(
                                            MediaItem2MediaItemDB(value),
                                            "Youtube Imports");
                                        SnackbarService.showMessage(
                                            "Imported Media: ${value.title}");
                                      } else {
                                        log("Failed to import media from YT",
                                            name: "Import Media");
                                      }
                                    });
                                    break;
                                  case ImportType.youtubeMusicPlaylist:
                                    context.pop();

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return ImporterDialogWidget(
                                            strm: ExternalMediaImporter
                                                .ytmPlaylistImporter(value));
                                      },
                                    );
                                    break;
                                  case ImportType.youtubeMusicAlbum:
                                    context.pop();
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return ImporterDialogWidget(
                                            strm: ExternalMediaImporter
                                                .ytmPlaylistImporter(value));
                                      },
                                    );
                                    break;
                                  case ImportType.youtubeMusicSingle:
                                    context.pop();
                                    ExternalMediaImporter.ytmMediaImporter(
                                            value)
                                        .then((value) {
                                      if (value != null) {
                                        BloomeeDBService.addMediaItem(
                                            MediaItem2MediaItemDB(value),
                                            "Youtube Imports");
                                        SnackbarService.showMessage(
                                            "Imported Media: ${value.title}");
                                      } else {
                                        log("Failed to import media from YT",
                                            name: "Import Media");
                                      }
                                    });
                                    break;
                                  case ImportType.storage:
                                    // Handled by the separate function
                                    break;
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Function to handle importing local MP3 files
Future<void> _importLocalMp3s(BuildContext context) async {
  try {
    // Pick multiple MP3 files
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['mp3'],
    );

    if (result == null || result.files.isEmpty) {
      log("No files selected", name: "Local MP3 Import");
      return;
    }

    // Show progress dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _LocalMp3ImportProgressDialog(
          filePaths: result.files.map((f) => f.path!).toList(),
        );
      },
    );
  } catch (e) {
    log("Error picking files: $e", name: "Local MP3 Import");
    SnackbarService.showMessage("Error selecting files: $e");
  }
}

/// Dialog widget for showing MP3 import progress
class _LocalMp3ImportProgressDialog extends StatefulWidget {
  final List<String> filePaths;

  const _LocalMp3ImportProgressDialog({
    Key? key,
    required this.filePaths,
  }) : super(key: key);

  @override
  State<_LocalMp3ImportProgressDialog> createState() =>
      _LocalMp3ImportProgressDialogState();
}

class _LocalMp3ImportProgressDialogState
    extends State<_LocalMp3ImportProgressDialog> {
  late Future<void> _importFuture;
  int _processedCount = 0;
  int _successCount = 0;
  String _currentFile = "";

  @override
  void initState() {
    super.initState();
    _importFuture = _performImport();
  }

  Future<void> _performImport() async {
    try {
      // Get app document directory for offline storage
      final appDocDir = (await getApplicationDocumentsDirectory()).path;

      final results = await LocalMp3ImportService.extractMetadataFromFiles(
        widget.filePaths,
      );

      // Add all valid MP3s to the library
      for (final result in results) {
        setState(() {
          _processedCount++;
          _currentFile = result.title;
        });

        try {
          // Copy MP3 to app's offline storage for offline availability
          final offlinePath = await LocalMp3ImportService.copyMp3ToAppDirectory(
            result.filePath,
            appDocDir,
          );

          // Create playlist if it doesn't exist
          final playlistName = "Local MP3s";
          await BloomeeDBService.createPlaylist(playlistName);

          // Add media item to playlist with offline path
          final mediaItemDB = result.toMediaItemDB();
          // Update streaming URL to use offline copy if available
          if (offlinePath != null) {
            mediaItemDB.streamingURL = 'file://$offlinePath';
            mediaItemDB.permaURL = offlinePath;
          }
          await BloomeeDBService.addMediaItem(mediaItemDB, playlistName);

          // Register as downloaded so it appears in offline library
          if (offlinePath != null) {
            final fileName = p.basename(offlinePath);
            final filePath = p.dirname(offlinePath);
            await BloomeeDBService.putDownloadDB(
              fileName: fileName,
              filePath: filePath,
              lastDownloaded: DateTime.now(),
              mediaItem: MediaItemDB2MediaItem(mediaItemDB),
            );
          }

          setState(() {
            _successCount++;
          });
        } catch (e) {
          log("Error adding media item ${result.title}: $e",
              name: "Local MP3 Import");
        }
      }

      // Show completion message
      if (mounted) {
        SnackbarService.showMessage(
          "Imported $_successCount of ${widget.filePaths.length} MP3 files",
        );
      }
    } catch (e) {
      log("Import error: $e", name: "Local MP3 Import");
      if (mounted) {
        SnackbarService.showMessage("Import failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Default_Theme.themeColor,
      title: const Text(
        "Importing MP3 Files",
        style: TextStyle(
          color: Default_Theme.primaryColor1,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: FutureBuilder<void>(
        future: _importFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Default_Theme.accentColor1,
                ),
                const SizedBox(height: 16),
                Text(
                  "Processing: $_processedCount/${widget.filePaths.length}",
                  style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentFile,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor2,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Import Complete!",
                style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontWeight: FontWeight.bold,
                ).merge(Default_Theme.primaryTextStyle),
              ),
              const SizedBox(height: 16),
              Text(
                "Successfully imported: $_successCount/${widget.filePaths.length}",
                style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                ),
              ),
              const SizedBox(height: 16),
              if (_successCount > 0)
                Text(
                  "Your MP3s have been added to 'Local MP3s' playlist",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor2,
                    fontSize: 12,
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "Done",
            style: TextStyle(color: Default_Theme.accentColor1),
          ),
        ),
      ],
    );
  }
}
