part of gamemodel;

class Ant extends Piece {
  Ant._internal(player, bugCount) : super._internal(player, Bug.ANT, bugCount);

  List<Move> moves(GameState gamestate) {
    return SlideMoveFinder.findMoves(this, gamestate);
  }
}

class Beetle extends Piece {
  Beetle._internal(player, bugCount) : super._internal(player, Bug.BEETLE, bugCount);

  List<Move> moves(GameState gamestate) {
    var moves = [];

    int height = gamestate.getHeight(this);
    if (height == 1) {
      moves.addAll(RangedSlideMoveFinder.findMoves(1, this, gamestate));
      moves.addAll(ClimbHiveMoveFinder.findMoves(this, gamestate));
    } else {
      moves.addAll(DismountHiveMoveFinder.findMoves(this, gamestate));
      moves.addAll(AtopHiveMoveFinder.findMoves(this, gamestate));
    }
    return moves;
  }
}

class Grasshopper extends Piece {
  Grasshopper._internal(player, bugCount) : super._internal(player, Bug.GRASSHOPPER, bugCount);

  List<Move> moves(GameState gamestate) {
    return JumpMoveFinder.findMoves(this, gamestate);
  }
}

class Queen extends Piece {
  Queen._internal(player, bugCount) : super._internal(player, Bug.QUEEN, bugCount);

  List<Move> moves(GameState gamestate) {
    return RangedSlideMoveFinder.findMoves(1, this, gamestate);
  }
}

class Spider extends Piece {
  Spider._internal(player, bugCount) : super._internal(player, Bug.SPIDER, bugCount);

  List<Move> moves(GameState gamestate) {
    return RangedSlideMoveFinder.findMoves(3, this, gamestate);
  }
}

class Mosquito extends Piece {
  Mosquito._internal(player, bugCount) : super._internal(player, Bug.MOSQUITO, bugCount);

  List<Move> moves(GameState gamestate) {
    return [];
  }
}
