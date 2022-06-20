import 'package:flutter_app/models/priority.dart';

class Tasks {
  static final tblTask = "Tasks";
  static final dbId = "id";
  static final dbTitle = "title";
  static final dbComment = "comment";
  static final dbDueDate = "dueDate";
  //REI
  static final dbFromTime = "fromTime";
  static final dbToTime = "toTime";
  static final dbUseTool = "useTool";
  static final dbPriority = "priority";
  static final dbStatus = "status";
  static final dbProjectID = "projectId";

  String title, comment;
  String? projectName;
  int? id, projectColor;
  int dueDate, projectId;
  //REI
  int fromTime, toTime;
  int useTool;

  Status priority;
  TaskStatus? tasksStatus;
  List<String> labelList = [];

  Tasks.create({
    required this.title,
    required this.projectId,
    this.comment = "",
    this.dueDate = -1,
    this.fromTime = -1,
    this.toTime = -1,
    this.useTool = 0,
    this.priority = Status.PRIORITY_4,
  }) {
    if (this.dueDate == -1) {
      this.dueDate = DateTime.now().millisecondsSinceEpoch;
    }
    if (this.fromTime == -1) {
      this.fromTime = DateTime.now().millisecondsSinceEpoch;
    }

    if (this.toTime == -1) {
      this.toTime = DateTime.now().millisecondsSinceEpoch;
    }
    this.tasksStatus = TaskStatus.PENDING;
  }

  bool operator ==(o) => o is Tasks && o.id == id;

  Tasks.update({
    required this.id,
    required this.title,
    required this.projectId,
    this.comment = "",
    this.dueDate = -1,
    this.fromTime = -1,
    this.toTime = -1,
    this.useTool = 0,
    this.priority = Status.PRIORITY_4,
    this.tasksStatus = TaskStatus.PENDING,
  }) {
    if (this.dueDate == -1) {
      this.dueDate = DateTime.now().millisecondsSinceEpoch;
    }

    if (this.fromTime == -1) {
      this.fromTime = DateTime.now().millisecondsSinceEpoch;
    }

    if (this.toTime == -1) {
      this.toTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Tasks.fromMap(Map<String, dynamic> map)
      : this.update(
          id: map[dbId],
          title: map[dbTitle],
          projectId: map[dbProjectID],
          comment: map[dbComment],
          dueDate: map[dbDueDate],
          fromTime: map[dbFromTime],
          toTime: map[dbToTime],
          useTool: map[dbUseTool],
          priority: Status.values[map[dbPriority]],
          tasksStatus: TaskStatus.values[map[dbStatus]],
        );
}

enum TaskStatus {
  PENDING,
  COMPLETE,
}
