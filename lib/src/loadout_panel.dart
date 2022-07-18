import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:planning_tool/algorithm/algorithm.dart';

class LoadoutPanel extends StatefulWidget {
  const LoadoutPanel({
    Key? key,
    required this.loadouts,
    required this.hoveredTask,
  }) : super(key: key);

  final List<Loadout> loadouts;
  final Task? hoveredTask;

  @override
  State<LoadoutPanel> createState() => _LoadoutPanelState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<Loadout>('loadouts', loadouts))
      ..add(DiagnosticsProperty<Task?>('hoveredTask', hoveredTask));
  }
}

class _LoadoutPanelState extends State<LoadoutPanel> {
  var _columnsNumber = 0;
  var _columnWidths = <int, TableColumnWidth>{};

  @override
  void initState() {
    super.initState();
    fill();
  }

  @override
  void didUpdateWidget(LoadoutPanel oldWidget) {
    fill();
    super.didUpdateWidget(oldWidget);
  }

  void fill() {
    _columnsNumber = widget.loadouts.map((e) => e.currentComplexity).reduce(math.max).ceil();

    _columnWidths.clear();
    _columnWidths = {
      0: const FixedColumnWidth(80),
    };
    _columnWidths.addAll(
      {for (var i in List.generate(_columnsNumber, (i) => i + 1)) i: const FixedColumnWidth(60)},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      columnWidths: _columnWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            const Text(r'Devs\Sprints'),
            for (var i = 0; i < _columnsNumber; i++)
              Text(
                '${i + 1}',
                textAlign: TextAlign.center,
              ),
          ],
        ),
        ...widget.loadouts.mapIndexed(
          (loadIndex, loadout) {
            var lastTaskIndex = 0;

            return TableRow(
              children: [
                Text(
                  '${loadIndex + 1}',
                  textAlign: TextAlign.center,
                ),
                ...List.generate(
                  _columnsNumber,
                  (index) {
                    if (loadout.currentComplexity <= index) {
                      return Container(height: 32, color: material.Colors.black12);
                    }

                    final loadTask = loadout.tasks[lastTaskIndex];

                    if (loadTask.task.complexity == 1) {
                      lastTaskIndex++;
                      return Container(
                        height: 32,
                        color: widget.hoveredTask == loadTask.task
                            ? material.Colors.blue
                            : material.Colors.greenAccent,
                        child: Text(loadTask.task.name),
                      );
                    }

                    // Start of the task.
                    if (loadTask.taskStart == index) {
                      return Container(
                        height: 32,
                        color: widget.hoveredTask == loadTask.task
                            ? material.Colors.blue
                            : material.Colors.greenAccent,
                        child: Text(loadTask.task.name),
                      );
                    }

                    // End of the task.
                    if (loadTask.taskStart + loadTask.task.complexity == index + 1) {
                      lastTaskIndex++;
                      return Container(
                        height: 32,
                        color: widget.hoveredTask == loadTask.task
                            ? material.Colors.blue
                            : material.Colors.greenAccent.shade100,
                        child: Text(loadTask.task.name),
                      );
                    }

                    // Middle of the task.
                    return Container(
                      height: 32,
                      color: widget.hoveredTask == loadTask.task
                          ? material.Colors.blue
                          : material.Colors.greenAccent.shade100,
                      child: Text(loadTask.task.name),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
