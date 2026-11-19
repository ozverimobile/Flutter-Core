enum RequestType {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE');

  const RequestType(this.asString);

  final String asString;
}
