class Schema {
  String title;
  String type;
  String description;
  List<dynamic> required;
  List<Properties> properties;

  Schema({
    this.title,
    this.type,
    this.description,
    this.required,
    this.properties,
  });

  factory Schema.fromJson(Map<String, dynamic> jsonSchema) {
    Schema newSchema = Schema(
      title: jsonSchema['title'],
      type: jsonSchema['type'],
      description: jsonSchema['description'],
      required: jsonSchema['required'],
    );
    newSchema.setProperties(jsonSchema['properties'], newSchema.required);
    print(newSchema.properties);
    return newSchema;
  }

  void setUiSchema(Map<String, dynamic> uiSchema) {
    uiSchema.forEach((key, data) {
      var props = properties.where((x) => x.id == key).toList();
      if (props.length > 0) {
        props.first = Properties.fromUiSchema(props.first, uiSchema[key]);
      }
    });
  }

  void setProperties(Map<String, dynamic> json, List<dynamic> requiredList) {
    List<Properties> props = List<Properties>();
    json.forEach((key, data) {
      bool required = true;
      if (requiredList.indexOf(key) == -1) {
        required = false;
      }
      props.add(
        Properties(
          id: key,
          type: data['type'],
          title: data['title'],
          defaultValue: data['default'],
          minLength: data['minLength'],
          required: required,
        ),
      );
    });

    this.properties = props;
  }
}

class Properties {
  String id;
  String type;
  String title;
  dynamic defaultValue;
  bool required;
  int minLength;
  bool autoFocus;
  String emptyValue;
  String description;
  String help;
  String widget;
  Options options;

  Properties({
    this.id,
    this.type,
    this.title,
    this.defaultValue,
    this.required,
    this.minLength,
    this.autoFocus,
    this.emptyValue,
    this.description,
    this.help,
    this.options,
  });

  factory Properties.fromJsonSchema(
      String propertyId, Map<String, dynamic> jsonSchema) {
    return Properties(
      id: propertyId,
      type: jsonSchema['type'],
      title: jsonSchema['title'],
      defaultValue: jsonSchema['default'],
      minLength: jsonSchema['minLength'],
    );
  }

  factory Properties.fromUiSchema(
      Properties prop, Map<String, dynamic> uiSchema) {
    Properties property = prop;

    uiSchema.forEach((key, data) {
      switch (key) {
        case "ui:autofocus":
          property.autoFocus = data as bool;
          break;
        case "ui:emptyValue":
          property.emptyValue = data as String;
          break;
        case "ui:title":
          property.title = data as String;
          break;
        case "ui:description":
          property.description = data as String;
          break;
        case "ui:help":
          property.help = data as String;
          break;
        case "ui:widget":
          property.widget = data as String;
          break;
        case "ui:options":
          property.options = Options.fromJson(data);
          break;
        default:
          break;
      }
    });

    return property;
  }
}

class Options {
  String inputType;

  Options({
    this.inputType,
  });

  factory Options.fromJson(Map<String, dynamic> json) {
    Options options = Options();

    options.inputType = json["inputType"];

    return options;
  }
}
