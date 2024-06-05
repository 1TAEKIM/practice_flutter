import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // 색상 선택기 패키지 임포트
import 'dart:ui' as ui; // dart:ui 패키지 임포트
import 'main.dart'; // main.dart 파일을 임포트합니다.

class HTPDrawingPage extends StatefulWidget {
  @override
  _HTPDrawingPageState createState() => _HTPDrawingPageState();
}

class _HTPDrawingPageState extends State<HTPDrawingPage> {
  double _brushSize = 5.0;
  Color _color = Colors.black;
  List<DrawingPoints> _points = [];
  bool _isErasing = false;
  int _step = 0;

  final List<String> _stepsText = [
    "집을 그려주세요",
    "나무를 그려주세요",
    "사람을 그려주세요"
  ];

  void _changeColor(Color color) {
    setState(() {
      _color = color;
      _isErasing = false;
    });
  }

  void _changeBrushSize(double size) {
    setState(() {
      _brushSize = size;
    });
  }

  void _nextStep() {
    if (_step < 2) {
      setState(() {
        _step++;
        _points.clear();
      });
    } else {
      // 모든 단계가 완료되었을 때의 처리
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NextPage()), // 다음 페이지로 이동
      );
    }
  }

  void _clearDrawing() {
    setState(() {
      _points.clear();
    });
  }

  void _enableEraser() {
    setState(() {
      _isErasing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/main_page.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'HTP 검사 - ${_stepsText[_step]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.white,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              RenderBox renderBox = context.findRenderObject() as RenderBox;
                              _points.add(DrawingPoints(
                                points: renderBox.globalToLocal(details.globalPosition),
                                paint: Paint()
                                  ..color = _isErasing ? Colors.white : _color
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..strokeWidth = _brushSize,
                              ));
                            });
                          },
                          onPanEnd: (details) {
                            _points.add(DrawingPoints(points: Offset.zero, paint: Paint()..color = Colors.transparent));
                          },
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: DrawingPainter(pointsList: _points),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text("Brush Size: "),
                                Slider(
                                  value: _brushSize,
                                  min: 1.0,
                                  max: 20.0,
                                  onChanged: (value) {
                                    _changeBrushSize(value);
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Color: "),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Select Color"),
                                        content: SingleChildScrollView(
                                          child: BlockPicker(
                                            pickerColor: _color,
                                            onColorChanged: (color) {
                                              _changeColor(color);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    color: _color,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Eraser: "),
                                IconButton(
                                  icon: Icon(Icons.brush),
                                  onPressed: _enableEraser,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: _clearDrawing,
                              child: Text('취소'),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _nextStep,
                              child: Text('다음'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoints> pointsList;

  DrawingPainter({required this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i].points != Offset.zero && pointsList[i + 1].points != Offset.zero) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points, pointsList[i].paint);
      } else if (pointsList[i].points != Offset.zero && pointsList[i + 1].points == Offset.zero) {
        canvas.drawPoints(ui.PointMode.points, [pointsList[i].points], pointsList[i].paint); // ui.PointMode 사용
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawingPoints {
  Paint paint;
  Offset points;

  DrawingPoints({required this.points, required this.paint});
}

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(child: Text("Next Page")),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xff110f12),
      iconTheme: IconThemeData(color: Colors.white),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xff110f12),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            DrawerItem(icon: Icons.home, text: 'Home', onTap: () {}),
            DrawerItem(icon: Icons.person, text: 'Profile', onTap: () {}),
            DrawerItem(icon: Icons.settings, text: 'Settings', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  DrawerItem({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
