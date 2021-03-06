part of hive_console_test;

class TestMoveFinder {
  static void run() {
    group('Move Finder:', () {
      group('Jump Finder:', _jumpFinder);
      group('Ranged Slide Finder:', _rangedSlideFinder);
      group('Slide Finder:', _slideFinder);
      group('Climb Hive Finder:', _climbHiveFinder);
      group('Dismount Hive Finder:', _dismountHiveFinder);
      group('Atop Hive Finder:', _atopHiveFinder);
    });
  }

  static void _jumpFinder() {
    test('one piece jumps', () {
      var _bG_ = new Piece(Player.BLACK, Bug.GRASSHOPPER, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', '  ', '  ', '  ', '  ' ],
          [ '  ', 'bA', 'bA', '  ', '  ' ],
        [ '  ', 'bA', _bG_, 'bA', '  ' ],
          [ '  ', 'bA', 'bA', '  ', '  ' ],
        [ '  ', '  ', '  ', '  ', '  ' ]
      ]);
      gamestate.stepToEnd();
      var piece = _bG_;
      var moves = JumpMoveFinder.findMoves(piece, gamestate);
      var initialCoordinate = new Coordinate(2, 2);
      var expected_moves = [
        new Move(_bG_, initialCoordinate, new Coordinate(0, 1)),
        new Move(_bG_, initialCoordinate, new Coordinate(0, 3)),
        new Move(_bG_, initialCoordinate, new Coordinate(2, 0)),
        new Move(_bG_, initialCoordinate, new Coordinate(2, 4)),
        new Move(_bG_, initialCoordinate, new Coordinate(4, 1)),
        new Move(_bG_, initialCoordinate, new Coordinate(4, 3))
      ];

      expect(moves.toSet(), equals(expected_moves.toSet()));
    });

    // may need to re-write this one after One Hive is added to findMoves
    test('can\'t jump without adjacent pieces', () {
      var _bG_ = new Piece(Player.BLACK, Bug.GRASSHOPPER, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'bA', '  ', 'bA', '  ' ],
          [ '  ', '  ', '  ', '  ', '  ' ],
        [ 'bA', '  ', _bG_, '  ', 'bA' ],
          [ '  ', '  ', '  ', '  ', '  ' ],
        [ '  ', 'bA', '  ', 'bA', '  ' ]
      ]);
      gamestate.stepToEnd();

