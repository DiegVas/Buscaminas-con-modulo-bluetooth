// main.dart
import 'package:flutter/material.dart';
import 'package:proyect_orga/pages/TitleGameScreen.dart';

void main() {
  runApp(const MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Montserrat',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1B41),
      ),
      home: const TitleGameScreen(),
    );
  }
}

// Title Screen
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'MINESWEEPER',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/mine_icon.png',
                height: 120,
                width: 120,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.warning_rounded,
                    size: 120,
                    color: Colors.orange,
                  );
                },
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BluetoothConnectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Connect Bluetooth',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DifficultyScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Play Game',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bluetooth Connection Screen
class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  State<BluetoothConnectionScreen> createState() =>
      _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  bool _isSearching = false;
  final List<Map<String, dynamic>> _mockDevices = [
    {'name': 'Device 1', 'id': '00:11:22:33:44:55', 'connected': false},
    {'name': 'Device 2', 'id': '66:77:88:99:AA:BB', 'connected': false},
    {'name': 'Device 3', 'id': 'CC:DD:EE:FF:00:11', 'connected': false},
  ];

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });

    // Mock search completion after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _connectToDevice(int index) {
    final device = _mockDevices[index];

    final updatedDevices = [..._mockDevices];
    for (var i = 0; i < updatedDevices.length; i++) {
      updatedDevices[i]['connected'] = i == index;
    }

    setState(() {
      _mockDevices.clear();
      _mockDevices.addAll(updatedDevices);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connected to ${device['name']}'),
        backgroundColor: Colors.green,
      ),
    );

    // Automatically proceed to the game after successful connection
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DifficultyScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Connection'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.indigo.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Connect to a Bluetooth device',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isSearching ? null : _startSearch,
                      icon:
                          _isSearching
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.search),
                      label: Text(
                        _isSearching ? 'Searching...' : 'Search for Devices',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Devices',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _mockDevices.length,
                itemBuilder: (context, index) {
                  final device = _mockDevices[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.indigo.shade600,
                    child: ListTile(
                      leading: const Icon(Icons.bluetooth, color: Colors.white),
                      title: Text(device['name']),
                      subtitle: Text(device['id']),
                      trailing: ElevatedButton(
                        onPressed: () => _connectToDevice(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              device['connected'] ? Colors.green : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          device['connected'] ? 'Connected' : 'Connect',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Difficulty Selection Screen
class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Difficulty'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Difficulty',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildDifficultyButton(
              context,
              'Easy',
              Colors.green,
              2, // 2 mines for easy difficulty
            ),
            const SizedBox(height: 20),
            _buildDifficultyButton(
              context,
              'Medium',
              Colors.orange,
              4, // 4 mines for medium difficulty
            ),
            const SizedBox(height: 20),
            _buildDifficultyButton(
              context,
              'Hard',
              Colors.red,
              6, // 6 mines for hard difficulty
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String text,
    Color color,
    int mines,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameScreen(mines: mines)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        minimumSize: const Size(200, 60),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Game Screen
class GameScreen extends StatefulWidget {
  final int mines;

  const GameScreen({super.key, required this.mines});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Fixed board size of 4x4
  static const int rows = 4;
  static const int columns = 4;

  late List<List<int>> _board;
  late List<List<bool>> _revealed;
  late List<List<bool>> _flagged;
  bool _gameOver = false;
  bool _gameWon = false;
  int _remainingMines = 0;
  int _revealedCells = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Initialize the board, initially all cells are 0 (no mines)
    _board = List.generate(rows, (_) => List.filled(columns, 0));

    // Randomly place mines (1's)
    _placeMines();

    // Calculate adjacent mines for each cell
    _calculateAdjacentMines();

    // Track which cells are revealed
    _revealed = List.generate(rows, (_) => List.filled(columns, false));

    // Track which cells are flagged
    _flagged = List.generate(rows, (_) => List.filled(columns, false));

    _remainingMines = widget.mines;
    _revealedCells = 0;
  }

  void _placeMines() {
    final random = DateTime.now().millisecondsSinceEpoch;
    int minesPlaced = 0;

    // For demonstration, place mines predictably
    // In a real implementation, you'd use Random() for true randomness
    for (int i = 0; i < rows && minesPlaced < widget.mines; i++) {
      for (int j = 0; j < columns && minesPlaced < widget.mines; j++) {
        // Place a mine with some pattern based on indices
        if ((i + j) % 4 == (random % 4) && minesPlaced < widget.mines) {
          _board[i][j] = 1; // 1 represents a mine
          minesPlaced++;
        }
      }
    }

    // If not enough mines were placed with the pattern, place more until we reach the desired count
    if (minesPlaced < widget.mines) {
      for (int i = 0; i < rows && minesPlaced < widget.mines; i++) {
        for (int j = 0; j < columns && minesPlaced < widget.mines; j++) {
          if (_board[i][j] == 0) {
            _board[i][j] = 1;
            minesPlaced++;
          }
        }
      }
    }
  }

  void _calculateAdjacentMines() {
    // In a complete implementation, we would calculate how many mines are adjacent to each cell
    // For this demo, we'll leave this as a placeholder
  }

  void _revealCell(int row, int col) {
    if (_gameOver || _revealed[row][col] || _flagged[row][col]) {
      return;
    }

    setState(() {
      _revealed[row][col] = true;
      _revealedCells++;

      // Check if the player hit a mine
      if (_board[row][col] == 1) {
        _gameOver = true;
        _revealAllMines();
      }
      // Check if the player has won
      else if (_revealedCells == (rows * columns) - widget.mines) {
        _gameWon = true;
        _gameOver = true;
      }
    });
  }

  void _toggleFlag(int row, int col) {
    if (_gameOver || _revealed[row][col]) {
      return;
    }

    setState(() {
      _flagged[row][col] = !_flagged[row][col];
      if (_flagged[row][col]) {
        _remainingMines--;
      } else {
        _remainingMines++;
      }
    });
  }

  void _revealAllMines() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (_board[i][j] == 1) {
          _revealed[i][j] = true;
        }
      }
    }
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
      _gameOver = false;
      _gameWon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minesweeper'),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Mines: $_remainingMines',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Game Status
          if (_gameOver)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _gameWon ? 'You Win! 🎉' : 'Game Over! 💣',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _gameWon ? Colors.green : Colors.red,
                ),
              ),
            ),

          // Game Board
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: columns / rows, // Always 1 for a 4x4 grid
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade800,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                        ),
                    itemCount: rows * columns,
                    itemBuilder: (context, index) {
                      final row = index ~/ columns;
                      final col = index % columns;

                      return GestureDetector(
                        onTap: () => _revealCell(row, col),
                        onLongPress: () => _toggleFlag(row, col),
                        child: _buildCell(row, col),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Game Controls
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 32.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Tap to reveal • Long press to flag',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    Color backgroundColor;
    Widget child;

    if (_revealed[row][col]) {
      // Cell is revealed
      if (_board[row][col] == 1) {
        // It's a mine
        backgroundColor = Colors.red;
        child = const Icon(Icons.warning_amber_rounded, color: Colors.white);
      } else {
        // It's a safe cell
        backgroundColor = Colors.indigo.shade300;
        // Display a number (would be calculated based on adjacent mines)
        int adjacentCount = (row + col) % 8 + 1; // Mock value for demonstration
        child = Text(
          adjacentCount.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        );
      }
    } else if (_flagged[row][col]) {
      // Cell is flagged
      backgroundColor = Colors.indigo.shade500;
      child = const Icon(Icons.flag, color: Colors.red);
    } else {
      // Cell is unrevealed
      backgroundColor = Colors.indigo.shade600;
      child = const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(child: child),
    );
  }
}
