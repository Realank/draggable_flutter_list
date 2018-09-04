double absMinus(double a, double b) {
  double result = a - b;
  if (result < 0) {
    return -result;
  } else {
    return result;
  }
}
