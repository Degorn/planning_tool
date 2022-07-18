import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:planning_tool/algorithm/algorithm.dart';
import 'package:planning_tool/src/loadout_panel.dart';
import 'package:planning_tool/src/tasks_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Planning tool',
      theme: ThemeData(
        brightness: Brightness.dark,
        focusTheme: const FocusThemeData(
          glowFactor: 4,
        ),
      ),
      home: const Align(
        alignment: Alignment.topCenter,
        child: Mica(
          child: Home(),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final algorithm = const Algorithm(
    maxConcurrency: 4,
  );

  var _loadouts = <Loadout>[];

  Task? _hoveredTask;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TasksPanel(
              onCalculate: (tasks) {
                setState(() {
                  _loadouts = algorithm.run(tasks: tasks).toList();
                });
              },
              onTaskEnter: (task) {
                setState(() {
                  _hoveredTask = task;
                });
              },
              onTaskExit: (task) {
                setState(() {
                  _hoveredTask = null;
                });
              },
            ),
          ),
        ),
        const material.VerticalDivider(
          color: Colors.grey,
          indent: 12,
          endIndent: 12,
        ),
        if (_loadouts.isNotEmpty)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: LoadoutPanel(
                loadouts: _loadouts,
                hoveredTask: _hoveredTask,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Algorithm>('algorithm', algorithm));
  }
}
