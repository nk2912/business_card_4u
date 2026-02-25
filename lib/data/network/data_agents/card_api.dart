import '../../models/business_card_model.dart';
import '../responses/card_response.dart';

abstract class CardApi {
  Future<CardResponse> getCards();
  Future<BusinessCardModel> createCard(Map<String, dynamic> data);
}
