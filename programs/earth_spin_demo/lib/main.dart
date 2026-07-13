import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:stacking_widgets/stacking_widgets.dart'
    show PiledWidget, StackingWidgets;
import 'package:three_d_sphere/three_d_sphere.dart' show Quadrant, ThreeDSphere;

const _cobaltBlue = Color(0xFF0047AB);
const _alpha = 0.3;
void main() {
  runApp(const SphereApp());
}

class SphereApp extends StatelessWidget {
  const SphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            children: [
              const Gap(100),

              StackingWidgets(
                size: const Size(200, 150),
                base: ThreeDSphere(
                  width: 20,
                  height: 10,
                  color: _cobaltBlue.withValues(alpha: _alpha),
                  gradientColor: Colors.deepPurpleAccent,
                  lightSource: Quadrant.topCenter,
                  sphereRadius: 1.15,
                ),
                piledWidgets: const [
                  PiledWidget(
                    offset: Offset(10, 20),
                    child: Text(
                      'BASE',
                      style: TextStyle(fontSize: 24, color: Colors.green),
                    ),
                  ),
                ],
              ),

              const Gap(8),
              ThreeDSphere(
                width: 100,
                height: 100,
                color: Colors.purple.withValues(alpha: _alpha),
                gradientColor: Colors.deepPurpleAccent,
                lightSource: Quadrant.topRight,
              ),
              const Gap(8),
              ThreeDSphere(
                width: 100,
                height: 100,
                color: Colors.purple.withValues(alpha: _alpha),
                gradientColor: Colors.white,
                lightSource: Quadrant.bottomRight,
              ),
              const Gap(8),
              ThreeDSphere(
                width: 100,
                height: 100,
                color: Colors.purple.withValues(alpha: _alpha),
                gradientColor: Colors.white,
                lightSource: Quadrant.bottomLeft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
