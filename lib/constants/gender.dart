const male = 0;
const female = 1;

String convert(int gender) {
  switch(gender) {
    case male: return 'Male';
    case female: return 'Female';
    default: return 'unknown';
  }
}
