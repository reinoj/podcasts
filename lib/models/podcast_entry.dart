class PodcastEntry {
  // final int id;
  final String title;
  final String rssUrl;

  PodcastEntry(
    // this.id,
    this.title,
    this.rssUrl,
  );

  Map<String, Object?> toMap() {
    return {
      // 'id': id,
      'title': title,
      'rssUrl': rssUrl,
    };
  }
}

PodcastEntry fromMap(Map<String, Object?> map) {
  return PodcastEntry(
    // map['id'] as int,
    map['title'] as String,
    map['rssUrl'] as String,
  );
}
