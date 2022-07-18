import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

void main() {
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

  const algorithm = Algorithm(
    maxConcurrency: 3,
  );

  algorithm.run(
    tasks: [task1, task2, task3, task4, task5, task6, task7],
    // ignore: avoid_print
  ).forEach(print);
}

@immutable
class Task {
  final String name;
  final double complexity;
  final Iterable<Task> dependencies;

  const Task({
    required this.name,
    required this.complexity,
    this.dependencies = const [],
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Task &&
            runtimeType == other.runtimeType &&
            name == other.name &&
            complexity == other.complexity;
  }

  @override
  String toString() {
    return 'Task{name: $name}';
  }

  @override
  int get hashCode {
    return name.hashCode ^ complexity.hashCode;
  }
}

class LoadoutTask<T> {
  final Task task;
  final double taskStart;

  const LoadoutTask({
    required this.task,
    required this.taskStart,
  });

  @override
  String toString() {
    return '$taskStart @ $task';
  }
}

class Loadout {
  final List<LoadoutTask> tasks;

  Loadout({
    required this.tasks,
  });

  @override
  String toString() {
    return 'Loadout(${tasks.join(', ')}, complexity: $currentComplexity)';
  }

  double get currentComplexity => tasks.fold(0, (sum, task) => sum + task.task.complexity);

  void addTask(LoadoutTask task) {
    tasks.add(task);
  }
}

class Algorithm {
  final List<Task> tasks;
  final bool allowAutoConcurrency;
  final int maxConcurrency;

  const Algorithm({
    this.tasks = const [],
    this.allowAutoConcurrency = true,
    this.maxConcurrency = 2,
  });

  // If not force concurenty then use !currentStreamsHaveSpace(result, task)

  Iterable<Loadout> run({
    required List<Task> tasks,
  }) {
    final cyclicDependencies = checkForCyclicDependencies(tasks);
    assert(
      cyclicDependencies == null,
      () {
        final taskNames = cyclicDependencies.keys.map((e) => e.name);
        return 'Cyclic dependencies found: ${taskNames.join(' -> ')} -> ${taskNames.first}';
      }(),
    );

    final loadouts = <Loadout>[];

    final tasksToResolve = <Task>[];

    for (final task in tasks) {
      if (task.dependencies.isNotEmpty) {
        tasksToResolve.add(task);
      }

      // Check if we can fit a task with dependencies into the current loadout.
      for (final taskToResolve in tasksToResolve.toList()) {
        if (dependentTasksResolved(loadouts, taskToResolve.dependencies)) {
          tasksToResolve.remove(taskToResolve);
          tryToFitTask(loadouts, taskToResolve);
        }
      }

      if (task.dependencies.isEmpty) {
        tryToFitTask(loadouts, task);
      }
    }

    for (final taskToResolve in tasksToResolve) {
      fitTaskToResolve(taskToResolve, loadouts);
    }

    return loadouts;
  }

  void fitTaskToResolve(Task taskToResolve, List<Loadout> loadouts) {
    final dependencyMap = {for (var e in taskToResolve.dependencies) e: false};
    for (final loadout in loadouts) {
      for (final dependencyEntry in dependencyMap.entries.where((element) => !element.value)) {
        final dependency = dependencyEntry.key;
        if (loadout.tasks.any((lt) => lt.task == dependency)) {
          dependencyMap[dependency] = true;

          if (dependencyMap.values.every((e) => e)) {
            fitTheTask(loadouts, taskToResolve);
            return;
          }
        }
      }
    }
  }

  void fitTheTask(List<Loadout> loadouts, Task task) {
    final dependencies = task.dependencies;

    var maxDesiredComplexity = 0.0;
    for (final loadout in loadouts) {
      for (final dependency in dependencies) {
        final dependencyTask = loadout.tasks.firstWhereOrNull((lt) => lt.task == dependency);
        if (dependencyTask == null) {
          continue;
        }
        maxDesiredComplexity =
            math.max(maxDesiredComplexity, dependencyTask.taskStart + dependency.complexity);
      }
    }
    // Find loadouts that have a complexity greater or equal to the max desired complexity.
    final loadoutsWithComplexity = loadouts.where((loadout) {
      final loadoutComplexity = loadout.currentComplexity;
      return loadoutComplexity >= maxDesiredComplexity;
    });
    // Find the loadout with the lowest complexity.
    final loadout =
        loadoutsWithComplexity.reduce((a, b) => a.currentComplexity < b.currentComplexity ? a : b);
    // Add the task to the loadout.
    loadout.addTask(LoadoutTask(task: task, taskStart: loadout.currentComplexity));
  }

