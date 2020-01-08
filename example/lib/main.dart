import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_schema/flutter_json_schema.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  JsonSchemaBloc jsonSchemaBloc;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    createJsonSchemaBloc();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JsonSchema Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter JsonSchema Demo'),
        ),
        body: isLoading ? Container() : _buildForm(),
      ),
    );
  }

  StreamBuilder<Schema> _buildForm() {
    return StreamBuilder<Schema>(
      stream: jsonSchemaBloc.jsonSchema,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return JsonSchemaForm(
            schema: snapshot.data,
            jsonSchemaBloc: jsonSchemaBloc,
          );
        } else {
          return Container();
        }
      },
    );
  }

  Future createJsonSchemaBloc() async {
    jsonSchemaBloc = JsonSchemaBloc();
    var jsonSchema =
        await rootBundle.loadString('assets/test_json_schema.json');
    var uiSchema = await rootBundle.loadString('assets/test_ui_schema.json');
    jsonSchemaBloc.readFromJsonString(jsonSchema, uiSchema);
    setState(() {
      isLoading = false;
    });
  }
}
