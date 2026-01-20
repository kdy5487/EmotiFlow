import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 그림 그리기 페이지 (개선 버전)
/// - 감정 스티커 추가
/// - 도형 도구 추가
/// - 자동 저장 기능
class DrawingCanvasPage extends StatefulWidget {
  const DrawingCanvasPage({super.key});

  @override
  State<DrawingCanvasPage> createState() => _DrawingCanvasPageState();
}

enum DrawingTool { pen, eraser, circle, heart, star }

class _DrawingCanvasPageState extends State<DrawingCanvasPage> {
  final GlobalKey _repaintKey = GlobalKey();

  final List<DrawingElement> _elements = [];
  final List<DrawingElement> _redo = [];
  Color _currentColor = Colors.black;
  double _currentWidth = 4.0;
  DrawingTool _currentTool = DrawingTool.pen;
  bool _showColorPalette = false;
  bool _showBrushSizes = false;
  bool _showStickers = false;

  Offset? _shapeStart;
  DrawingElement? _activeElement;

  // 색상 팔레트
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

  // 감정 스티커
  final List<String> _emotionStickers = [
    '😊',
    '😢',
    '😡',
    '😱',
    '😍',
    '🤗',
    '😴',
    '🤔',
    '😎',
    '🥳',
    '❤️',
    '💔',
    '⭐',
    '✨',
    '🌈',
  ];

  @override
  void initState() {
    super.initState();
    _loadAutoSave();
  }

  @override
  void dispose() {
    _autoSave();
    super.dispose();
  }

