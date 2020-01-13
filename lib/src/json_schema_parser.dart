import 'dart:convert';
import 'package:flutter_json_schema/src/models.dart';

class JsonSchemaParser {
  Schema schema;
  Map<String, dynamic> data = Map<String, dynamic>();
  String get formData => json.encode(data);

  void readFromJsonString(String jsonSchema, String uiSchema) async {
    Map<String, dynamic> jsonSchemaMap = json.decode(jsonSchema);
    Map<String, dynamic> uiSchemaMap = json.decode(uiSchema);

    schema = Schema.fromJson(jsonSchemaMap)..setUiSchema(uiSchemaMap);
    schema.properties.forEach((p) {
      data[p.id] = p.defaultValue;
    });
  }
}
