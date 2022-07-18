import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:planning_tool/algorithm/algorithm.dart';
import 'package:planning_tool/src/panneled_task.dart';
import 'package:planning_tool/src/task_editing.dart';

class TasksPanel extends StatefulWidget {
  const TasksPanel({
    Key? key,
    required this.onCalculate,
    required this.onTaskEnter,
    required this.onTaskExit,
  }) : super(key: key);

  final void Function(List<Task> tasks) onCalculate;
  final void Function(Task task) onTaskEnter;
  final void Function(Task task) onTaskExit;

  @override
  State<TasksPanel> createState() => _TasksPanelState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<void Function(List<Task> tasks)>.has('onCalculate', onCalculate))
      ..add(ObjectFlagProperty<void Function(Task task)>.has('onTaskExit', onTaskExit))
      ..add(ObjectFlagProperty<void Function(Task task)>.has('onTaskEnter', onTaskEnter));
  }
}

class _TasksPanelState extends State<TasksPanel> {
  final _tasks = <Task>[];

  @override
  void initState() {
    super.initState();
    const task1 = Task(
      name: 'Task 1',
      complexity: 1,
    );
    const task2 = Task(
      name: 'Task 2',
      complexity: 2,
    );
    const task3 = Task(
      name: 'Task 3',
      complexity: 1,
      dependencies: [task1, task2],
    );
    const task4 = Task(
      name: 'Task 4',
      complexity: 1,
    );
    const task5 = Task(
      name: 'Task 5',
      complexity: 2,
    );
    const task6 = Task(
      name: 'Task 6',
      complexity: 2,
    );
    const task7 = Task(
      name: 'Task 7',
      complexity: 1,
    );
    const task8 = Task(
      name: 'Task 8',
      complexity: 2,
      dependencies: [task2],
    );
    const task9 = Task(
      name: 'Task 9',
      complexity: 3,
      dependencies: [task8],
    );
    _tasks.addAll([task1, task2, task3, task4, task5, task6, task7, task8, task9]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TaskEditing(
          availableTasks: _tasks,
          onSave: _tasks.add,
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              return PanneledTask(
                availableTasks: _tasks,
                task: _tasks[index],
                onSave: (task) {
                  setState(() {
                    _tasks[index] = task;
                  });
                },
                onDelete: () {
                  _tasks.removeAt(index);
                },
                onEnter: () {
                  widget.onTaskEnter(_tasks[index]);
                },
                onExit: () {
                  widget.onTaskExit(_tasks[index]);
                },
              );
            },
          ),
        ),
        Button(
          child: const Text('Calculate'),
          onPressed: () => widget.onCalculate(_tasks),
        )
      ],
    );
  }
}
