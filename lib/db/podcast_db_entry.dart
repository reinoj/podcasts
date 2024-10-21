class PodcastDbEntry {
  // final int id;
  final String title;
  final String rssUrl;

  PodcastDbEntry(
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

PodcastDbEntry fromMap(Map<String, Object?> map) {
  return PodcastDbEntry(
    // map['id'] as int,
    map['title'] as String,
    map['rssUrl'] as String,
  );
}
