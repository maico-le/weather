class ApiEndpoints {
  static const String baseUrl = 'https://wttr.in';

  static String weatherByCity(String city) {
    final encoded = Uri.encodeComponent(city.trim());
    return '$baseUrl/$encoded?format=j1';
  }

  static const List<String> defaultCities = [
    'Ho Chi Minh City',
    'Hanoi',
    'Da Nang',
    'Can Tho',
    'Tokyo',
    'Singapore',
    'Seoul',
    'London',
    'Paris',
    'New York',
  ];
}
