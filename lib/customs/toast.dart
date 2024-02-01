import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToast {
  CustomToast(this.message, this.icon, this.color);
  String message;
  Icon icon;
  Color color;


  static final FToast fToast = FToast();

  // Initializes FToast with a BuildContext
  static void initialize(BuildContext context) {
    fToast.init(context);
  }


  void showCustomToast() {
    final Widget toast = CustomAnimatedToastContent(
      message: message,
      icon: icon,
      color: color,
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
    );
  }
}

class CustomAnimatedToastContent extends StatefulWidget {
  const CustomAnimatedToastContent({
    required this.message,
    required this.icon,
    required this.color,
    super.key,
  });

  final String message;
  final Icon icon;
  final Color color;

  @override
  State<CustomAnimatedToastContent> createState() => _CustomAnimatedToastContentState();
}

class _CustomAnimatedToastContentState extends State<CustomAnimatedToastContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: widget.color,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.icon,
            const SizedBox(width: 12),
            Text(widget.message),
          ],
        ),
      ),
    );
  }
}
