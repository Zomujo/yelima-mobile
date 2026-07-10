import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MultiValueListenableBuilder extends StatefulWidget {
  const MultiValueListenableBuilder({
    super.key,
    required this.valueListenables,
    required this.builder,
    this.child,
  });

  final List<ValueListenable> valueListenables;
  final Widget? child;
  final Widget Function(
      BuildContext context, List<dynamic> values, Widget? child) builder;

  @override
  State<MultiValueListenableBuilder> createState() =>
      _MultiValueListenableBuilderState();
}

class _MultiValueListenableBuilderState
    extends State<MultiValueListenableBuilder> {
  @override
  void initState() {
    super.initState();
    for (final valueListenable in widget.valueListenables) {
      valueListenable.addListener(_valueChanged);
    }
  }

  @override
  void didUpdateWidget(MultiValueListenableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenables != widget.valueListenables) {
      for (final valueListenable in oldWidget.valueListenables) {
        valueListenable.removeListener(_valueChanged);
      }
      for (final valueListenable in widget.valueListenables) {
        valueListenable.addListener(_valueChanged);
      }
    }
  }

  @override
  void dispose() {
    for (final valueListenable in widget.valueListenables) {
      valueListenable.removeListener(_valueChanged);
    }
    super.dispose();
  }

  void _valueChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.valueListenables.map((value) => value.value).toList(),
      widget.child,
    );
  }
}
