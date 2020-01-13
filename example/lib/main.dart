import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_schema/flutter_json_schema.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  JsonSchemaParser parser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    createJsonSchemaParser();
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

  Widget _buildForm() {
    return JsonSchemaForm(
      schema: parser.schema,
      jsonSchemaParser: parser,
    );
  }

  Future createJsonSchemaParser() async {
    parser = JsonSchemaParser();
    var jsonSchema =
        await rootBundle.loadString('assets/test_json_schema.json');
    var uiSchema = await rootBundle.loadString('assets/test_ui_schema.json');
    parser.readFromJsonString(jsonSchema, uiSchema);
    setState(() {
      isLoading = false;
    });
  }
}
