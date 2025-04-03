import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../core/models/tile.dart';
import '../core/theme/colors.dart';
import '../service/app_service.dart';

class Game2048 extends StatefulWidget {
  const Game2048({super.key});

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> with SingleTickerProviderStateMixin {

  late AnimationController animationController;
  late AppService appService;
  List<List<Tile>> grid = List.generate(4, (y) => List.generate(4, (x) => Tile(x: x, y: y, val: 0)));
  List<Tile> toAdd = [];
  Iterable<Tile> get smoothedGrid => grid.expand((e) => e);
  Iterable<List<Tile>> get columns => List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        for (var element in toAdd) {
          grid[element.y][element.x].val = element.val;
        }
        for (var e in smoothedGrid) {
          e.resetAnimation();
        }
        toAdd.clear();
      }
    });
    resetGame();
  }
  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width - 16.0 * 2;
    double tileSize = (gridSize - 4.0 * 2) / 4;
    List<Widget> stackThings = [];

    stackThings.addAll(
      smoothedGrid.map(
            (e) => Positioned(
          left: e.x * tileSize,
          top: e.y * tileSize,
          width: tileSize,
          height: tileSize,
          child: Center(
            child: Container(
              width: tileSize - 4.0 * 2,
              height: tileSize - 4.0 * 2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.brown.shade100),
            ),
          ),
        ),
      ),
    );
    stackThings.addAll(
      smoothedGrid.map(
            (e) => AnimatedBuilder(
          animation: animationController,
          builder: (context, child) => e.animatedVal.value == 0
              ? SizedBox()
              : Positioned(
            left: e.animatedX.value * tileSize,
            top: e.animatedY.value * tileSize,
            width: tileSize,
            height: tileSize,
            child: Center(
              child: Container(
                width: (tileSize - 4.0 * 2) * e.scale.value,
                height: (tileSize - 4.0 * 2) * e.scale.value,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColors.numButtonColor[e.animatedVal.value],
                ),
                child: Center(
                  child: Text(
                    "${e.animatedVal.value}",
                    style: TextStyle(
                        color: e.animatedVal.value <= 4
                            ? Colors.grey
                            : AppColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: (){
              setState(() {
                resetGame();
              });
            },
            icon: Icon(Icons.restart_alt, color: Colors.black),
          )
        ],
      ),
      body: Center(
        child: Container(
          width: gridSize,
          height: gridSize,
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.brown.shade200,
          ),
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy < -250 && canSwipeUp()) {
                /// swipe Up
                doSwipe(swipeUp);
              } else if (details.velocity.pixelsPerSecond.dy > 250 && canSwipeDown()) {
                /// swipe down
                doSwipe(swipeDown);
              }
            },
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx < -1000 && canSwipeLeft()) {
                /// swipe Left
                doSwipe(swipeLeft);
              } else if (details.velocity.pixelsPerSecond.dx > 1000 &&
                  canSwipeRight()) {
                /// swipe Right
                doSwipe(swipeRight);
              }
            },
            child: Stack(
              children: stackThings,
            ),
          ),
        ),
      ),
    );
  }

  void resetGame(){
    grid = List.generate(4, (y) => List.generate(4, (x) => Tile(x: x, y: y, val: 0)));
    grid[1][1].val = 4;
    grid[0][1].val = 16;
    grid[0][0].val = 16;
    grid[1][0].val = 4;

    for (var e in smoothedGrid) {
      e.resetAnimation();
    }

    setState(() {});
  }
  void addNewTile() {
    List<Tile> empty = smoothedGrid.where((e) => e.val == 0).toList();
    empty.shuffle();
    toAdd.add(
      Tile(x: empty.first.x, y: empty.first.y, val: 2)
        ..appear(animationController),
    );
  }

  void doSwipe(void Function() swipeFn) {
    setState(() {
      swipeFn();
      addNewTile();
      animationController.forward(from: 0);
    });
  }

  bool canSwipeLeft() => grid.any(canSwipe);
  bool canSwipeRight() => grid.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipeUp() => columns.any(canSwipe);
  bool canSwipeDown() => columns.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipe(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i].val == 0) {
        if (tiles.skip(i + 1).any((e) => e.val != 0)) {
          return true;
        }
      } else {
        Tile? nextNonZero =
            tiles.skip(i + 1).where((e) => e.val != 0).firstOrNull;
        if (nextNonZero != null && nextNonZero.val == tiles[i].val) {
          return true;
        }
      }
    }
    return false;
  }

  void swipeLeft() => grid.forEach(mergeTiles);
  void swipeRight() => grid.map((e) => e.reversed.toList()).forEach(mergeTiles);

  void swipeUp() => columns.forEach(mergeTiles);
  void swipeDown() =>
      columns.map((e) => e.reversed.toList()).forEach(mergeTiles);

  void mergeTiles(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      Iterable<Tile> toCheck =
      tiles.skip(i).skipWhile((value) => value.val == 0);

      if (toCheck.isNotEmpty) {
        Tile t = toCheck.first;
        Tile? merge = toCheck.skip(1).firstWhereOrNull((t) => t.val != 0);
        if (merge != null && merge.val != t.val) {
          merge = null;
        }
        if (tiles[i] != t || merge != null) {
          int resultValue = t.val;
          t.moveTo(animationController, tiles[i].x, tiles[i].y);
          if (merge != null) {
            resultValue += merge.val;
            merge.moveTo(animationController, tiles[i].x, tiles[i].y);
            merge.bounce(animationController);
            merge.changeNumber(animationController, resultValue);
            merge.val = 0;

            t.changeNumber(animationController, 0);
          }
          t.val = 0;
          tiles[i].val = resultValue;
        }
      }
    }
  }
}