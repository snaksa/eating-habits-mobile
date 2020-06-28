const underweight = 18.5;
const normal = 25;
const overweight = 30;
const obesity = 40;

bool isUnderweight(double bmi) {
  return bmi <= underweight;
}

bool isNormal(double bmi) {
  return bmi > underweight && bmi <= normal;
}

bool isOverweight(double bmi) {
  return bmi > normal && bmi <= overweight;
}

bool isObese(double bmi) {
  return bmi > overweight;
}