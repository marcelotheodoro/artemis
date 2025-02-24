import 'dart:convert';
import 'package:artemis/schema/options.dart';
import 'package:artemis/schema/graphql.dart';

GraphQLType getTypeByName(GraphQLSchema schema, String name) =>
    schema.types.firstWhere((t) => t.name == name);

GraphQLType followType(GraphQLType type) {
  switch (type.kind) {
    case GraphQLTypeKind.LIST:
    case GraphQLTypeKind.NON_NULL:
      return followType(type.ofType);
    default:
      return type;
  }
}

String buildTypeString(GraphQLType type, GeneratorOptions options,
    {bool dartType = true, String replaceLeafWith}) {
  switch (type.kind) {
    case GraphQLTypeKind.LIST:
      return 'List<${buildTypeString(type.ofType, options, dartType: dartType, replaceLeafWith: replaceLeafWith)}>';
    case GraphQLTypeKind.NON_NULL:
      return buildTypeString(type.ofType, options,
          dartType: dartType, replaceLeafWith: replaceLeafWith);
    case GraphQLTypeKind.SCALAR:
      final scalar = getSingleScalarMap(options, type);
      return dartType ? scalar.dartType : scalar.graphQLType;
    default:
      if (replaceLeafWith != null) return replaceLeafWith;
      return type.name;
  }
}

List<ScalarMap> _defaultScalarMapping = [
  ScalarMap(graphQLType: 'Boolean', dartType: 'bool'),
  ScalarMap(graphQLType: 'Float', dartType: 'double'),
  ScalarMap(graphQLType: 'ID', dartType: 'String'),
  ScalarMap(graphQLType: 'Int', dartType: 'int'),
  ScalarMap(graphQLType: 'String', dartType: 'String'),
];

ScalarMap getSingleScalarMap(GeneratorOptions options, GraphQLType type) =>
    options.scalarMapping.followedBy(_defaultScalarMapping).firstWhere(
        (m) => m.graphQLType == type.name,
        orElse: () => ScalarMap(graphQLType: type.name, dartType: type.name));

GraphQLSchema schemaFromJsonString(String jsonS) =>
    GraphQLSchema.fromJson(json.decode(jsonS));
