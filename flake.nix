{
  description = "Development environment for GamepadMidiController";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          mingw = pkgs.pkgsCross.mingwW64;
        in {
          default = pkgs.mkShell {
            packages = [
              pkgs.cmake
              pkgs.ninja
              pkgs.pkg-config
              mingw.stdenv.cc
            ];
            shellHook = ''
              echo "Windows x86_64 cross-build tools are ready."
              echo "Configure with: cmake -S . -B build-windows -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/mingw-w64.cmake -DCMAKE_BUILD_TYPE=Release"
            '';
          };
        });
    };
}
