const everyday = 1;
const period = 2;
const once = 3;

String convert(int frequency) {
  switch(frequency) {
    case everyday: return 'Everyday';
    case period: return 'Periodic';
    case once: return 'Once';
    default: return 'unknown';
  }
}
