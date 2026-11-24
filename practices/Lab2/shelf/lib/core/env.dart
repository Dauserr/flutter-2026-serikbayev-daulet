abstract final class Env {
  static const catalogueHost = String.fromEnvironment(
    'CATALOGUE_HOST',
    defaultValue: 'openlibrary.org',
  );

  static const collectionHost = String.fromEnvironment(
    'COLLECTION_HOST',
    defaultValue: 'api.restful-api.dev',
  );

  static const useFakes = bool.fromEnvironment('USE_FAKES');

  static const name = String.fromEnvironment('ENV', defaultValue: 'local');
}
