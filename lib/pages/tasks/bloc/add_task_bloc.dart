import 'dart:async';
import 'dart:ffi';

import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class AddTaskBloc implements BlocBase {
  final TaskDB _taskDB;
  final ProjectDB _projectDB;
  final LabelDB _labelDB;
  Status lastPrioritySelection = Status.PRIORITY_4;

  AddTaskBloc(this._taskDB, this._projectDB, this._labelDB) {
    _loadProjects();
    _loadLabels();
    updateDueDate(DateTime.now().millisecondsSinceEpoch);
    updateFromTime(DateTime.now().millisecondsSinceEpoch);
    updateToTime(DateTime.now().millisecondsSinceEpoch);
    _projectSelection.add(Project.getInbox());
    _prioritySelected.add(lastPrioritySelection);
  }

  BehaviorSubject<List<Project>> _projectController =
      BehaviorSubject<List<Project>>();

  Stream<List<Project>> get projects => _projectController.stream;

  BehaviorSubject<List<Label>> _labelController =
      BehaviorSubject<List<Label>>();

  Stream<List<Label>> get labels => _labelController.stream;

  BehaviorSubject<Project> _projectSelection = BehaviorSubject<Project>();

  Stream<Project> get selectedProject => _projectSelection.stream;

  BehaviorSubject<String> _labelSelected = BehaviorSubject<String>();

  Stream<String> get labelSelection => _labelSelected.stream;

  List<Label> _selectedLabelList = [];

  List<Label> get selectedLabels => _selectedLabelList;

  BehaviorSubject<Status> _prioritySelected = BehaviorSubject<Status>();

  Stream<Status> get prioritySelected => _prioritySelected.stream;

  BehaviorSubject<int> _dueDateSelected = BehaviorSubject<int>();

  Stream<int> get dueDateSelected => _dueDateSelected.stream;

  //REI
  BehaviorSubject<int> _fromTimeSelected = BehaviorSubject<int>();

  Stream<int> get fromTimeSelected => _fromTimeSelected.stream;

  BehaviorSubject<int> _toTimeSelected = BehaviorSubject<int>();

  Stream<int> get toTimeSelected => _toTimeSelected.stream;

  String updateTitle = "";

  BehaviorSubject<int> _useToolSelected = BehaviorSubject<int>();
  Stream<int> get useToolSelected => _useToolSelected.stream;

  @override
  void dispose() {
    _projectController.close();
    _labelController.close();
    _projectSelection.close();
    _labelSelected.close();
    _prioritySelected.close();
    _dueDateSelected.close();
    _fromTimeSelected.close();
    _toTimeSelected.close();
  }

  void _loadProjects() {
    _projectDB.getProjects(isInboxVisible: true).then((projects) {
      _projectController.add(List.unmodifiable(projects));
    });
  }

  void _loadLabels() {
    _labelDB.getLabels().then((labels) {
      _labelController.add(List.unmodifiable(labels));
    });
  }

  void projectSelected(Project project) {
    _projectSelection.add(project);
  }

  void labelAddOrRemove(Label label) {
    if (_selectedLabelList.contains(label)) {
      _selectedLabelList.remove(label);
    } else {
      _selectedLabelList.add(label);
    }
    _buildLabelsString();
  }

  void _buildLabelsString() {
    List<String> selectedLabelNameList = [];
    _selectedLabelList.forEach((label) {
      selectedLabelNameList.add("@${label.name}");
    });
    String labelJoinString = selectedLabelNameList.join("  ");
    String displayLabels =
        labelJoinString.length == 0 ? "No Labels" : labelJoinString;
    _labelSelected.add(displayLabels);
  }

  void updatePriority(Status priority) {
    _prioritySelected.add(priority);
    lastPrioritySelection = priority;
  }

  Stream createTask() {
    return ZipStream.zip6(selectedProject, dueDateSelected, fromTimeSelected, toTimeSelected, useToolSelected, prioritySelected,
        (Project project, int dueDateSelected, int fromTimeSelected, int toTimeSelected, int useToolSelected, Status status) {
      print('just enter');
      List<int> labelIds = [];
      _selectedLabelList.forEach((label) {
        labelIds.add(label.id!);
      });
      print("hi");

      var task = Tasks.create(
        title: updateTitle,
        dueDate: dueDateSelected,
        toTime: toTimeSelected,
        fromTime: fromTimeSelected,
        useTool: useToolSelected, //TODO,
        priority: status,
        projectId: project.id!,
      );
      ;
      print("hiiii");

      _taskDB.updateTask(task, labelIDs: labelIds).then((task) {
        Notification.onDone();
      });
    });
  }

  void updateDueDate(int millisecondsSinceEpoch) {
    _dueDateSelected.add(millisecondsSinceEpoch);
  }

  void updateFromTime(int millisecondsSinceEpoch) {
    _fromTimeSelected.add(millisecondsSinceEpoch);
  }

  void updateToTime(int millisecondsSinceEpoch) {
    _toTimeSelected.add(millisecondsSinceEpoch);
  }

  void updateUseTool(bool useTool) {
    int val = useTool?1:0;
    _useToolSelected.add(val);
  }
}

