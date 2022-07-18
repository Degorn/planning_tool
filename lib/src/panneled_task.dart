import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:planning_tool/algorithm/algorithm.dart';
import 'package:planning_tool/src/task_editing.dart';

class PanneledTask extends StatefulWidget {
  const PanneledTask({
    Key? key,
    required this.availableTasks,
    required this.task,
    required this.onSave,
    required this.onDelete,
    required this.onEnter,
    required this.onExit,
  }) : super(key: key);

  final List<Task> availableTasks;
  final Task task;
  final void Function(Task) onSave;
  final void Function() onDelete;
  final void Function() onEnter;
  final void Function() onExit;

  @override
  State<PanneledTask> createState() => _PanneledTaskState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<Task>('availableTasks', availableTasks))
      ..add(ObjectFlagProperty<void Function()>.has('onExit', onExit))
      ..add(ObjectFlagProperty<void Function()>.has('onEnter', onEnter))
      ..add(ObjectFlagProperty<void Function()>.has('onDelete', onDelete))
      ..add(ObjectFlagProperty<void Function(Task p1)>.has('onSave', onSave))
      ..add(DiagnosticsProperty<Task>('task', task));
  }
}

class _PanneledTaskState extends State<PanneledTask> {
  var _isEditing = false;
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.task.name;
    final subtitle = widget.task.complexity.toString();
    final dependencies = widget.task.dependencies.map((e) => e.name);

    return MouseRegion(
      onEnter: (pointerEnterEvent) {
        widget.onEnter();
      },
      onExit: (pointerExitEvent) {
        widget.onExit();
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isEditing = true;
            _isHovered = false;
          });
        },
        child: _isEditing
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TaskEditing(
                    availableTasks: widget.availableTasks,
                    task: widget.task,
                    onSave: (task) {
                      widget.onSave(task);
                      setState(() {
                        _isEditing = false;
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  Button(
                    child: const Text('Cancel'),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                    },
                  )
                ],
              )
            : MouseRegion(
                onEnter: (pointerEnterEvent) {
                  setState(() {
                    _isHovered = true;
                  });
                },
                onExit: (pointerExitEvent) {
                  setState(() {
                    _isHovered = false;
                  });
                },
                child: ListTile(
                  title: Text('$title - $subtitle'),
                  tileColor: _isHovered ? material.Colors.grey[700] : null,
                  subtitle: dependencies.isEmpty ? null : Text(dependencies.toString()),
                  trailing: IconButton(
                    icon: const Icon(
                      FluentIcons.delete,
                      color: material.Colors.redAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        widget.onDelete();
                      });
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
