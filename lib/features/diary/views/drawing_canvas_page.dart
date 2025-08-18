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

  _Stroke? _active;

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
    _active = _Stroke(color: _currentColor, width: _currentWidth, points: [pos]);
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
          Expanded(
            child: Container(
              color: const Color(0xFFF7F7F7), // 연회색 배경으로 선명하게
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: _strokes.isNotEmpty
                      ? () {
                          setState(() {
                            _redo.add(_strokes.removeLast());
                          });
                        }
                      : null,
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
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _strokes.clear();
                      _redo.clear();
                    });
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: '펜(검정)',
                  onPressed: () {
                    _currentColor = Colors.black;
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.color_lens),
                  tooltip: '색상 변경',
                  onPressed: () {
                    final colors = [Colors.black, Colors.red, Colors.blue, Colors.green, Colors.orange];
                    _currentColor = colors[(colors.indexOf(_currentColor) + 1) % colors.length];
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.brush),
                  tooltip: '두께 변경',
                  onPressed: () {
                    _currentWidth = _currentWidth + 2;
                    if (_currentWidth > 16) _currentWidth = 4;
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.auto_fix_normal),
                  tooltip: '지우개',
                  onPressed: () {
                    // 배경색으로 그려서 지우개처럼
                    _currentColor = const Color(0xFFF7F7F7);
                    setState(() {});
                  },
                ),
              ],
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
    // 배경은 부모 컨테이너 색상으로 채워짐
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


