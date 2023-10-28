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
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };
        androidPkgs = pkgs.androidenv.composeAndroidPackages {
          /*
          toolsVersion = "26.1.1";
          platformToolsVersion = "31.0.3";
          includeEmulator = false;
          emulatorVersion = "30.9.0";
          */
          buildToolsVersions = [ "30.0.3" ];
          platformVersions = [ "33" ];
        };
      in
      {
        devShell = pkgs.mkShell {
          JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
          nativeBuildInputs = with pkgs; [
            steam-run
          ];
          env = {
            ANDROID_SDK_ROOT = "${androidPkgs.androidsdk}/libexec/android-sdk";
            # GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidPkgs.androidsdk}/libexec/android-sdk/build-tools/30.0.3/aapt2";
          };
        };
      });
}
