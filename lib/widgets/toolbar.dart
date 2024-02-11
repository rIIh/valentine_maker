import 'package:flutter/material.dart';
import 'package:valentine/theme/theme.dart';

enum DefaultToolbarActions {
  erase,
  pen,
  fill,
  blister,
  ;

  Widget build() => Image.asset('assets/images/maker/toolbar/$name.png');
}

class ToolbarActionData<T> {
  final T value;
  final Widget child;

  ToolbarActionData({required this.value, required this.child});
}

enum Palette { sizes, colors, blister, none }

class Toolbar<T> extends StatelessWidget {
  final T selected;
  final ValueSetter<T> onSelected;
  final List<ToolbarActionData<T>> actions;

  final Palette activePalette;

  final int? selectedColor;
  final List<Color> colors;
  final ValueSetter<int>? onColorSelected;

  final double selectedSize;
  final ValueSetter<double>? onSizeSelected;

  const Toolbar({
    super.key,
    required this.actions,
    required this.selected,
    required this.onSelected,
    this.selectedColor,
    this.colors = const [],
    this.onColorSelected,
    this.activePalette = Palette.none,
    this.selectedSize = 22,
    this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return RestorationScope(
      restorationId: 'colors',
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRect(
              child: AnimatedAlign(
                heightFactor: {Palette.colors, Palette.blister}.contains(activePalette) ? 1 : 0,
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Padding(
                    key: const Key('colors'),
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      restorationId: 'colors',
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 33,
                        children: [
                          for (final (index, color) in colors.indexed)
                            GestureDetector(
                              onTap: () => onColorSelected?.call(index),
                              child: AnimatedContainer(
                                width: 55,
                                height: 55,
                                duration: const Duration(milliseconds: 140),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: activePalette == Palette.blister
                                      ? const DecorationImage(image: AssetImage('assets/images/noise.png'))
                                      : null,
                                  border: Border.all(
                                    width: selectedColor == index ? 5 : 0,
                                    color: selectedColor == index ? context.white : Colors.white.withAlpha(0),
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  color: color,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ClipRect(
              child: AnimatedAlign(
                heightFactor: activePalette == Palette.sizes ? 1 : 0,
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 50,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final size in <double>[22, 33, 44, 55])
                            GestureDetector(
                              onTap: () => onSizeSelected?.call(size),
                              child: AnimatedContainer(
                                width: size,
                                height: size,
                                duration: const Duration(milliseconds: 140),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: selectedSize == size ? 5 : 0,
                                    color: selectedSize == size ? context.pink : context.pink.withAlpha(0),
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  color: context.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 95,
              child: Wrap(
                spacing: 25,
                children: [
                  for (final action in actions)
                    ToolbarAction(
                      selected: selected == action.value,
                      onSelected: () => onSelected(action.value),
                      child: action.child,
                    ),
                ].toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ToolbarAction extends StatefulWidget {
  final bool selected;
  final Widget child;
  final VoidCallback onSelected;

  const ToolbarAction({
    super.key,
    this.selected = false,
    required this.child,
    required this.onSelected,
  });

  @override
  State<ToolbarAction> createState() => _ToolbarActionState();
}

class _ToolbarActionState extends State<ToolbarAction> with TickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);

  @override
  void initState() {
    _controller.duration = const Duration(milliseconds: 140);
    if (widget.selected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ToolbarAction oldWidget) {
    _controller.duration = const Duration(milliseconds: 140);
    if (widget.selected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = Tween(begin: const Offset(0, 30), end: const Offset(0, 0))
        .chain(CurveTween(curve: Curves.ease))
        .animate(_controller);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: animation.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onSelected,
        child: widget.child,
      ),
    );
  }
}
