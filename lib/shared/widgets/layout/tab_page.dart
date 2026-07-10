import 'package:flutter/material.dart';

class TabPage<T> extends StatelessWidget {
  final List<T> items;
  final Widget emptyWidget;
  final Widget Function(T item) itemBuilder;

  const TabPage({
    super.key,
    required this.items,
    required this.emptyWidget,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: items.isEmpty
          ? emptyWidget
          : ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: itemBuilder(items[index]),
                );
              },
            ),
    );
  }
}
