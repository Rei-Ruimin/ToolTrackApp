import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/bloc/add_task_bloc.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:flutter_app/utils/extension.dart';

import 'bloc/task_bloc.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {

  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Task",
          key: ValueKey(AddTaskKeys.ADD_TASK_TITLE),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  key: ValueKey(AddTaskKeys.ADD_TITLE),
                  validator: (value) {
                    var msg = value!.isEmpty ? "Title Cannot be Empty" : null;
                    return msg;
                  },
                  onSaved: (value) {
                    createTaskBloc.updateTitle = value!;
                  },
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(hintText: "Title")),
            ),
            key: _formState,
          ),
          CheckboxListTile(
            title: Text('Use Tool'),
            contentPadding: EdgeInsets.all(8),
            activeColor: Theme.of(context).colorScheme.primary,
            value: isChecked,
            onChanged: (bool? value) {
              setState(() {
                isChecked = value!;
              });
              _selectUseTool(context, isChecked);
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          ListTile(
            key: ValueKey("addProject"),
            leading: Icon(Icons.book),
            title: Text("Project"),
            subtitle: StreamBuilder<Project>(
              stream: createTaskBloc.selectedProject,
              initialData: Project.getInbox(),
              builder: (context, snapshot) => Text(snapshot.data!.name),
            ),
            onTap: () {
              _showProjectsDialog(createTaskBloc, context);
            },
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text("From"),
            subtitle: StreamBuilder<int>(
              stream: createTaskBloc.fromTimeSelected,
              initialData: DateTime.now().hour,
              builder: (context, snapshot) =>
                  Text(getFormattedTime(snapshot.data!)),
            ),
            onTap: () {
              _selectTime(context, true);
            },
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text("To"),
            subtitle: StreamBuilder<int>(
              stream: createTaskBloc.toTimeSelected,
              initialData: DateTime.now().millisecondsSinceEpoch,
              builder: (context, snapshot) =>
                  Text(getFormattedTime(snapshot.data!)),
            ),
            onTap: () {
              _selectTime(context, false);
            },
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
          key: ValueKey(AddTaskKeys.ADD_TASK),
          child: Icon(Icons.send, color: Colors.white),
          onPressed: () {
            // context.safePop();
            _selectUseTool(context, isChecked);
            if (_formState.currentState!.validate()) {
              _formState.currentState!.save();
              createTaskBloc.createTask().listen((value) {
                if (context.isWiderScreen()) {
                  context
                      .bloc<HomeBloc>()
                      .applyFilter("Today", Filter.byToday());
                } else {
                  context.safePop();
                }
              });
            }
          }),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      createTaskBloc.updateDueDate(picked.millisecondsSinceEpoch);
    }
  }
  // REI
  Future<Null> _selectTime(BuildContext context, bool isFromTime) async {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      var now = new DateTime.now();
      var conv_picked = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      if (isFromTime) {
        createTaskBloc.updateFromTime(conv_picked.millisecondsSinceEpoch);
      }
      else {
        createTaskBloc.updateToTime(conv_picked.millisecondsSinceEpoch);

      }
    }
  }

  Future<Null> _selectUseTool(BuildContext context, bool useTool) async {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    createTaskBloc.updateUseTool(useTool);
  }


  Future<Status?> _showPriorityDialog(
      AddTaskBloc createTaskBloc, BuildContext context) async {
    return await showDialog<Status>(
        context: context,
        builder: (BuildContext dialogContext) {
          return SimpleDialog(
            title: const Text('Select Priority'),
            children: <Widget>[
              buildContainer(context, Status.PRIORITY_1),
              buildContainer(context, Status.PRIORITY_2),
              buildContainer(context, Status.PRIORITY_3),
              buildContainer(context, Status.PRIORITY_4),
            ],
          );
        });
  }

  Future<Status?> _showProjectsDialog(
      AddTaskBloc createTaskBloc, BuildContext context) async {
    return showDialog<Status>(
        context: context,
        builder: (BuildContext dialogContext) {
          return StreamBuilder<List<Project>>(
              stream: createTaskBloc.projects,
              initialData: <Project>[],
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('Select Project'),
                  children:
                      buildProjects(createTaskBloc, context, snapshot.data!),
                );
              });
        });
  }

  Future<Status?> _showLabelsDialog(BuildContext context) async {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    return showDialog<Status>(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder<List<Label>>(
              stream: createTaskBloc.labels,
              initialData: <Label>[],
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('Select Labels'),
                  children:
                      buildLabels(createTaskBloc, context, snapshot.data!),
                );
              });
        });
  }

  List<Widget> buildProjects(
    AddTaskBloc createTaskBloc,
    BuildContext context,
    List<Project> projectList,
  ) {
    List<Widget> projects = [];
    projectList.forEach((project) {
      projects.add(ListTile(
        leading: Container(
          width: 12.0,
          height: 12.0,
          child: CircleAvatar(
            backgroundColor: Color(project.colorValue),
          ),
        ),
        title: Text(project.name),
        onTap: () {
          createTaskBloc.projectSelected(project);
          Navigator.pop(context);
        },
      ));
    });
    return projects;
  }

  List<Widget> buildLabels(
    AddTaskBloc createTaskBloc,
    BuildContext context,
    List<Label> labelList,
  ) {
    List<Widget> labels = [];
    labelList.forEach((label) {
      labels.add(ListTile(
        leading: Icon(Icons.label, color: Color(label.colorValue), size: 18.0),
        title: Text(label.name),
        trailing: createTaskBloc.selectedLabels.contains(label)
            ? Icon(Icons.close)
            : Container(width: 18.0, height: 18.0),
        onTap: () {
          createTaskBloc.labelAddOrRemove(label);
          Navigator.pop(context);
        },
      ));
    });
    return labels;
  }

  GestureDetector buildContainer(BuildContext context, Status status) {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    return GestureDetector(
        onTap: () {
          createTaskBloc.updatePriority(status);
          Navigator.pop(context, status);
        },
        child: Container(
            color: status == createTaskBloc.lastPrioritySelection
                ? Colors.grey
                : Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 6.0,
                    color: priorityColor[status.index],
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(12.0),
                child: Text(priorityText[status.index],
                    style: TextStyle(fontSize: 18.0)),
              ),
            )));
  }
}

class AddTaskProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: AddTaskBloc(TaskDB.get(), ProjectDB.get(), LabelDB.get()),
      child: AddTaskScreen(),
    );
  }
}