      var piece = _bG_;
      var moves = JumpMoveFinder.findMoves(piece, gamestate);
      expect(moves.isEmpty, isTrue);
    });

    group('jump respects one hive rule', () {
      test('basic hive split', () {
        var _bG_ = new Piece(Player.BLACK, Bug.GRASSHOPPER, 1);
        var gamestate = GameStateTestHelper.build([
          [ '  ', 'bA', _bG_, 'bA', '  ' ]
        ]);
        gamestate.stepToEnd();

        var piece = _bG_;
        var moves = JumpMoveFinder.findMoves(piece, gamestate);
        expect(moves.isEmpty, isTrue);
      });

      test('hive only splits during the jump', () {
        var _bG_ = new Piece(Player.BLACK, Bug.GRASSHOPPER, 1);

        // wA gets isolated during jump into __
        var gamestate = GameStateTestHelper.build([
          [ '  ', 'bA', '__', '  ' ],
            [ 'bA', '  ', 'wA', '  ' ],
          [ '  ', 'bA', '  ', _bG_ ],
            [ '  ', 'bA', 'bA', '  ' ]
        ]);
        gamestate.stepToEnd();

        var piece = _bG_;
        var moves = JumpMoveFinder.findMoves(piece, gamestate);
        expect(moves.firstWhere((move) => move.targetLocation == new Coordinate(0, 2), orElse: () => null), isNull);
      });
    });
  }

  static void _rangedSlideFinder() {
    test('slide once around a single piece', () {
      var _bQ_ = new Piece(Player.BLACK, Bug.QUEEN, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', '  ' ],
          [ 'bA', _bQ_ ],
        [ '  ', '  ' ]
      ]);
      gamestate.stepToEnd();

      var piece = _bQ_;
      var moves = RangedSlideMoveFinder.findMoves(1, piece, gamestate);
      var moveCoordinates = [
        new Coordinate(2, 1),
        new Coordinate(0, 1)
      ];

      expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });

    test('slide twice around a single piece', () {
      var _bQ_ = new Piece(Player.BLACK, Bug.QUEEN, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', '  ', '  ' ],
          [ '  ', 'bA', _bQ_ ],
        [ '  ', '  ', '  ' ]
      ]);
      gamestate.stepToEnd();

      var piece = _bQ_;
      var moves = RangedSlideMoveFinder.findMoves(2, piece, gamestate);
      var moveCoordinates = [
        new Coordinate(2, 1),
        new Coordinate(0, 1)
      ];

      expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });

    test('slide respects one hive rule', () {
      var _bQ_ = new Piece(Player.BLACK, Bug.QUEEN, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', '  ', '  ' ],
          [ 'bA', _bQ_, 'bA' ],
        [ '  ', '  ', '  ' ]
      ]);
      gamestate.stepToEnd();

      var piece = _bQ_;
      var moves = RangedSlideMoveFinder.findMoves(1, piece, gamestate);
      expect(moves.isEmpty, isTrue);
    });

    test('spider edge case can reach adjacent space', () {
      var _bS_ = new Piece(Player.BLACK, Bug.QUEEN, 1);
      // spider can land in both adjacent __ by moving away initially
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'bA', 'bA', '  '],
          [ 'bA', '__', 'bA', '  ' ],
        [ '  ', _bS_, '  ', 'bA' ],
          [ 'bA', '__', 'bA', '  ' ],
        [ '  ', 'bA', 'bA', '  ' ]
      ]);
      gamestate.stepToEnd();

      var piece = _bS_;
      var moves = RangedSlideMoveFinder.findMoves(3, piece, gamestate);
      var moveCoordinates = [
        new Coordinate(3, 1),
        new Coordinate(1, 1)
      ];

      expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });

    test('slide respects freedom of movement', () {
      var _bA_ = new Piece(Player.WHITE, Bug.ANT, 1);
      // attempt to move through gate into __
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'wG', 'wG', 'wG' ],
          [ 'wG', '__', _bA_, 'wG' ],
        [ '  ', 'wG', 'wG', 'wG' ]
      ]);
      gamestate.stepToEnd();

      Piece piece = _bA_;
      var moves = RangedSlideMoveFinder.findMoves(1, piece, gamestate);
      expect(moves.isEmpty, isTrue);
    });

    test('respect freedom of movement mid-slide', () {
      var _bA_ = new Piece(Player.WHITE, Bug.ANT, 1);
      // attempt to move through gate into __
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'wG', 'wG', 'wG', 'wG' ],
          [ 'wG', '__', '  ', _bA_, 'wG' ],
        [ '  ', 'wG', 'wG', '  ', 'wG' ],
          [ '  ', '  ', 'wG', 'wG', '  ' ],
      ]);
      gamestate.stepToEnd();

      Piece piece = _bA_;
      var moves = RangedSlideMoveFinder.findMoves(2, piece, gamestate);

      // the two adjacents are ok
      var moveCoordinates = [
        new Coordinate(2, 3),
        new Coordinate(1, 2)
      ];

      expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });

    test('slide respects constant contact', () {
      var _bA_ = new Piece(Player.WHITE, Bug.ANT, 1);
      // attempt to move into __ without constant contact
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'wG', 'wG' ],
          [ 'wG', '  ', 'wG' ],
        [ '  ', '__', _bA_ ]
      ]);
      gamestate.stepToEnd();
      Piece piece = _bA_;
      var moves = RangedSlideMoveFinder.findMoves(1, piece, gamestate);
      var moveCoordinates = [
        new Coordinate(1, 1),
        new Coordinate(2, 3)
      ];

      expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });
  }

  static void _climbHiveFinder() {
    test('climb onto neighboring pieces', () {
      var _wB_ = new Piece(Player.WHITE, Bug.BEETLE, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'wG' ],
          [ 'wG', _wB_ ]
      ]);
      gamestate.stepToEnd();

      Piece piece = _wB_;
      var moves = ClimbHiveMoveFinder.findMoves(piece, gamestate);
      var moveCoordinates = [
        new Coordinate(0, 1),
        new Coordinate(1, 0)
      ];

      expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });

    test('can\'t climb if already on hive', () {
      var _wB_ = new Piece(Player.WHITE, Bug.BEETLE, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'wG' ],
          [ '  ', _wB_ ]
      ]);
      gamestate.stepToEnd();

      Piece piece = _wB_;
      gamestate.appendMove(new Move(piece, new Coordinate(1, 1), new Coordinate(0, 1)));
      gamestate.stepToEnd();

      var moves = ClimbHiveMoveFinder.findMoves(piece, gamestate);
      expect(moves.isEmpty, isTrue);
    });
  }

  static void _dismountHiveFinder() {
    test('empty if not on hive', () {
      var _wB_ = new Piece(Player.WHITE, Bug.BEETLE, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'wG' ],
          [ '  ', _wB_ ]
      ]);
      gamestate.stepToEnd();

      Piece piece = _wB_;

      var moves = DismountHiveMoveFinder.findMoves(piece, gamestate);
      expect(moves.isEmpty, isTrue);
    });

    test('returns empty adjacent moves', () {
      var _wB_ = new Piece(Player.WHITE, Bug.BEETLE, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'wG', '__' ],
          [ 'wG', 'wG', '__' ],
        [ '  ', _wB_, 'wG' ]
      ]);
      gamestate.stepToEnd();

      Piece piece = _wB_;
      gamestate.appendMove(new Move(piece, new Coordinate(2, 1), new Coordinate(1, 1)));
      gamestate.stepToEnd();

      var moves = DismountHiveMoveFinder.findMoves(piece, gamestate);
      var moveCoordinates = [
        new Coordinate(0, 2),
        new Coordinate(1, 2),
        new Coordinate(2, 1),
      ];
      expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });
  }

  static void _atopHiveFinder() {
    test('move on top of adjacent pieces', () {
      var _wB_ = new Piece(Player.WHITE, Bug.BEETLE, 1);
      var gamestate = GameStateTestHelper.build([
        [ 'wG', '  ', 'wG' ],
          [ 'wG', '  ', '  ' ],
        [ _wB_, 'wG', '  ' ]
      ]);
      gamestate.stepToEnd();

      Piece piece = _wB_;
      gamestate.appendMove(new Move(piece, new Coordinate(2, 0), new Coordinate(1, 0)));
      gamestate.stepToEnd();

      var moves = AtopHiveMoveFinder.findMoves(piece, gamestate);
      var moveCoordinates = [
        new Coordinate(0, 0),
        new Coordinate(2, 1)
      ];
      expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });

    test('empty when not atop the hive', () {
      var _wB_ = new Piece(Player.WHITE, Bug.BEETLE, 1);
      var gamestate = GameStateTestHelper.build([
        [ 'wG', '  ', 'wG' ],
          [ 'wG', '  ', '  ' ],
        [ _wB_, 'wG', '  ' ]
      ]);
      gamestate.stepToEnd();

      Piece piece = _wB_;

      var moves = AtopHiveMoveFinder.findMoves(piece, gamestate);
      expect(moves.isEmpty, isTrue);
    });

    test('elevation is no obstacle', () {
      var _wB_ = new Piece(Player.WHITE, Bug.BEETLE, 1);
      var _bB_ = new Piece(Player.BLACK, Bug.BEETLE, 1);
      var gamestate = GameStateTestHelper.build([
        [ 'wG', _bB_, 'wG' ],
          [ 'wG', '  ', '  ' ],
        [ _wB_, 'wG', '  ' ]
      ]);
      gamestate.stepToEnd();

      Piece piece = _wB_;
      Piece otherBeetle = _bB_;
      gamestate.appendMove(new Move(piece, new Coordinate(2, 0), new Coordinate(1, 0)));
      gamestate.stepToEnd();
      gamestate.appendMove(new Move(otherBeetle, new Coordinate(0, 1), new Coordinate(0, 0)));
      gamestate.stepToEnd();

      var moves = AtopHiveMoveFinder.findMoves(piece, gamestate);
      var moveCoordinates = [
        new Coordinate(0, 0),
        new Coordinate(2, 1)
      ];
      expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });
  }

  static void _slideFinder() {
    test('respects one hive rule', () {
      var _wA_ = new Piece(Player.BLACK, Bug.ANT, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', '  ', 'bA' ],
          [ '__', _wA_, 'bA' ]
      ]);
      gamestate.stepToEnd();
      var piece = _wA_;
      var moves = SlideMoveFinder.findMoves(piece, gamestate);
      expect(moves.firstWhere((move) => move.targetLocation == new Coordinate(1, 0), orElse: () => null), isNull);
    });

    test('respects dangling piece one hive rule', () {
      var _wA_ = new Piece(Player.BLACK, Bug.ANT, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', '  ', 'bA', '  ' ],
          [ 'wG', '  ', _wA_, '  ' ],
        [ '  ', 'wG', '  ', 'wG' ],
          [ '  ', 'wG', 'wG', '  ' ]
      ]);
      gamestate.stepToEnd();
      var piece = _wA_;
      var moves = SlideMoveFinder.findMoves(piece, gamestate);
      expect(moves.isEmpty, isTrue);
    });
  }
}
