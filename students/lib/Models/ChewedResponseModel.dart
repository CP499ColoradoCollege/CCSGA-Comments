/* 
 * This class helps digest an http response.
 * Based on the status code, it figures out whether the transaction 
 * was @param isSuccessful, and if not, provides a helpful error @param message
 * Specify @param message in the constructor if a success message
 * is necessary (otherwise message == null on success)
 * @param message is a success or error message
 */
class ChewedResponse {
  bool isSuccessful;
  String message;
  int statusCode;

  ChewedResponse({this.isSuccessful, this.message, this.statusCode}) {
    if (this.statusCode != null) {
      this.chewStatusCode(this.statusCode);
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
      this.isSuccessful = false;
      this.message = 'Page or resource cannot be found';
    } else {
      this.isSuccessful = false;
      this.message = 'Failed to send your message';
    }
  }
}
