import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

const fadeTabDuration = Duration(milliseconds: 220);
const fadeTabCurve = Curves.easeInOut;

/// The slide starts quickly and settles long and gently, so the second half
/// of the move stays calm; the base duration is a little longer than M3's.
const slideTabDuration = Duration(milliseconds: 380);
const slideTabCurve = Cubic(0.2, 0.45, 0.25, 1);

const minTabAnimationSpeed = 0.5;
const maxTabAnimationSpeed = 2.0;

/// Scales a tab transition's base [duration] by the user's speed multiplier:
/// faster runs in less time, and values outside the slider's range clamp.
Duration tabAnimationDurationOf(Duration duration, double speed) {
  final clamped = speed.clamp(minTabAnimationSpeed, maxTabAnimationSpeed);
  return duration * (1 / clamped);
}

/// Plays [spring] over the first [seconds] of an animation, easing out the
/// remaining residual so the curve still ends exactly at 1.
class SpringCurve extends Curve {
  SpringCurve(SpringDescription spring, {required this.seconds})
    : _simulation = SpringSimulation(spring, 0, 1, 0);

  final double seconds;
  final SpringSimulation _simulation;

  late final double _residual = 1 - _simulation.x(seconds);

  @override
  double transformInternal(double t) =>
      _simulation.x(t * seconds) + _residual * t;
}

final dropletSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 165,
  ratio: 0.8,
);

/// Rises to 1 at [peak] and back, as iOS 27's droplets overshoot and swell.
double riseAndFall(double time, double peak, double sharpness) {
  if (time <= 0) {
    return 0;
  }
  final x = time / peak;
  return math.pow(x, sharpness) * math.exp(sharpness * (1 - x));
}
