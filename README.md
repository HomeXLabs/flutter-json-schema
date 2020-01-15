# flutter_json_schema

Generate a Flutter form based on JSON Schema and outputs FormData on submit.
This is the react version of a [live playground](https://rjsf-team.github.io/react-jsonschema-form/).


## Usage
Here is how the JsonSchemaForm can be constructed where jsonSchema and uiSchema are String:
````dart
   JsonSchemaForm(
      jsonSchema: jsonSchema,
      uiSchema: uiSchema,
      onFormDataChanged: (String formData) async {
            // TODO: Do whatever you want to do with formData
      },
    );
````

