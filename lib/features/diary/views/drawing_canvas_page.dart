import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class DrawingCanvasPage extends StatefulWidget {
  const DrawingCanvasPage({super.key});

  @override
  State<DrawingCanvasPage> createState() => _DrawingCanvasPageState();
}

class _DrawingCanvasPageState extends State<DrawingCanvasPage> {
  final GlobalKey _repaintKey = GlobalKey();

  final List<_Stroke> _strokes = [];
  final List<_Stroke> _redo = [];
  Color _currentColor = Colors.black;
  double _currentWidth = 4.0;
  bool _isEraser = false;
  bool _showColorPalette = false;
  bool _showBrushSizes = false;

  _Stroke? _active;

  // 더 다양한 색상 팔레트
  final List<Color> _colorPalette = [
    Colors.black,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  // 브러시 크기 옵션
  final List<double> _brushSizes = [2.0, 4.0, 6.0, 8.0, 12.0, 16.0, 20.0, 24.0];

  Future<String?> _exportToImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (_) {
      return null;
    }
  }

  void _startStroke(Offset pos) {
    _active = _Stroke(
      color: _isEraser ? const Color(0xFFF7F7F7) : _currentColor, 
      width: _isEraser ? _currentWidth * 2 : _currentWidth, // 지우개는 2배 크기로
      points: [pos]
    );
    _redo.clear();
    setState(() {
      _strokes.add(_active!);
    });
  }

  void _extendStroke(Offset pos) {
    if (_active == null) return;
    setState(() {
      _active!.points.add(pos);
    });
  }

  void _endStroke() {
    _active = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그림 그리기'),
        actions: [
          IconButton(
            onPressed: () async {
              final path = await _exportToImage();
              if (!mounted) return;
              Navigator.pop(context, path);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Column(
        children: [
          // 그림 캔버스
          Expanded(
            child: Container(
              color: const Color(0xFFF7F7F7),
              child: GestureDetector(
                onPanStart: (d) => _startStroke(d.localPosition),
                onPanUpdate: (d) => _extendStroke(d.localPosition),
                onPanEnd: (_) => _endStroke(),
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: CustomPaint(
                    painter: _CanvasPainter(strokes: _strokes),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          
          // 색상 팔레트 (도구 바 위에 표시)
          if (_showColorPalette) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('색상 선택:', style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _showColorPalette = false;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorPalette.map((color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentColor = color;
                          _isEraser = false;
                          _showColorPalette = false;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentColor == color ? Colors.black : Colors.grey,
                            width: _currentColor == color ? 3 : 1,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
          
          // 브러시 크기 선택 (도구 바 위에 표시)
          if (_showBrushSizes) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('브러시 크기:', style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _showBrushSizes = false;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _brushSizes.map((size) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentWidth = size;
                          _showBrushSizes = false;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _currentWidth == size ? Colors.blue : Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentWidth == size ? Colors.blue : Colors.grey,
                            width: _currentWidth == size ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: size / 2,
                            height: size / 2,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
          
          // 하단 도구 바 (고정)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 왼쪽 도구들
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: _strokes.isNotEmpty
                        ? () {
                            setState(() {
                              _redo.add(_strokes.removeLast());
                            });
                          }
                        : null,
                    tooltip: '실행 취소',
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo),
                    onPressed: _redo.isNotEmpty
                        ? () {
                            setState(() {
                              _strokes.add(_redo.removeLast());
                            });
                          }
                        : null,
                    tooltip: '다시 실행',
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _strokes.clear();
                        _redo.clear();
                      });
                    },
                    tooltip: '모두 지우기',
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // 오른쪽 도구들
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: !_isEraser ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEraser = false;
                      });
                    },
                    tooltip: '그림펜',
                  ),
                  
                  IconButton(
                    icon: Icon(
                      Icons.auto_fix_normal,
                      color: _isEraser ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEraser = true;
                      });
                    },
                    tooltip: '지우개',
                  ),
                  
                  // 색상 선택 버튼
                  IconButton(
                    icon: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _currentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _showColorPalette = !_showColorPalette;
                        _showBrushSizes = false;
                      });
                    },
                    tooltip: '색상 선택',
                  ),
                  
                  // 브러시 크기 버튼
                  IconButton(
                    icon: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: _currentWidth / 2,
                          height: _currentWidth / 2,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _showBrushSizes = !_showBrushSizes;
                        _showColorPalette = false;
                      });
                    },
                    tooltip: '브러시 크기',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}

class _Stroke {
  final Color color;
  final double width;
  final List<Offset> points;
  _Stroke({required this.color, required this.width, required this.points});
}

class _CanvasPainter extends CustomPainter {
  final List<_Stroke> strokes;
  _CanvasPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s.width
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < s.points.length - 1; i++) {
        canvas.drawLine(s.points[i], s.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) => true;
}


