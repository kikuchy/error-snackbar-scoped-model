import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp(model: LoadModel()));

/// Base of State.
///
/// I need union type for Dart 😫
abstract class LoadModelStatus {
  LoadModelStatus(this.lastData);

  final String lastData;
}

/// Loading.
class LoadModelStatusLoading extends LoadModelStatus {
  LoadModelStatusLoading(String lastData) : super(lastData);
}

/// Success.
class LoadModelStatusSuccess extends LoadModelStatus {
  LoadModelStatusSuccess(String lastData) : super(lastData);
}

/// Failure.
class LoadModelStatusFailure extends LoadModelStatus {
  LoadModelStatusFailure(String lastData, this.error) : super(lastData);
  final Object error;
}

/// Model of [LoadPage].
/// Sometimes failure to load data randomly.
class LoadModel extends Model {
  LoadModelStatus _status = LoadModelStatusSuccess("Initial state");

  LoadModelStatus get status => _status;

  Future<void> requestLoad() async {
    // Cancel requests while loading.
    if (_status is LoadModelStatusLoading) return;

    _status = LoadModelStatusLoading(_status.lastData);
    notifyListeners();
    try {
      final data = await Future.delayed(
          Duration(milliseconds: 300),
          () => Random().nextBool()
              ? "Success!!"
              : throw Exception("Failure..."));
      _status = LoadModelStatusSuccess(_status.lastData + data);
    } catch (e) {
      _status = LoadModelStatusFailure(_status.lastData, e);
    }
    notifyListeners();
  }
}

/// Screen widget.
/// It has Text shows current [LoadModel]'s data and a button to reload.
/// It shows [SnackBar] when loading fails.
class LoadPage extends StatefulWidget {
  LoadPage({Key key, this.model}) : super(key: key);

  final LoadModel model;

  @override
  _LoadPageState createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  void showSnackBarOnError() {
    final status = widget.model.status;
    if (status is LoadModelStatusFailure) {
      final snackBar = SnackBar(
          content: Text("Faild to load: ${status.error}"),
          action: SnackBarAction(
              label: "Realod", onPressed: () => widget.model.requestLoad()));
      // No GlobalKey!! This is smart way, isn't it?
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }


  @override
  void initState() {
    super.initState();
    widget.model.addListener(showSnackBarOnError);
    // Initial load.
    widget.model.requestLoad();
  }

  @override
  void dispose() {
    widget.model.removeListener(showSnackBarOnError);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<LoadModel>(
        model: widget.model,
        child: Center(
          child: Column(
            children: <Widget>[
              ScopedModelDescendant<LoadModel>(
                  builder: (context, child, model) =>
                      Text(model.status.lastData)),
              SizedBox(
                height: 16,
              ),
              ScopedModelDescendant<LoadModel>(
                builder: (context, child, model) {
                  if (model.status is LoadModelStatusLoading) {
                    return CircularProgressIndicator();
                  } else {
                    return RaisedButton(
                        child: Text("Reload"),
                        onPressed: () => model.requestLoad());
                  }
                },
              ),
            ],
          ),
        ));
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key key, this.model}) : super(key: key);

  final LoadModel model;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Demo Home Page'),
        ),
        body: LoadPage(model: model),
      ),
    );
  }
}
