import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RetroMusic extends StatefulWidget {
  const RetroMusic({Key? key}) : super(key: key);

  @override
  State<RetroMusic> createState() => _RetroMusicState();
}

class _RetroMusicState extends State<RetroMusic> {

  double dx = 0;
  double dy = 0;
  double size = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Stack(
                  children: [
                    Positioned(
                      left: dx,
                      top: dy,
                      child: Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle
                        ),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onPanUpdate: (v) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            dx = v.localPosition.dx;
                            dy = v.localPosition.dy;
                          });
                          print(v.localPosition.dx);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: size.r,
                                  height: size.r,
                                  decoration: BoxDecoration(
                                      color: Colors.white12,
                                      shape: BoxShape.circle
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(size/3/2.r),
                                  child: Container(
                                    width: size/3*2.r,
                                    height: size/3*2.r,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
