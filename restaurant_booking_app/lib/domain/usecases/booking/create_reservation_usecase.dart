import 'package:injectable/injectable.dart';

import '../../entities/reservation.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class CreateReservationUseCase {
  final BookingRepository _bookingRepository;

  CreateReservationUseCase(this._bookingRepository);

  Future<ApiResult<Reservation>> call(ReservationRequest request) async {
    return await _bookingRepository.createReservation(request);
  }
}