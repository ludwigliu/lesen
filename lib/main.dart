import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:epub_view/epub_view.dart'; // 导入 epub_view
import 'package:path/path.dart' as path; 
import 'package:provider/provider.dart';
import 'reading_settings.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = ReadingSettings();
  settings.loadSettings(); 

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lesen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
      String filePath = result.files.single.path!;
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
                  // 字体大小设置
                  const Text('Font Size'),
                  Slider(
                    value: settings.fontSize,
                    min: 12.0,
                    max: 30.0,
                    divisions: 18,
                    label: settings.fontSize.round().toString(),
                    onChanged: (value) {
                      // 这里我们调用方法来改变设置，注意 listen: false
                      context.read<ReadingSettings>().setFontSize(value);
                    },
                  ),
                  const SizedBox(height: 10),
                  // 背景颜色设置
                  const Text('Background Color'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildColorChip(context, Colors.white, 'white'),
                      _buildColorChip(context, const Color(0xFFF5F5DC), 'beige'),
                      _buildColorChip(context, const Color(0xFFE8F5E9), 'green'),
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
      child: Chip(
        label: Text(name),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingSettings>(
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
                  color: settings.backgroundColor == const Color(0xFF212121) 
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

class EpubReaderPage extends StatefulWidget {
  final String filePath;
  const EpubReaderPage({super.key, required this.filePath});

  @override
  State<EpubReaderPage> createState() => _EpubReaderPageState();
}

class _EpubReaderPageState extends State<EpubReaderPage> {
  late EpubController _epubController;

  @override
  void initState() {
    super.initState();
    _epubController = EpubController(
      document: EpubDocument.openFile(File(widget.filePath)),
    );
  }
  
  @override
  void dispose() {
    _epubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingSettings>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: EpubViewActualChapter(
              controller: _epubController,
              builder: (chapterValue) => Text(
                chapterValue?.chapter?.Title ?? 'Loading...',
                textAlign: TextAlign.start,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.menu_book_outlined),
                onPressed: () => _showTableOfContents(context),
              ),
            ],
          ),
          drawer: Drawer(
            child: EpubViewTableOfContents(
              controller: _epubController,
            ),
          ),
          body: EpubView(
            controller: _epubController,
             builders: EpubViewBuilders<DefaultBuilderOptions>(
              options: DefaultBuilderOptions(textStyle: TextStyle(fontSize: settings.fontSize)),
              chapterDividerBuilder: (_) => const Divider(),
            ),
          ),
        );
      },
    );
  }
  
  void _showTableOfContents(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: EpubViewTableOfContents(controller: _epubController),
        );
      },
    );
  }
}