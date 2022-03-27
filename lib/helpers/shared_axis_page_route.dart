import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class SharedAxisPageRoute extends PageRouteBuilder {
  SharedAxisPageRoute({required Widget page, required SharedAxisTransitionType transitionType, required double duration}) : super(
    transitionDuration: Duration(milliseconds: (duration * 1000).round()),
    pageBuilder: (
        BuildContext context,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
        ) => page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) {
      return SharedAxisTransition(
        animation: primaryAnimation,
        secondaryAnimation: secondaryAnimation,
        transitionType: transitionType,
        child: child,
      );
    },
  );

  // static const double kDefaultDuration = 1000;
  //
  // static Route<T> fadeThrough<T>(Widget page, [double duration = kDefaultDuration]) {
  //   return PageRouteBuilder<T>(
  //     transitionDuration: Duration(milliseconds: (duration * 1000).round()),
  //     pageBuilder: (context, animation, secondaryAnimation) => page,
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       return FadeThroughTransition(animation: animation, secondaryAnimation: secondaryAnimation, child: child);
  //     },
  //   );
  // }
  //
  // static Route<T> fadeScale<T>(Widget page, [double duration = kDefaultDuration]) {
  //   return PageRouteBuilder<T>(
  //     transitionDuration: Duration(milliseconds: (duration * 1000).round()),
  //     pageBuilder: (context, animation, secondaryAnimation) => page,
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       return FadeScaleTransition(animation: animation, child: child);
  //     },
  //   );
  // }
  //
  // static Route<T> sharedAxis<T>(Widget page, [SharedAxisTransitionType type = SharedAxisTransitionType.scaled, double duration = kDefaultDuration]) {
  //   return PageRouteBuilder<T>(
  //     transitionDuration: Duration(milliseconds: (duration * 1000).round()),
  //     pageBuilder: (context, animation, secondaryAnimation) => page,
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       return SharedAxisTransition(
  //         child: child,
  //         animation: animation,
  //         secondaryAnimation: secondaryAnimation,
  //         transitionType: type,
  //       );
  //     },
  //   );
  // }
}