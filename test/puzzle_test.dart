import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/models/puzzle.dart';

void main() {
  group('Puzzle', () {
    test('un tablero resuelto se detecta como resuelto', () {
      expect(Puzzle.solved(4).isSolved, isTrue);
    });

    test(
      'los tableros barajados siempre son resolubles y no vienen resueltos',
      () {
        final rng = Random(42);
        for (final size in [3, 4, 5]) {
          for (var i = 0; i < 200; i++) {
            final p = Puzzle.shuffled(size, random: rng);
            expect(Puzzle.isSolvable(p.tiles, size), isTrue);
            expect(p.isSolved, isFalse);
            expect(p.tiles.toSet().length, size * size);
          }
        }
      },
    );

    test('el 15-puzzle con 14 y 15 intercambiados NO es resoluble', () {
      final tiles = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 14, 0];
      expect(Puzzle.isSolvable(tiles, 4), isFalse);
    });

    test('solo se mueven piezas adyacentes al vacío', () {
      final p = Puzzle.solved(3); // vacío en índice 8
      expect(p.canMove(7), isTrue); // izquierda
      expect(p.canMove(5), isTrue); // arriba
      expect(p.canMove(4), isFalse); // diagonal
      expect(p.canMove(6), isFalse); // misma fila pero lejos

      expect(p.move(7), isTrue);
      expect(p.emptyIndex, 7);
      expect(p.tiles[8], 8);
      expect(p.isSolved, isFalse);
    });
  });
}
