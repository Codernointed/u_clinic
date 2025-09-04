import 'package:flutter/material.dart';

class SharedAxisPageRoute extends PageRouteBuilder {
  final Widget child;
  final String transitionType; // Simplified to just use a string

  SharedAxisPageRoute({required this.child, this.transitionType = 'horizontal'})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: transitionType == 'horizontal'
                      ? const Offset(1.0, 0.0)
                      : const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },
      );
}
