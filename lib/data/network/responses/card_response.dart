import '../../models/business_card_model.dart';

class CardResponse {
  final List<BusinessCardModel> cards;

  CardResponse({required this.cards});

  factory CardResponse.fromJson(dynamic json) {

    List data;

    if (json is List) {
      data = json;
    } else {
      data = json['data'] ?? [];
    }

    return CardResponse(
      cards: data
          .map((e) => BusinessCardModel.fromJson(e))
          .toList(),
    );
  }
}
