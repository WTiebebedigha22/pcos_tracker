class BMICalculator {
  static double calculateBMI({
    required double weightKg,
    required double heightCm,
  }) {
    final heightM = heightCm / 100;

    return weightKg /
        (heightM * heightM);
  }

  static String getBMICategory(
    double bmi,
  ) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }
}