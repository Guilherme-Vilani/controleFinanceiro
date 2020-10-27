import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ListaMetas extends StatefulWidget {
  @override
  _ListaMetasState createState() => _ListaMetasState();
}

class _ListaMetasState extends State<ListaMetas> {
  final _toDoController = TextEditingController();

  List _listaMetas = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _listaMetas = json.decode(data);
      });
    });
  }

  void _addMeta() {
    setState(() {
      Map<String, dynamic> novaMeta = Map();
      novaMeta["title"] = _toDoController.text;
      _toDoController.text = "";
      novaMeta["ok"] = false;
      _listaMetas.add(novaMeta);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Metas',
          style: TextStyle(
            fontFamily: 'Roboto Slab',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 35,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15, top: 15, right: 15),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                      hintText: 'Qual a meta da vez ?',
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                RaisedButton(
                  color: Colors.blue,
                  onPressed: _addMeta,
                  child: Text(
                    'Atribuir meta',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto Slab',
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 15),
              child: ListView.builder(
                itemCount: _listaMetas.length,
                itemBuilder: itemBuilder,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget itemBuilder(context, index) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _listaMetas[index]["ok"] = false;
          _saveData();
        });
      },
      onTap: () {
        setState(() {
          _listaMetas[index]["ok"] = true;
          _saveData();
        });
      },
      child: Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: Card(
          elevation: 10,
          child: Container(
            color: _listaMetas[index]["ok"] ? Colors.green : Colors.red,
            alignment: Alignment.center,
            height: 50,
            child: Text(
              _listaMetas[index]["title"],
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto Slab',
              ),
            ),
          ),
        ),
        onDismissed: (direction) {
          setState(() {
            _lastRemoved = Map.from(_listaMetas[index]);
            _lastRemovedPos = index;
            _listaMetas.removeAt(index);

            _saveData();

            final snack = SnackBar(
              content: Text("Meta ${_lastRemoved["title"]} excluida!"),
              action: SnackBarAction(
                  label: "Desfazer",
                  onPressed: () {
                    setState(() {
                      _listaMetas.insert(_lastRemovedPos, _lastRemoved);
                      _saveData();
                    });
                  }),
              duration: Duration(seconds: 5),
            );
            Scaffold.of(context).showSnackBar(snack);
          });
        },
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_listaMetas);

    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (error) {
      return null;
    }
  }
}
