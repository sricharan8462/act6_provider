import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  setupWindow();
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: const MyApp(),
    ),
  );
}

const double windowWidth = 360;
const double windowHeight = 640;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Provider Counter');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      if (screen != null) {
        setWindowFrame(
          Rect.fromCenter(
            center: screen.frame.center,
            width: windowWidth,
            height: windowHeight,
          ),
        );
      }
    });
  }
}

class Counter with ChangeNotifier {
  int value = 0;

  void increment() {
    // Prevent the counter from exceeding 99.
    if (value < 99) {
      value++;
      notifyListeners();
    }
  }

  void decrement() {
    if (value > 0) {
      value--;
      notifyListeners();
    }
  }

  void setValue(int newValue) {
    value = newValue;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Age Milestone Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  /// Returns a milestone message and background color based on the current age.
  Map<String, dynamic> _ageMilestone(int age) {
    if (age <= 12) {
      return {'message': "You're a child!", 'color': Colors.lightBlueAccent};
    } else if (age <= 19) {
      return {'message': "Teenager time!", 'color': Colors.lightGreenAccent};
    } else if (age <= 30) {
      return {'message': "You're a young adult!", 'color': Colors.yellowAccent};
    } else if (age <= 50) {
      return {'message': "You're an adult now!", 'color': Colors.orangeAccent};
    } else {
      return {'message': "Golden years!", 'color': Colors.grey};
    }
  }

  /// Returns a color for the progress bar based on age segments.
  Color _progressBarColor(int age) {
    if (age < 33) {
      return Colors.green;
    } else if (age < 67) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Counter>(
      builder: (context, counter, child) {
        final milestone = _ageMilestone(counter.value);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Age Milestone App'),
          ),
          // Set the background color based on the current milestone.
          backgroundColor: milestone['color'],
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Age: ${counter.value}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  milestone['message'],
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 30),
                // Slider to adjust the age between 0 and 99.
                Slider(
                  value: counter.value.toDouble(),
                  min: 0,
                  max: 99,
                  divisions: 99,
                  label: counter.value.toString(),
                  onChanged: (double newValue) {
                    counter.setValue(newValue.toInt());
                  },
                ),
                const SizedBox(height: 20),
                // Progress bar that visualizes the age segments.
                LinearProgressIndicator(
                  value: counter.value / 99,
                  minHeight: 10,
                  color: _progressBarColor(counter.value),
                  backgroundColor: Colors.black12,
                ),
              ],
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () => context.read<Counter>().decrement(),
                tooltip: 'Decrement',
                child: const Icon(Icons.remove),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                onPressed: () => context.read<Counter>().increment(),
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }
}
