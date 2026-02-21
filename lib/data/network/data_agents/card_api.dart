import '../responses/card_response.dart';

abstract class CardApi {
  Future<CardResponse> getCards();
}
