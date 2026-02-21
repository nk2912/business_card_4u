import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
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
}
