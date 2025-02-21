import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultimate Flutter Performance Test',
      showPerformanceOverlay: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PerformanceStressTestPage(),
    );
  }
}

class PerformanceStressTestPage extends StatefulWidget {
  @override
  _PerformanceStressTestPageState createState() =>
      _PerformanceStressTestPageState();
}

class _PerformanceStressTestPageState extends State<PerformanceStressTestPage>
    with TickerProviderStateMixin {

  late AnimationController _globalAnimationController;
  late AnimationController _rotationController;
  late Animation<double> _globalScaleAnim;
  late Animation<double> _globalOpacityAnim;


  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  final List<Map<String, dynamic>> _dynamicItems = [];
  final math.Random _random = math.Random();

  static const int _gridItemsPerRow = 4;
  static const int _initialItemCount = 500;
  static const double _maxBlurRadius = 20.0;

  @override
  void initState() {
    super.initState();

    _populateItems(_initialItemCount);

    _globalAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _globalScaleAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _globalAnimationController,
        curve: Curves.easeInOutQuad,
      ),
    );

    _globalOpacityAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _globalAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _verticalScrollController.addListener(_handleScroll);
  }

  void _populateItems(int count) {
    for (var i = 0; i < count; i++) {
      _dynamicItems.add({
        'color': Color((0xFFFFFFFF & _random.nextInt(0xFFFFFFFF))),
        'height': 80.0 + _random.nextDouble() * 120,
        'rotation': _random.nextDouble() * 2 * math.pi,
        'blur': _random.nextDouble() * _maxBlurRadius,
      });
    }
  }

  void _handleScroll() {
    if (_verticalScrollController.position.pixels >
        _verticalScrollController.position.maxScrollExtent - 200) {
      setState(() => _populateItems(100));
    }
  }

  @override
  void dispose() {
    _globalAnimationController.dispose();
    _rotationController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Widget _buildPerformanceKillerItem(BuildContext context, int index) {
    final item = _dynamicItems[index];
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _globalAnimationController,
        _rotationController,
      ]),
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..scale(_globalScaleAnim.value)
            ..rotateZ(_rotationController.value),
          alignment: Alignment.center,
          child: Opacity(
            opacity: _globalOpacityAnim.value,
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: item['color'],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: item['blur'],
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: _WavePainter(
                      progress: _globalAnimationController.value,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        10,
                        (subIndex) => Container(
                          width: 120,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.accents[subIndex % Colors.accents.length],
                                Colors.accents[(subIndex + 5) % Colors.accents.length],
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Item ${index}_$subIndex',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ultimate Performance Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _populateItems(100)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.deepPurple, Colors.black],
            center: Alignment.topLeft,
            radius: 2.0,
          ),
        ),
        child: CustomScrollView(
          controller: _verticalScrollController,
          slivers: [
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gridItemsPerRow,
                childAspectRatio: 0.8,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPerformanceKillerItem(context, index),
                childCount: _dynamicItems.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {}),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    final waveHeight = size.height * 0.2;
    final xOffset = progress * size.width * 2;

    path.moveTo(0, size.height / 2);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          math.sin((x + xOffset) * math.pi / 180) * waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}