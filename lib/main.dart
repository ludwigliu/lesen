import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import 'reading_settings.dart';
import 'epub_reader_page.dart';

import 'utils/file_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = ReadingSettings();
  settings.loadSettings();

  runApp(ChangeNotifierProvider.value(value: settings, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String lastOpenedFile =
        context.read<ReadingSettings>().getLastOpenedFile ?? '';
    return MaterialApp(
      title: 'lesen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(lastOpenedFile: lastOpenedFile),
    );
  }
}

class HomePage extends StatefulWidget {
  final String lastOpenedFile;
  const HomePage({super.key, required this.lastOpenedFile});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _textContent = 'please select a file to read.';

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'epub'],
    );

    if (result != null && result.files.single.path != null) {
      String? cacheFilePath = result.files.first.path;
      String? permanentFilePath = await copyFileToAppDir(cacheFilePath);
      if (permanentFilePath != null) {
        debugPrint('permant file path: $permanentFilePath');
      }

      String filePath = permanentFilePath!;
      String extension = path.extension(filePath).replaceAll('.', '');

      if (extension == 'epub') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EpubReaderPage(filePath: filePath),
          ),
        );
      } else if (extension == 'txt') {
        File file = File(filePath);
        try {
          String contents = await file.readAsString();
          setState(() {
            _textContent = contents;
          });
        } catch (e) {
          setState(() {
            _textContent = 'failed to read file: $e';
          });
        }
      } else {
        setState(() {
          _textContent = 'Unsupported file type: $extension';
        });
      }
    }
  }

  void _showSettingsPanel() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<ReadingSettings>(
          builder: (context, settings, child) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Font Size'),
                  Slider(
                    value: settings.fontSize,
                    min: 12.0,
                    max: 30.0,
                    divisions: 18,
                    label: settings.fontSize.round().toString(),
                    onChanged: (value) {
                      context.read<ReadingSettings>().setFontSize(value);
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text('Background Color'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildColorChip(context, Colors.white, 'white'),
                      _buildColorChip(
                        context,
                        const Color(0xFFF5F5DC),
                        'beige',
                      ),
                      _buildColorChip(
                        context,
                        const Color(0xFFE8F5E9),
                        'green',
                      ),
                      _buildColorChip(context, const Color(0xFF212121), 'dark'),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildColorChip(BuildContext context, Color color, String name) {
    return InkWell(
      onTap: () {
        context.read<ReadingSettings>().setBackgroundColor(color);
        Navigator.pop(context);
      },
      child: Chip(label: Text(name), backgroundColor: color),
    );
  }

  @override
  void initState() {
    context.read<ReadingSettings>().setLastOpenedFile(widget.lastOpenedFile);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'last saved settings: '
      'fontSize=${context.read<ReadingSettings>().fontSize}, '
      'backgroundColor=${context.read<ReadingSettings>().backgroundColor}, '
      'lastOpenedFile=${context.read<ReadingSettings>().getLastOpenedFile}',
    );

    return widget.lastOpenedFile.isNotEmpty
        ? Consumer<ReadingSettings>(
            builder: (context, setttings, child) =>
                EpubReaderPage(filePath: widget.lastOpenedFile),
          )
        : Consumer<ReadingSettings>(
            builder: (context, settings, child) {
              return Scaffold(
                backgroundColor: settings.backgroundColor,
                appBar: AppBar(
                  title: const Text('My Bookshelf'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: _showSettingsPanel,
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _textContent,
                      style: TextStyle(
                        fontSize: settings.fontSize,
                        height: 1.5,
                        color:
                            settings.backgroundColor == const Color(0xFF212121)
                            ? Colors.grey[300]
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: _pickFile,
                  tooltip: 'choose file',
                  child: const Icon(Icons.add),
                ),
              );
            },
          );
  }
}