  void tryToFitTask(List<Loadout> loadouts, Task task) {
    if (canCreateNewStream(loadouts.length)) {
      loadouts.add(
        Loadout(
          tasks: [
            LoadoutTask(
              task: task,
              taskStart: 0,
            ),
          ],
        ),
      );
    } else {
      final minimumLoadout = findMinimumLoadout(loadouts);

      minimumLoadout.addTask(
        LoadoutTask(
          task: task,
          taskStart: minimumLoadout.currentComplexity,
        ),
      );
    }
  }

  bool canCreateNewStream(int currentLoadouts) {
    return currentLoadouts < maxConcurrency;
  }

  bool currentStreamsHaveSpace(List<Loadout> currentLoadouts, Task newTask) {
    var minComplexity = double.infinity;
    var maxComplexity = 0.0;

    for (final loadout in currentLoadouts) {
      minComplexity = math.min(minComplexity, loadout.currentComplexity);
      maxComplexity = math.max(maxComplexity, loadout.currentComplexity);

      if (minComplexity + newTask.complexity <= maxComplexity) {
        return true;
      }
    }

    return false;
  }

  Loadout findMinimumLoadout(List<Loadout> currentLoadouts) {
    var minComplexity = double.infinity;
    var minLoadout = currentLoadouts.first;

    for (final loadout in currentLoadouts) {
      minComplexity = math.min(minComplexity, loadout.currentComplexity);
      if (loadout.currentComplexity == minComplexity) {
        minLoadout = loadout;
      }
    }

    return minLoadout;
  }

  bool dependentTasksResolved(List<Loadout> loadouts, Iterable<Task> dependencies) {
    final dependencyMap = {for (var e in dependencies) e: false};

    // var minComplexity = double.infinity;
    // var maxComplexity = 0.0;

    for (final loadout in loadouts) {
      for (final dependency in dependencyMap.keys) {
        // minComplexity = math.min(minComplexity, loadout.currentComplexity);
        // maxComplexity = math.max(maxComplexity, loadout.currentComplexity);

        if (loadout.tasks.any((lt) => lt.task == dependency)) {
          // if (minComplexity + dependency.complexity <= maxComplexity) {
          //   dependencyMap[dependency] = true;
          // }

          // if (currentStreamsHaveSpace(loadouts, dependency)) {
          //   dependencyMap[dependency] = true;
          // }

          // Also need to check the complexity of tasks
          // dependencyMap[dependency] = true;
        }
      }
    }

    return dependencyMap.values.every((e) => e);
  }

  Map<Task, bool>? checkForCyclicDependencies(List<Task> tasks) {
    final taskMap = <Task, Iterable<Task>>{};
    for (final task in tasks) {
      taskMap[task] = task.dependencies;
    }
    final visited = <Task, bool>{};
    final stack = <Task, bool>{};
    for (final task in tasks) {
      if (visited.containsKey(task)) {
        continue;
      }
      if (hasCycle(task, taskMap, visited, stack) != null) {
        return stack;
      }
    }
    return null;
  }

  Map<Task, bool>? hasCycle(
    Task task,
    Map<Task, Iterable<Task>> taskMap,
    Map<Task, bool> visited,
    Map<Task, bool> stack,
  ) {
    if (stack.containsKey(task)) {
      return stack;
    }
    if (visited.containsKey(task)) {
      return null;
    }
    visited[task] = true;
    stack[task] = true;
    if (!taskMap.containsKey(task)) {
      return null;
    }
    for (final dependency in taskMap[task]!) {
      if (hasCycle(dependency, taskMap, visited, stack) != null) {
        return stack;
      }
    }
    stack.remove(task);
    return null;
  }
}
