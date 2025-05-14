import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class OnBoardingController {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  final TickerProvider vsync;

  OnBoardingController({required this.vsync}) {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }
  Animation<Offset> get slideAnimation => _slideAnimation;
  Animation<double> get fadeAnimation => _fadeAnimation;

  void resetAnimations() {
    _controller.reset();
    _controller.forward();
  }
  void dispose() {
    _controller.dispose();
  }
}