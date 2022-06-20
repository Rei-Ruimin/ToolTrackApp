import 'package:flutter/material.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:flutter_app/pages/tasks/row_task.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'dart:math';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TaskBloc _tasksBloc = BlocProvider.of(context);

    return StreamBuilder<List<Tasks>>(
      stream: _tasksBloc.tasks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildTaskList(snapshot.data!, context);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );

  }

  Widget _buildTaskList(List<Tasks> list, BuildContext context) {
    int getTotalTime() {
      int totalTime = 0;
      list.forEach((task) {
        DateTime toTime = DateTime.fromMillisecondsSinceEpoch(task.toTime);
        DateTime fromTime = DateTime.fromMillisecondsSinceEpoch(task.fromTime);
        Duration diff = toTime.difference(fromTime);
        totalTime += diff.inMinutes;
      });
      return totalTime;
    }

    int getToolTime() {
      int toolTime = 0;
      list.forEach((task) {
        if (task.useTool == 1) {
          DateTime toTime = DateTime.fromMillisecondsSinceEpoch(task.toTime);
          DateTime fromTime = DateTime.fromMillisecondsSinceEpoch(task.fromTime);
          Duration diff = toTime.difference(fromTime);
          toolTime += diff.inMinutes;
        }
      });
      return toolTime;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: list.length == 0
          ? MessageInCenterWidget("No Task Added")
          :
          Container(
            child:
            Column(children: <Widget>[
              Container(
                // width: 300,
                height: 60,
                margin: EdgeInsets.symmetric(horizontal:15, vertical: 15),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    border: Border.all(width: 10,color: Theme.of(context).colorScheme.primary,),
                    borderRadius: BorderRadius.circular(20,)
                ),
                alignment: Alignment.center,
                child:Text(
                    'Total Time: ${(getTotalTime()/60).toStringAsFixed(1)} hrs     '
                    'Tool Time: ${(getToolTime()/60).toStringAsFixed(1)} hrs      '
                    '${(getToolTime()/getTotalTime()).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRect(
                      child: Dismissible(
                          key: ValueKey("swipe_${list[index].id}_$index"),
                          onDismissed: (DismissDirection direction) {
                            var taskID = list[index].id!;
                            final TaskBloc _tasksBloc =
                            BlocProvider.of<TaskBloc>(context);
                            String message = "";
                            if (direction == DismissDirection.endToStart) {
                              _tasksBloc.updateStatus(
                                  taskID, TaskStatus.COMPLETE);
                              message = "Task completed";
                            } else {
                              _tasksBloc.delete(taskID);
                              message = "Task deleted";
                            }
                            SnackBar snackbar =
                            SnackBar(content: Text(message));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackbar);
                          },
                          background: Container(
                            color: Colors.red,
                            child: Align(
                              alignment: Alignment(-0.95, 0.0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.green,
                            child: Align(
                              alignment: Alignment(0.95, 0.0),
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                          ),
                          child: TaskRow(list[index])),
                    );
                  }),
              )
            ]
            )
          ),
    );
  }
}
