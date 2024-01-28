import 'package:coozy_cafe/widgets/progress_button/button_stagger_animation.dart';
import 'package:flutter/material.dart';

class ProgressButton extends StatefulWidget {
  /// The background color of the button.
  final Color? color;

  /// The progress indicator color.
  final Color? progressIndicatorColor;

  /// The size of the progress indicator.
  final double? progressIndicatorSize;

  /// The border radius while NOT animating.
  final BorderRadius? borderRadius;

  /// The duration of the animation.
  final Duration? animationDuration;

  /// The stroke width of progress indicator.
  final double? strokeWidth;

  /// Function that will be called at the on pressed event.
  ///
  /// This will grant access to its [AnimationController] so
  /// that the animation can be controlled based on the need.
  final Function(AnimationController)? onPressed;

  /// The child to display on the button.
  final Widget? child;

  const ProgressButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = Colors.blue,
    this.strokeWidth = 2,
    this.progressIndicatorColor = Colors.white,
    this.progressIndicatorSize = 30,
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  _ProgressButtonState createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton>
    with TickerProviderStateMixin {
  AnimationController? controller;
  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ButtonStaggerAnimation(
        controller: controller,
        color: widget.color,
        strokeWidth: widget.strokeWidth,
        progressIndicatorColor: widget.progressIndicatorColor,
        progressIndicatorSize: widget.progressIndicatorSize,
        borderRadius: widget.borderRadius,
        onPressed: widget.onPressed,
        child: widget.child,
      ),
    );
  }
}
