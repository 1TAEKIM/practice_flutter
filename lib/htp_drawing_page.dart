import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mindcare_flutter/htp_api_service.dart';  // 파일 경로 수정
import 'package:path_provider/path_provider.dart';  // 추가된 패키지
import 'main.dart';
import 'htp_result_page.dart';  // 결과 페이지 파일 경로 추가

class HTPDrawingPage extends StatefulWidget {
  @override
  _HTPDrawingPageState createState() => _HTPDrawingPageState();
}

class _HTPDrawingPageState extends State<HTPDrawingPage> {
  final GlobalKey _globalKey = GlobalKey();  // 추가된 부분
  double _brushSize = 5.0;
  double _eraserSize = 5.0;
  Color _color = Colors.black;
  List<DrawingPoints> _points = [];
  bool _isErasing = false;
  int _step = 0;
  File? _image;
  final picker = ImagePicker();
  String _result = '';
  int? _drawingId;  // 추가된 부분

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

  void _changeEraserSize(double size) {
    setState(() {
      _eraserSize = size;
    });
  }

  Future<void> _nextStep() async {
    if (_step < 2) {
      setState(() {
        _step++;
        _points.clear();
      });
    } else {
      await _saveToFile();
      if (_image != null) {
        var response = await ApiService.uploadDrawing(_image!, _stepsText[_step], 'your_token');
        setState(() {
          _drawingId = response['id'];  // 수정된 부분
          _result = 'Uploaded. Ready for diagnosis.';
        });
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultPage(result: _result, imageUrl: _image?.path ?? '')),
      );
    }
  }

  Future<void> _saveToFile() async {
    try {
      await Future.delayed(Duration(milliseconds: 100));  // RepaintBoundary가 페인팅될 시간을 줌
      final boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png');
      _image = await file.writeAsBytes(buffer);
    } catch (e) {
      print("Error in _saveToFile: $e");
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

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('HTP 검사를 종료하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MyApp()),
                      (Route<dynamic> route) => false,
                );
              },
              child: Text('종료'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _diagnose() async {
    if (_drawingId != null) {
      try {
        var response = await ApiService.diagnoseDrawing(_drawingId!);
        setState(() {
          _result = response['result'];
        });
      } catch (e) {
        print(e);
      }
    } else {
      print('No drawing to diagnose.');
    }
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
                  child: RepaintBoundary(
                    key: _globalKey,  // 수정된 부분
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 200),
                          color: Colors.white,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                RenderBox renderBox = context.findRenderObject() as RenderBox;
                                _points.add(DrawingPoints(
                                  points: renderBox.globalToLocal(details.localPosition),
                                  paint: Paint()
                                    ..color = _isErasing ? Colors.white : _color
                                    ..strokeCap = StrokeCap.round
                                    ..isAntiAlias = true
                                    ..strokeWidth = _isErasing ? _eraserSize : _brushSize,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text("Eraser Size: "),
                                  Slider(
                                    value: _eraserSize,
                                    min: 1.0,
                                    max: 20.0,
                                    onChanged: (value) {
                                      _changeEraserSize(value);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.brush),
                                    onPressed: _enableEraser,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Pen: "),
                                  IconButton(
                                    icon: Icon(Icons.create),
                                    onPressed: () {
                                      setState(() {
                                        _isErasing = false;
                                      });
                                    },
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
                                onPressed: _confirmCancel,
                                child: Text('취소'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _nextStep,
                                child: Text('다음'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
        canvas.drawPoints(ui.PointMode.points, [pointsList[i].points], pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;

  DrawingPoints({required this.points, required this.paint});
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
