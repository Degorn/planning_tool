import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:planning_tool/algorithm/algorithm.dart';

class TaskEditing extends StatefulWidget {
  const TaskEditing({
    Key? key,
    required this.availableTasks,
    required this.onSave,
    this.task,
  }) : super(key: key);

  final List<Task> availableTasks;
  final void Function(Task) onSave;
  final Task? task;

  @override
  State<TaskEditing> createState() => _TaskEditingState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<Task>('availableTasks', availableTasks))
      ..add(DiagnosticsProperty<Task?>('task', task))
      ..add(ObjectFlagProperty<void Function(Task p1)>.has('onSave', onSave));
  }
}

class _TaskEditingState extends State<TaskEditing> {
  var _availableTasksToDependOn = <Task>[];
  final _taskNameController = TextEditingController();
  final _taskDurationController = TextEditingController();
  final _dependeciesSuggestController = TextEditingController();

  var _taskDependsOn = <Task>[];

  @override
  void initState() {
    super.initState();
    _availableTasksToDependOn = widget.availableTasks.toList();
    if (widget.task != null) {
      _taskNameController.text = widget.task!.name;
      _taskDurationController.text = widget.task!.complexity.toString();
      _taskDependsOn = widget.task!.dependencies.toList();
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskDurationController.dispose();
    _dependeciesSuggestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextBox(
                controller: _taskNameController,
                placeholder: 'Title',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextBox(
                controller: _taskDurationController,
                placeholder: 'Complexity',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AutoSuggestBox(
          placeholder: 'Add dependency',
          controller: _dependeciesSuggestController,
          items: _availableTasksToDependOn.map((e) => e.name).toList(),
          onSelected: (text) {
            setState(() {
              final task = _availableTasksToDependOn.firstWhere((e) => e.name == text);
              _taskDependsOn.add(task);
              _availableTasksToDependOn.remove(task);
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _dependeciesSuggestController.clear();
            });
          },
        ),
        const SizedBox(height: 4),
        ChipTheme(
          data: ChipThemeData(
            decoration: ButtonState.resolveWith((states) {
              return BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: material.Colors.white24,
              );
            }),
          ),
          child: Wrap(
            spacing: 4,
            children: _taskDependsOn.map(
              (task) {
                return Chip(
                  text: Row(
                    children: [
                      Text(task.name),
                      Tooltip(
                        message: 'Unlink',
                        child: IconButton(
                          icon: const Icon(
                            FluentIcons.remove_link,
                            color: material.Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              _taskDependsOn.remove(task);
                              _availableTasksToDependOn
                                ..add(task)
                                ..sort((a, b) => a.name.compareTo(b.name));
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {},
                );
              },
            ).toList(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 128,
          child: Button(
            child: const Text('Save'),
            onPressed: () {
              widget.onSave(Task(
                name: _taskNameController.text,
                complexity: double.tryParse(_taskDurationController.text) ?? 0,
                dependencies: _taskDependsOn.toList(),
              ));
              setState(() {
                _taskNameController.clear();
                _taskDurationController.clear();
                _taskDependsOn.clear();
              });
            },
          ),
        ),
      ],
    );
  }
}
