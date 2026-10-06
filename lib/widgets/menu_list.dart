import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuList extends StatefulWidget {
  final List<String> items;
  final ValueChanged<int> onSelected;
  final ValueChanged<int>? onFavorite;
  final VoidCallback? onBack;

  const MenuList({
    super.key,
    required this.items,
    required this.onSelected,
    this.onFavorite,
    this.onBack,
  });

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  final FocusNode _focusNode = FocusNode();

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Request focus again whenever this screen becomes active.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestFocus();
    });
  }

  void _requestFocus() {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void moveUp() {
    if (widget.items.isEmpty) {
      return;
    }

    setState(() {
      selectedIndex--;

      if (selectedIndex < 0) {
        selectedIndex = widget.items.length - 1;
      }
    });
  }

  void moveDown() {
    if (widget.items.isEmpty) {
      return;
    }

    setState(() {
      selectedIndex++;

      if (selectedIndex >= widget.items.length) {
        selectedIndex = 0;
      }
    });
  }

  void select() {
    if (widget.items.isEmpty) {
      return;
    }

    widget.onSelected(selectedIndex);
  }

  void favorite() {
    if (widget.items.isEmpty) {
      return;
    }

    widget.onFavorite?.call(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        final key = event.logicalKey;

        if (key == LogicalKeyboardKey.arrowUp) {
          moveUp();
          return KeyEventResult.handled;
        }

        if (key == LogicalKeyboardKey.arrowDown) {
          moveDown();
          return KeyEventResult.handled;
        }

        if (key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.space) {
          select();
          return KeyEventResult.handled;
        }

        if (key == LogicalKeyboardKey.keyY) {
          favorite();
          return KeyEventResult.handled;
        }

        if (key == LogicalKeyboardKey.escape) {
          widget.onBack?.call();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          widget.items.length,
          (index) {
            final selected = index == selectedIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });

                select();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Text(
                  selected
                      ? '> ${widget.items[index]}'
                      : '  ${widget.items[index]}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}