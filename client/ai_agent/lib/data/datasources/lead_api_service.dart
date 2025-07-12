import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../domain/entities/lead.dart';

part 'lead_api_service.g.dart';

@RestApi()
abstract class LeadApiService {
  factory LeadApiService(Dio dio) = _LeadApiService;

  @GET('/leads')
  Future<List<Lead>> getLeads();

  @POST('/leads')
  Future<Lead> createLead(@Body() Lead lead);

  @PUT('/leads/{id}')
  Future<Lead> updateLead(
    @Path('id') String id,
    @Body() Lead lead,
  );

  @DELETE('/leads/{id}')
  Future<void> deleteLead(@Path('id') String id);
}
