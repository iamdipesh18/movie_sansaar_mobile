class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int totalPages;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
