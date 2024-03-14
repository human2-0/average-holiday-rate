import 'package:flutter/material.dart';

class ToastWidget extends StatefulWidget {
  const ToastWidget({required this.message, required this.backgroundColor,
  required this.textColor,required this.icon, super.key,});
  final String message;
final Color backgroundColor;
final Color textColor;
  final IconData icon;


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
      duration: const Duration(milliseconds: 300,),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Start the animation
    _controller.forward();

    // Hide the toast message after some time
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted && !_controller.isDisposed) {
        await _reverseAnimation(); // Reverse the animation
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
            color: widget.backgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,),
              const SizedBox(width: 4),
              Text(
                widget.message,
                style: TextStyle(color: widget.textColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showToast(BuildContext context, String message, Color backgroundColor, Color textColor,  {IconData icon = Icons.done_outline_rounded}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 100, // Adjust this value to control the vertical positioning
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Center(child: ToastWidget(message: message, backgroundColor: backgroundColor, textColor: textColor, icon: icon,)),
    ),
  );

  overlay?.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), overlayEntry.remove);
}

extension AnimationControllerExtension on AnimationController {
  bool get isDisposed => status == AnimationStatus.dismissed;
}
