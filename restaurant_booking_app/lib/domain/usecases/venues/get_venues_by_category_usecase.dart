import 'package:injectable/injectable.dart';

import '../../entities/venue.dart';
import '../../repositories/venue_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class GetVenuesByCategoryUseCase {
  final VenueRepository _venueRepository;

  GetVenuesByCategoryUseCase(this._venueRepository);

  Future<ApiResult<List<Venue>>> call(
    String categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _venueRepository.getVenuesByCategory(
      categoryId,
      page: page,
      limit: limit,
    );
  }
}