  /// 자동 저장
  Future<void> _autoSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _elements.map((e) => e.toJson()).toList();
      await prefs.setString('temp_drawing', jsonEncode(data));
      print('✅ 자동 저장 완료');
    } catch (e) {
      print('⚠️ 자동 저장 실패: $e');
    }
  }

  /// 자동 저장 불러오기
  Future<void> _loadAutoSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('temp_drawing');
      if (savedData != null && savedData.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(savedData);
        setState(() {
          _elements.addAll(
            jsonList.map((json) => DrawingElement.fromJson(json)).toList(),
          );
        });
        print('✅ 자동 저장 복구 완료 (${_elements.length}개 요소)');
      }
    } catch (e) {
      print('⚠️ 자동 저장 복구 실패: $e');
    }
  }

  /// PNG 내보내기
  Future<String?> _exportToImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // 자동 저장 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('temp_drawing');

      return file.path;
    } catch (_) {
      return null;
    }
  }

  void _onPanStart(Offset pos) {
    if (_currentTool == DrawingTool.pen || _currentTool == DrawingTool.eraser) {
      _activeElement = StrokeElement(
        color: _currentTool == DrawingTool.eraser
            ? const Color(0xFFF7F7F7)
            : _currentColor,
        width: _currentTool == DrawingTool.eraser
            ? _currentWidth * 2
            : _currentWidth,
        points: [pos],
      );
      _redo.clear();
      setState(() {
        _elements.add(_activeElement!);
      });
    } else {
      // 도형 도구
      _shapeStart = pos;
    }
  }

  void _onPanUpdate(Offset pos) {
    if (_currentTool == DrawingTool.pen || _currentTool == DrawingTool.eraser) {
      if (_activeElement is StrokeElement) {
        setState(() {
          (_activeElement as StrokeElement).points.add(pos);
        });
      }
    } else if (_shapeStart != null) {
      // 도형 미리보기 업데이트
      setState(() {
        // 기존 임시 도형 제거
        if (_elements.isNotEmpty && _elements.last is ShapeElement) {
          final last = _elements.last as ShapeElement;
          if (!last.isFinalized) {
            _elements.removeLast();
          }
        }

        // 새 임시 도형 추가
        _elements.add(ShapeElement(
          type: _currentTool,
          color: _currentColor,
          start: _shapeStart!,
          end: pos,
          isFinalized: false,
        ));
      });
    }
  }

  void _onPanEnd() {
    if (_currentTool == DrawingTool.pen || _currentTool == DrawingTool.eraser) {
      _activeElement = null;
    } else if (_shapeStart != null) {
      // 도형 확정
      if (_elements.isNotEmpty && _elements.last is ShapeElement) {
        setState(() {
          (_elements.last as ShapeElement).isFinalized = true;
        });
      }
      _shapeStart = null;
    }
    _autoSave(); // 자동 저장
  }

  void _undo() {
    if (_elements.isEmpty) return;
    setState(() {
      _redo.add(_elements.removeLast());
    });
    _autoSave();
  }

  void _redoAction() {
    if (_redo.isEmpty) return;
    setState(() {
      _elements.add(_redo.removeLast());
    });
    _autoSave();
  }

  /// 마지막 요소 삭제 (NEW!)
  void _deleteLast() {
    if (_elements.isEmpty) return;
    setState(() {
      _elements.removeLast();
      _redo.clear();
    });
    _autoSave();
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 지우기'),
        content: const Text('그림을 모두 지우시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _elements.clear();
                _redo.clear();
              });
              _autoSave();
              Navigator.pop(context);
            },
            child: const Text('지우기', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addSticker(String emoji) {
    setState(() {
      _elements.add(StickerElement(
        emoji: emoji,
        position: Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 3,
        ),
      ));
      _showStickers = false;
    });
    _autoSave();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_elements.isEmpty) {
          // 빈 화면이면 임시 저장 삭제하고 나가기
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('temp_drawing');
          return true;
        }

        // 뒤로가기 시 저장 여부 선택
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('그림 저장'),
            content: const Text('작성중인 그림을 어떻게 하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false); // 저장 안함
                },
                child: const Text(
                  '저장 안함',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true); // 임시 저장
                },
                child: const Text('임시 저장'),
              ),
            ],
          ),
        );

        if (result == null) {
          // 다이얼로그 취소 (뒤로가기 안 함)
          return false;
        } else if (result == true) {
          // 임시 저장 후 나가기
          await _autoSave();
          return true;
        } else {
          // 저장 안함 (임시 저장 삭제 후 나가기)
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('temp_drawing');
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('그림 그리기'),
          actions: [
            IconButton(
              onPressed: _elements.isEmpty ? null : _clearAll,
              icon: const Icon(Icons.delete_forever),
              color: Colors.red,
              tooltip: '전체 지우기',
            ),
            IconButton(
              onPressed: () async {
                final path = await _exportToImage();
                if (!mounted) return;
                Navigator.pop(context, path != null ? File(path) : null);
              },
              icon: const Icon(Icons.check),
              tooltip: '완료',
            ),
          ],
        ),
        body: Column(
          children: [
            // 캔버스
            Expanded(
              child: Container(
                color: const Color(0xFFF7F7F7),
                child: GestureDetector(
                  onPanStart: (d) => _onPanStart(d.localPosition),
                  onPanUpdate: (d) => _onPanUpdate(d.localPosition),
                  onPanEnd: (_) => _onPanEnd(),
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: CustomPaint(
                      painter: _CanvasPainter(elements: _elements),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),

            // 색상 팔레트
            if (_showColorPalette) _buildColorPalette(),

            // 브러시 크기
            if (_showBrushSizes) _buildBrushSizes(),

            // 감정 스티커 (NEW!)
            if (_showStickers) _buildStickerPalette(),

            // 하단 도구 바
            _buildToolBar(),
          ],
        ),
      ),
    );
  }

  /// 색상 팔레트
  Widget _buildColorPalette() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('색상 선택:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showColorPalette = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorPalette
                .map((color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentColor = color;
                          _currentTool = DrawingTool.pen;
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
                            color: _currentColor == color
                                ? Colors.black
                                : Colors.grey,
                            width: _currentColor == color ? 3 : 1,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 브러시 크기
  Widget _buildBrushSizes() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('브러시 크기:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showBrushSizes = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _brushSizes
                .map((size) => GestureDetector(
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
                          color: _currentWidth == size
                              ? Colors.blue
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentWidth == size
                                ? Colors.blue
                                : Colors.grey,
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
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 감정 스티커 팔레트 (NEW!)
  Widget _buildStickerPalette() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('감정 스티커:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showStickers = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _emotionStickers
                .map((emoji) => GestureDetector(
                      onTap: () => _addSticker(emoji),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 하단 도구 바 (중요도 순 배치 + 가로 스크롤)
  Widget _buildToolBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== 고중요도: 기본 도구 =====
            // 펜
            IconButton(
              onPressed: () => setState(() => _currentTool = DrawingTool.pen),
              icon: const Icon(Icons.edit),
              color:
                  _currentTool == DrawingTool.pen ? Colors.blue : Colors.grey,
              tooltip: '펜',
            ),
            // 지우개 (탭=지우개 메뉴, 길게 누르기=전체 지우기)
            GestureDetector(
              onTap: () => _showEraserMenu(),
              onLongPress: () {
                if (_elements.isNotEmpty) _clearAll();
              },
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  Icons.auto_fix_high,
                  color: _currentTool == DrawingTool.eraser
                      ? Colors.blue
                      : Colors.grey,
                ),
              ),
            ),
            // 색상
            IconButton(
              onPressed: () {
                setState(() {
                  _showColorPalette = !_showColorPalette;
                  _showBrushSizes = false;
                  _showStickers = false;
                });
              },
              icon: Icon(Icons.palette, color: _currentColor),
              tooltip: '색상',
            ),
            // 브러시 크기
            IconButton(
              onPressed: () {
                setState(() {
                  _showBrushSizes = !_showBrushSizes;
                  _showColorPalette = false;
                  _showStickers = false;
                });
              },
              icon: const Icon(Icons.brush),
              tooltip: '브러시 크기',
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            // 실행 취소
            IconButton(
              onPressed: _elements.isEmpty ? null : _undo,
              icon: const Icon(Icons.undo),
              tooltip: '실행 취소',
            ),
            // 다시 실행
            IconButton(
              onPressed: _redo.isEmpty ? null : _redoAction,
              icon: const Icon(Icons.redo),
              tooltip: '다시 실행',
            ),
            // 마지막 삭제
            IconButton(
              onPressed: _elements.isEmpty ? null : _deleteLast,
              icon: const Icon(Icons.backspace),
              color: Colors.orange,
              tooltip: '마지막 삭제',
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            // ===== 저중요도: 도형 + 스티커 =====
            // 원
            IconButton(
              onPressed: () =>
                  setState(() => _currentTool = DrawingTool.circle),
              icon: Icon(
                Icons.circle_outlined,
                color: _currentTool == DrawingTool.circle
                    ? Colors.blue
                    : Colors.grey,
              ),
              tooltip: '원',
            ),
            // 하트
            IconButton(
              onPressed: () => setState(() => _currentTool = DrawingTool.heart),
              icon: Icon(
                Icons.favorite_border,
                color: _currentTool == DrawingTool.heart
                    ? Colors.blue
                    : Colors.grey,
              ),
              tooltip: '하트',
            ),
            // 별
            IconButton(
              onPressed: () => setState(() => _currentTool = DrawingTool.star),
              icon: Icon(
                Icons.star_border,
                color: _currentTool == DrawingTool.star
                    ? Colors.blue
                    : Colors.grey,
              ),
              tooltip: '별',
            ),
            // 스티커
            IconButton(
              onPressed: () {
                setState(() {
                  _showStickers = !_showStickers;
                  _showColorPalette = false;
                  _showBrushSizes = false;
                });
              },
              icon: const Text('😊', style: TextStyle(fontSize: 20)),
              tooltip: '스티커',
            ),
          ],
        ),
      ),
    );
  }

  /// 지우개 메뉴 (크기 선택)
  void _showEraserMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '지우개 크기 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEraserSizeButton('작게', 10.0),
                _buildEraserSizeButton('보통', 20.0),
                _buildEraserSizeButton('크게', 40.0),
                _buildEraserSizeButton('매우 크게', 80.0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 지우개 크기 버튼
  Widget _buildEraserSizeButton(String label, double size) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTool = DrawingTool.eraser;
          _currentWidth = size / 2; // 지우개는 2배로 적용되므로 /2
        });
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Container(
                width: size.clamp(8.0, 40.0),
                height: size.clamp(8.0, 40.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ============ 그리기 요소 추상 클래스 ============

abstract class DrawingElement {
  Map<String, dynamic> toJson();
  void paint(Canvas canvas, Size size);

  factory DrawingElement.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'stroke':
        return StrokeElement.fromJson(json);
      case 'shape':
        return ShapeElement.fromJson(json);
      case 'sticker':
        return StickerElement.fromJson(json);
      default:
        throw Exception('Unknown element type: $type');
    }
  }
}

// ============ 펜 스트로크 ============

class StrokeElement implements DrawingElement {
  final Color color;
  final double width;
  final List<Offset> points;

  StrokeElement({
    required this.color,
    required this.width,
    required this.points,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'stroke',
        'color': color.value,
        'width': width,
        'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      };

  factory StrokeElement.fromJson(Map<String, dynamic> json) {
    return StrokeElement(
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
      points: (json['points'] as List)
          .map((p) => Offset(
                (p['x'] as num).toDouble(),
                (p['y'] as num).toDouble(),
              ))
          .toList(),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }
}

// ============ 도형 (원, 하트, 별) ============

class ShapeElement implements DrawingElement {
  final DrawingTool type;
  final Color color;
  final Offset start;
  final Offset end;
  bool isFinalized;

  ShapeElement({
    required this.type,
    required this.color,
    required this.start,
    required this.end,
    this.isFinalized = true,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'shape',
        'shapeType': type.toString(),
        'color': color.value,
        'start': {'x': start.dx, 'y': start.dy},
        'end': {'x': end.dx, 'y': end.dy},
      };

  factory ShapeElement.fromJson(Map<String, dynamic> json) {
    final shapeTypeStr = json['shapeType'] as String;
    final shapeType = DrawingTool.values.firstWhere(
      (e) => e.toString() == shapeTypeStr,
      orElse: () => DrawingTool.circle,
    );

    return ShapeElement(
      type: shapeType,
      color: Color(json['color'] as int),
      start: Offset(
        (json['start']['x'] as num).toDouble(),
        (json['start']['y'] as num).toDouble(),
      ),
      end: Offset(
        (json['end']['x'] as num).toDouble(),
        (json['end']['y'] as num).toDouble(),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    switch (type) {
      case DrawingTool.circle:
        final center = Offset(
          (start.dx + end.dx) / 2,
          (start.dy + end.dy) / 2,
        );
        final radius = (end - start).distance / 2;
        canvas.drawCircle(center, radius, paint);
        break;

      case DrawingTool.heart:
        _drawHeart(canvas, paint);
        break;

      case DrawingTool.star:
        _drawStar(canvas, paint);
        break;

      default:
        break;
    }
  }

  void _drawHeart(Canvas canvas, Paint paint) {
    final path = Path();
    final center = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
    final width = (end.dx - start.dx).abs();
    final height = (end.dy - start.dy).abs();

    path.moveTo(center.dx, center.dy + height / 4);
    path.cubicTo(
      center.dx - width / 2,
      center.dy - height / 3,
      center.dx - width / 4,
      center.dy - height / 2,
      center.dx,
      center.dy - height / 6,
    );
    path.cubicTo(
      center.dx + width / 4,
      center.dy - height / 2,
      center.dx + width / 2,
      center.dy - height / 3,
      center.dx,
      center.dy + height / 4,
    );
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Paint paint) {
    final path = Path();
    final center = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
    final radius = (end - start).distance / 2;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final x = center.dx + radius * (i % 2 == 0 ? 1.0 : 0.5) * math.cos(angle);
      final y = center.dy + radius * (i % 2 == 0 ? 1.0 : 0.5) * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

// ============ 스티커 (감정 이모지) ============

class StickerElement implements DrawingElement {
  final String emoji;
  final Offset position;

  StickerElement({
    required this.emoji,
    required this.position,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'sticker',
        'emoji': emoji,
        'position': {'x': position.dx, 'y': position.dy},
      };

  factory StickerElement.fromJson(Map<String, dynamic> json) {
    return StickerElement(
      emoji: json['emoji'] as String,
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(fontSize: 40),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }
}

// ============ 캔버스 페인터 ============

class _CanvasPainter extends CustomPainter {
  final List<DrawingElement> elements;

  _CanvasPainter({required this.elements});

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in elements) {
      element.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return true; // ✅ 항상 다시 그려서 실시간 표시
  }
}
