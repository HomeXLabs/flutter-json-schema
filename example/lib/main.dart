import 'package:flutter/material.dart';
import 'package:flutter_json_schema/flutter_json_schema.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Flutter JsonSchema Demo';
    JsonSchemaBloc jsonSchemaBloc = JsonSchemaBloc();
    jsonSchemaBloc.getTestSchema();

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: StreamBuilder<Schema>(
          stream: jsonSchemaBloc.jsonSchema,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return JsonSchemaForm(
                schema: snapshot.data,
                jsonSchemaBloc: jsonSchemaBloc,
              );
            } else {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
