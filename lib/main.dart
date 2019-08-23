import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MaterialApp(
    title: "GQL App",
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // httpLink => link points to graphql server with desired headers and data
    final HttpLink httpLink = HttpLink(uri: "https://countries.trevorblades.com/");

    // when value changes the class will notify the listener
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: OptimisticCache(
          dataIdFromObject: typenameDataIdFromObject
        )
      )
    );

    return GraphQLProvider(
      child: HomePage(),
      client: client,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String query = r"""
    query GetContinent($code : String!){
      continent(code:$code){
        name
        countries{
          name
        }
      }
    }
  """;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GraphQL Client"),),
      body: Query(
        options: QueryOptions(document: query, variables: <String, dynamic>{"code": "AS"}),
        // Just like in apollo refetch() could be used to manually trigger a refetch
        // while fetchMore() can be used for pagination purpose
        builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
          if (result.errors != null) {
            return Text(result.errors.toString());
          }

          if (result.data == null) {
            return Text("No Data Found!");
          }

          if (result.loading) {
            return Text('Loading');
          }

          // it can be either Map or List
          List data = result.data['continent']['countries'];

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(data[index]['name']),
              );
          });
        },
      ),
    );
  }
}