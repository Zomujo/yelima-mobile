void main() {
  final list = [
    DateTime(2023, 1, 1), // Oldest
    DateTime(2023, 1, 5), // Middle
    DateTime(2023, 1, 10), // Newest
  ];
  list.sort((a, b) => b.compareTo(a));
  print(list);
}
