{
  inputs = {
    nixpkgs.url = "github:NickCao/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.android_sdk.accept_license = true;
        };
        androidPkgs = pkgs.androidenv.composeAndroidPackages {
          /*
          toolsVersion = "26.1.1";
          platformToolsVersion = "31.0.3";
          buildToolsVersions = [ "31.0.0" ];
          includeEmulator = false;
          emulatorVersion = "30.9.0";
          platformVersions = [ "31" ];
          */
        };
      in
      {
        devShell = pkgs.mkShell {
          # JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
          nativeBuildInputs = with pkgs; [
            flutter
            chromiuim
          ];
          env = {
            CHROME_EXECUTABLE = "chromium";
            ANDROID_SDK_ROOT = "${androidPkgs.androidsdk}/libexec/android-sdk";
          };
        };
      });
}
