import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../models/business_card_model.dart';
import '../responses/card_response.dart';
import 'card_api.dart';

class CardApiImpl implements CardApi {
  final Dio dio;

  CardApiImpl(this.dio);

  @override
  Future<CardResponse> getCards() async {
    final res = await dio.get(ApiConstants.cards);

    return CardResponse.fromJson(res.data);
  }

  @override
  Future<BusinessCardModel> createCard(Map<String, dynamic> data) async {
    try {
      final Response res = await dio.post(
        ApiConstants.cards,
        data: data,
      );
      final dynamic body = res.data;
      final dynamic dataJson = body is Map<String, dynamic> ? body['data'] : null;
      return BusinessCardModel.fromJson(
        (dataJson ?? body) as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create card',
      );
    }
  }
}
