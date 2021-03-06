import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:blapp/src/model/state_model.dart';

class StateRepository extends Disposable {
  final HasuraConnect connection;

  StateRepository(this.connection);

  Future<StateModel> createState(StateModel state) async {
    var query = """
      mutation createState(\$name:String!, \$country_id:Int) {
        insert_states(objects: {name: \$name, country_id: \$country_id}) {
          returning {
            state_id
          }
        }
      }
    """;
    var data = await connection.mutation(query, variables: {"nome": state.nome, "cnpj": state.cnpj});
    var id = data["data"]["insert_states"]["returning"][0]["state_id"];

    return StateModel(localizacao: id, nome: state.nome);
  }

  Future<int> remove(int stateId) async {
    var query = """ 
      mutation deleteState(\$state_id:Int){
        delete_states(
          where: { state_id: 
            {_eq: \$state_id}
          }
        ){
          affected_rows
        }
      }
    """;
    var data = await connection.mutation(query, variables: {"state_id": stateId});
    return data["data"]["delete_states"]["affected_rows"] as int;
  }

  @override
  void dispose() {}
}
