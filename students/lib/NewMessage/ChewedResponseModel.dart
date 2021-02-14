/* 
 * Specify this.message in the constructor if a success message
 * is necessary (otherwise message == null on success)
 * @param this.message is a success or error message
 */
class ChewedResponse {
  bool isSuccessful;
  String message;
  int responseCode;

  ChewedResponse([this.isSuccessful, this.message, this.responseCode]) {
    if (this.responseCode != null) {
      this.chewStatusCode(this.responseCode);
    }
  }

  /*
   * Sets this.isSuccessful and this.message based on the @param statusCode
   */
  void chewStatusCode(int statusCode) {
    if (statusCode == 200 || statusCode == 201) {
      this.isSuccessful = true;
    } else if (statusCode == 401) {
      this.isSuccessful = false;
      this.message = 'You cannot send a message unless you are signed in';
    } else if (statusCode == 403) {
      this.isSuccessful = false;
      this.message =
          'Your account may have been banned. Please contact the Administrator';
    } else if (statusCode == 404) {
    } else {
      this.isSuccessful = false;
      this.message = 'Failed to send your message';
    }
  }
}
