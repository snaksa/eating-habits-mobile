import '../models/weight.dart';

class CalculationHelper {
  double calculateDynamicWeight(Weight weight) {
    return weight == null ? 5000 : (((weight.weight * 2.20) * 0.66) * 0.029) * 1000;
  }
}
