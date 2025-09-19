import 'package:flutter/material.dart';
import 'package:lesen/books/book.dart';
import 'package:lesen/books/book_shelf.dart';
import 'package:provider/provider.dart';

import 'reading_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = ReadingSettings();
  settings.loadSettings();

  runApp(ChangeNotifierProvider.value(value: settings, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String booksDir = '/storage/emulated/0/Download/books/';

  @override
  Widget build(BuildContext context) {
    List<Book> books = [
      Book('', '', 1968, title: '负零', filePath: '$booksDir负零.epub'),
      Book('', '', 2002, title: 'Heidi', filePath: '${booksDir}Heidi.epub'),
    ];
    return MaterialApp(
      title: 'lesen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BookShelf(books: books),
    );
  }
}
