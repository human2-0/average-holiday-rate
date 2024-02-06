import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ToastWidget extends StatefulWidget {
  const ToastWidget({required this.message, super.key});
  final String message;

  @override
  _ToastWidgetState createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Start the animation
    _controller.forward();

    // Hide the toast message after some time
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted && !_controller.isDisposed) {
        await _reverseAnimation(); // Reverse the animation
        if (mounted) {
          context.pop();
        }
      }
    });
  }

  Future<void> _reverseAnimation() async {
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.black.withOpacity(0.7),
          ),
          child: Text(
            widget.message,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

void showToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 50,
      left: MediaQuery.of(context).size.width * 0.1,
      child: ToastWidget(message: message),
    ),
  );

  overlay?.insert(overlayEntry);

  // Don't remove the overlay entry immediately
  // It will be removed automatically after reversing the animation
}

extension AnimationControllerExtension on AnimationController {
  bool get isDisposed => status == AnimationStatus.dismissed;
}
