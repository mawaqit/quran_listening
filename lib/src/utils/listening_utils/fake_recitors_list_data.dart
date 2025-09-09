import '../../models/reciter.dart';

// Sample data for testing purposes
final List<Reciter> fakeReciters = [
  Reciter(
    id: 1,
    mainReciterId: 1,
    reciterName: 'Muhammad Al-Luhaidan',
    mushaf: [],
    serverUrl: 'https://example.com/',
    style: 'Murattal',
    totalSurah: 114,
    surahsList: List.generate(114, (index) => (index + 1).toString()),
  ),
  Reciter(
    id: 2,
    mainReciterId: 2,
    reciterName: 'Abdul Rahman Al-Sudais',
    mushaf: [],
    serverUrl: 'https://example.com/',
    style: 'Murattal',
    totalSurah: 114,
    surahsList: List.generate(114, (index) => (index + 1).toString()),
  ),
  Reciter(
    id: 3,
    mainReciterId: 3,
    reciterName: 'Mishary Rashid Alafasy',
    mushaf: [],
    serverUrl: 'https://example.com/',
    style: 'Murattal',
    totalSurah: 114,
    surahsList: List.generate(114, (index) => (index + 1).toString()),
  ),
];
