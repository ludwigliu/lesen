import 'package:flutter/material.dart';
import 'package:lesen/books/book.dart';

class BookItem extends StatelessWidget {
  final VoidCallback onTap;
  final Book book;

  const BookItem({super.key, required this.onTap, required this.book});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        height: 70,
        child: Image.asset(
          book.coverImagePath ?? 'assets/images/default_cover.png',
          fit: BoxFit.cover,
        ),
      ),
      title: Text(book.title),
      subtitle: Text(book.filePath),
    );
  }
}
