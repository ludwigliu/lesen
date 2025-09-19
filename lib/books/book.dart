class Book {
  final String title;
  final String? author;
  final int? publicationYear;
  final String filePath;
  String? coverImagePath;

  Book(
    this.coverImagePath,
    this.author,
    this.publicationYear, {
    required this.title,
    required this.filePath,
  });
}
