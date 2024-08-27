enum RequestType {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  const RequestType(this.asString);

  final String asString;
}
