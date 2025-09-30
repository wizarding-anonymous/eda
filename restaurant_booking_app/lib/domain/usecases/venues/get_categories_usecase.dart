import 'package:injectable/injectable.dart';

import '../../entities/category.dart';
import '../../repositories/venue_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class GetCategoriesUseCase {
  final VenueRepository _venueRepository;

  GetCategoriesUseCase(this._venueRepository);

  Future<ApiResult<List<Category>>> call() async {
    return await _venueRepository.getCategories();
  }
}
