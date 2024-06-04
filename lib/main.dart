import 'package:flutter/material.dart';

void main() {
  runApp(const OthelloGame());
}

// OthelloGameアプリケーションのルートウィジェット
class OthelloGame extends StatelessWidget {
  const OthelloGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Othello Game', // タイトル
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OthelloBoard(), // ホーム画面
    );
  }
}

// Othelloのゲームボードを表示するウィジェット
class OthelloBoard extends StatefulWidget {
  const OthelloBoard({super.key});

  @override
  State<OthelloBoard> createState() => _OthelloBoardState();
}

// OthelloBoardの状態を管理するクラス
class _OthelloBoardState extends State<OthelloBoard> {
  static const int boardSize = 8; // ボードのサイズは8x8
  List<List<int>> board =
      List.generate(boardSize, (_) => List.filled(boardSize, 0)); // ボードの初期化
  int currentPlayer = 1; // 現在のプレイヤー（1が黒、2が白）

  @override
  void initState() {
    super.initState();
    _initializeBoard(); // ボードを初期化
  }

  // ボードの初期配置を設定
  void _initializeBoard() {
    board[3][3] = 1;
    board[4][4] = 1;
    board[3][4] = 2;
    board[4][3] = 2;
  }

  // セルをタップしたときの処理
  void _handleTap(int x, int y) {
    if (board[x][y] != 0) return; // すでに石が置かれている場合は何もしない
    List<List<int>> flips = _getFlips(x, y, currentPlayer); // 挟まれる石を取得
    if (flips.isNotEmpty) {
      setState(() {
        board[x][y] = currentPlayer; // 石を置く
        for (List<int> flip in flips) {
          board[flip[0]][flip[1]] = currentPlayer; // 挟まれた石をひっくり返す
        }
        currentPlayer = 3 - currentPlayer; // プレイヤーを交代
      });
    }
  }

  // 挟まれる石のリストを取得
  List<List<int>> _getFlips(int x, int y, int player) {
    List<List<int>> directions = [
      [0, 1], [1, 0], [0, -1], [-1, 0], // 水平方向と垂直方向
      [1, 1], [1, -1], [-1, 1], [-1, -1] // 斜め方向
    ];
    List<List<int>> flips = [];

    for (List<int> direction in directions) {
      List<List<int>> potentialFlips = [];
      int dx = direction[0];
      int dy = direction[1];
      int nx = x + dx;
      int ny = y + dy;

      while (nx >= 0 &&
          nx < boardSize &&
          ny >= 0 &&
          ny < boardSize &&
          board[nx][ny] == 3 - player) {
        potentialFlips.add([nx, ny]);
        nx += dx;
        ny += dy;
      }

      if (nx >= 0 &&
          nx < boardSize &&
          ny >= 0 &&
          ny < boardSize &&
          board[nx][ny] == player) {
        flips.addAll(potentialFlips);
      }
    }

    return flips;
  }

  // セルのウィジェットを構築
  Widget _buildCell(int x, int y) {
    return GestureDetector(
      onTap: () => _handleTap(x, y), // セルがタップされたときの処理
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green, // セルの背景色
          border: Border.all(color: Colors.black), // セルの境界線
        ),
        child: Center(
          child: _buildPiece(board[x][y]), // 石を配置
        ),
      ),
    );
  }

  // 石のウィジェットを構築
  Widget _buildPiece(int piece) {
    if (piece == 0) return const SizedBox.shrink(); // 石がない場合は空のウィジェットを返す
    return Container(
      decoration: BoxDecoration(
        color: piece == 1 ? Colors.black : Colors.white, // 石の色を設定
        shape: BoxShape.circle, // 石の形を丸に設定
      ),
      width: 80.0, // 石の幅
      height: 80.0, // 石の高さ
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Othello Game'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0, // 正方形のボードを保持
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: boardSize, // ボードの列数
            ),
            itemBuilder: (context, index) {
              int x = index ~/ boardSize;
              int y = index % boardSize;
              return _buildCell(x, y); // セルを構築
            },
            itemCount: boardSize * boardSize, // セルの総数
          ),
        ),
      ),
    );
  }
}
