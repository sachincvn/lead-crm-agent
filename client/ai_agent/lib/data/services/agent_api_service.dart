import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'agent_api_service.g.dart';

@RestApi()
abstract class AgentApiService {
  factory AgentApiService(Dio dio) = _AgentApiService;

  @POST('/agent/generate')
  Future<String> generateResponse(@Body() Map<String, dynamic> request);
}
