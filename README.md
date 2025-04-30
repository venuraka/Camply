# camply

## Ayeshi Login Google/ Facebook 
To use Google Sign-In on your local machine:

1. Run `cd android` to go to android directory (if not possible in vscode terminal try using the cmd).
2. Run `./gradlew signingReport`. (If your jdk > jdk 17 then download jdk 17 and change the path temporarily to 17 and when done you can 
    switch back to your original jdk)
3. Copy the SHA-1 from the `debug` variant.
4. Go to Firebase Console → Project Settings → General → Your Apps (Select your app from them ex: my one was "example.camply.com") → Add Fingerprint.
5. Add your SHA-1 there.
6. Download updated `google-services.json` and replace it in `android/app/`.
7. Run `flutter clean && flutter pub get`.
8. Done!