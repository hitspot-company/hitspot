class HSTag {
  final String? tid, value;
  final int? spotsCount, boardsCount, tripsCount, searchesCount, followsCount;

  HSTag({
    this.tid,
    this.value,
    this.spotsCount,
    this.boardsCount,
    this.tripsCount,
    this.searchesCount,
    this.followsCount,
  });

  factory HSTag.deserialize(Map<String, dynamic> data) {
    return HSTag(
      tid: data['id'],
      value: data['tag_value'],
      spotsCount: data['spots_count'],
      boardsCount: data['boards_count'],
      tripsCount: data['trips_count'],
      searchesCount: data['searches_count'],
      followsCount: data['follows_count'],
    );
  }

  Map<String, dynamic> serialize() {
    return {
      'tag_value': value,
      'spots_count': spotsCount,
      'boards_count': boardsCount,
      'trips_count': tripsCount,
      'searches_count': searchesCount,
      'follows_count': followsCount,
    };
  }
}
