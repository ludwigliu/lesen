import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reading_settings.dart';

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
                      // 这里我们调用方法来改变设置，注意 listen: false
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
                icon: const Icon(Icons.settings),
                onPressed: _showSettingsPanel,
              ),
            ],
          ),
          drawer: Drawer(
            child: EpubViewTableOfContents(controller: _epubController),
          ),
          body: EpubView(
            controller: _epubController,
            builders: EpubViewBuilders<DefaultBuilderOptions>(
              options: DefaultBuilderOptions(
                textStyle: TextStyle(
                  fontSize: settings.fontSize,
                  height: 1.5,
                  color: settings.backgroundColor == const Color(0xFF212121)
                      ? Colors.grey[300]
                      : Colors.black,
                ),
              ),
              chapterDividerBuilder: (_) => const Divider(),
            ),
          ),
        );
      },
    );
  }
}
