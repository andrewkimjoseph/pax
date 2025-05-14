class ForumReport {
  final String id;
  final String? title;
  final String? subtitle;
  final DateTime? timePublished;
  final String? coverImageURI;
  final String? postURI;

  ForumReport({
    required this.id,
    this.title,
    this.subtitle,
    this.timePublished,
    this.coverImageURI,
    this.postURI,
  });
}
