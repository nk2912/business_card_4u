import 'dart:io';
import '../../models/business_card_model.dart';
import '../responses/card_response.dart';

abstract class CardApi {
  Future<CardResponse> getCards();
  Future<BusinessCardModel> createCard(Map<String, dynamic> data, {File? imageFile});
  Future<BusinessCardModel> updateCard(int id, Map<String, dynamic> data, {File? imageFile});
  Future<void> deleteCard(int id);
  Future<void> addFriend(int cardId);
  Future<void> removeFriend(int cardId);
}
