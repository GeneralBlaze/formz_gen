String pascalCase(String name) =>
    name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);

String lastSegment(String reference) => reference.split('.').last;
