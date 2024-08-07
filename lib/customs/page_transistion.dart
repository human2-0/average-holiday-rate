import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  const FadeTransitionPage({required LocalKey super.key, required super.child})
      : super(
    transitionsBuilder: _transitionsBuilder,
    transitionDuration: const Duration(milliseconds: 100),
  );

  static Widget _transitionsBuilder(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) => FadeTransition(
      opacity: animation,
      child: child,
    );
}
