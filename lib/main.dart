import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(SnakeGameApp());

class SnakeGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SnakeGame(),
    );
  }
}

enum Direction { up, down, left, right }

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  static const double cellSize = 20.0;

  late Direction _direction;
  late List<Offset> _snake;
  late Offset _food;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _direction = Direction.right;
    _snake = [Offset(5, 5)];
    _food = _generateFood();
    _timer = Timer.periodic(Duration(milliseconds: 200), _updateSnake);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Offset _generateFood() {
    final random = Random();
    return Offset(
      random.nextInt(gridSize).toDouble(),
      random.nextInt(gridSize).toDouble(),
    );
  }

  void _updateSnake(Timer timer) {
    setState(() {
      final head = _snake.last;
      Offset next;
      switch (_direction) {
        case Direction.up:
          next = Offset(head.dx, head.dy - 1);
          break;
        case Direction.down:
          next = Offset(head.dx, head.dy + 1);
          break;
        case Direction.left:
          next = Offset(head.dx - 1, head.dy);
          break;
        case Direction.right:
          next = Offset(head.dx + 1, head.dy);
          break;
      }

      if (next.dx < 0 ||
          next.dx >= gridSize ||
          next.dy < 0 ||
          next.dy >= gridSize ||
          _snake.contains(next)) {
        _timer.cancel();
        return;
      }

      _snake.add(next);
      if (next == _food) {
        _food = _generateFood();
      } else {
        _snake.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (_direction != Direction.up && details.delta.dy > 0) {
                _direction = Direction.down;
              } else if (_direction != Direction.down && details.delta.dy < 0) {
                _direction = Direction.up;
              }
            },
            onHorizontalDragUpdate: (details) {
              if (_direction != Direction.left && details.delta.dx > 0) {
                _direction = Direction.right;
              } else if (_direction != Direction.right && details.delta.dx < 0) {
                _direction = Direction.left;
              }
            },
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                final x = index % gridSize;
                final y = index ~/ gridSize;
                final offset = Offset(x.toDouble(), y.toDouble());
                if (_snake.contains(offset)) {
                  return _buildSnakeCell();
                } else if (offset == _food) {
                  return _buildFoodCell();
                } else {
                  return _buildEmptyCell();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnakeCell() {
    return Container(
      margin: EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFoodCell() {
    return Container(
      margin: EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Container(
      margin: EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
    );
  }
}
