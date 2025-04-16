import 'package:flutter/material.dart';

class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final AnimationType animationType;

  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutQuad,
    this.animationType = AnimationType.slideRight,
  }) : super(key: key);

  @override
  _AnimatedListItemState createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    // Définir l'animation de glissement en fonction du type d'animation
    switch (widget.animationType) {
      case AnimationType.slideRight:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(_animation);
        break;
      case AnimationType.slideLeft:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(_animation);
        break;
      case AnimationType.slideUp:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(_animation);
        break;
      case AnimationType.slideDown:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, -1.0),
          end: Offset.zero,
        ).animate(_animation);
        break;
      case AnimationType.fade:
        // Pour le type fade, on utilise quand même un slideAnimation mais avec un offset nul
        _slideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero,
        ).animate(_animation);
        break;
    }

    // Retarder l'animation en fonction de l'index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        if (widget.animationType == AnimationType.fade) {
          return FadeTransition(
            opacity: _animation,
            child: widget.child,
          );
        } else {
          return FadeTransition(
            opacity: _animation,
            child: SlideTransition(
              position: _slideAnimation,
              child: widget.child,
            ),
          );
        }
      },
    );
  }
}

enum AnimationType {
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
  fade,
}
