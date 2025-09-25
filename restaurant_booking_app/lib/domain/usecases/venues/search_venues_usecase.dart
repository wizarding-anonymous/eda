import 'package:injectable/injectable.dart';

import '../../entities/venue.dart';
import '../../repositories/venue_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class SearchVenuesUseCase {
  final VenueRepository _venueRepository;

  SearchVenuesUseCase(this._venueRepository);

  Future<ApiResult<List<Venue>>> call(
    SearchFilters filters, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _venueRepository.searchVenues(filters, page: page, limit: limit);
  }
}