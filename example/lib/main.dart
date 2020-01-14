import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_schema/flutter_json_schema.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  static final navKey = new GlobalKey<NavigatorState>();

  const MyApp({Key navKey}) : super(key: navKey);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  String jsonSchema;
  String uiSchema;

  @override
  void initState() {
    super.initState();

    setup();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JsonSchema Demo',
      navigatorKey: MyApp.navKey,
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
      jsonSchema: jsonSchema,
      uiSchema: uiSchema,
      onFormDataChanged: (String formData) async {
        showDialog(
            context: MyApp.navKey.currentState.overlay.context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("FormData"),
                content: SizedBox(
                  width: 150,
                  child: TextFormField(
                    initialValue: formData,
                    maxLines: null,
                  ),
                ),
              );
            });
      },
    );
  }

  Future setup() async {
    jsonSchema = await rootBundle.loadString('assets/test_json_schema.json');
    uiSchema = await rootBundle.loadString('assets/test_ui_schema.json');

    setState(() {
      isLoading = false;
    });
  }
}
