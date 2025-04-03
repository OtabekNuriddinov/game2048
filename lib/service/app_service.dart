import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../core/models/tile.dart';


class AppService{

  late AnimationController animationController;
  late List<List<Tile>> grid;
  List<Tile> toAdd = [];

  AppService({required this.animationController}){
    resetGame();
  }

  void resetGame(){
   grid = List.generate(4, (y)=>List.generate(4, (x) => Tile(x: x, y: y, val: 0)));

   grid[1][1].val = 4;
   grid[0][1].val = 16;
   grid[0][0].val = 16;
   grid[1][0].val = 4;

   for(var e in smoothedGrid){
     e.resetAnimation();
   }
  }

  Iterable<Tile>get smoothedGrid => grid.expand((e)=>e);

  void addNewTile() {
    List<Tile> empty = smoothedGrid.where((e) => e.val == 0).toList();
    empty.shuffle();
    toAdd.add(
      Tile(x: empty.first.x, y: empty.first.y, val: 2)
        ..appear(animationController),
    );
  }


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

  bool canSwipeLeft() => grid.any(canSwipe);
  bool canSwipeRight() => grid.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipeUp() => List.generate(4, (x) => List.generate(4, (y) => grid[y][x])).any(canSwipe);
  bool canSwipeDown() => List.generate(4, (x) => List.generate(4, (y)=>grid[y][x]))
      .map((e)=>e.reversed.toList()).any(canSwipe);

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

  void swipeLeft() => grid.forEach(mergeTiles);
  void swipeRight() => grid.map((e) => e.reversed.toList()).forEach(mergeTiles);

  void swipeUp() =>List.generate(4, (x) => List.generate(4, (y) => grid[y][x])).forEach(mergeTiles);
  void swipeDown() => List.generate(4, (x) => List.generate(4, (y)=>grid[y][x])).map((e)=>e.reversed.toList()).forEach(mergeTiles);

}