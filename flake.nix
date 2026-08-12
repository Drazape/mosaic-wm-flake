{
	description = "Rethinking window management for GNOME Shell";

	inputs = {
		flake-parts = { type="github"; owner="hercules-ci"; repo="flake-parts"; };
		nixpkgs = { type="github"; owner="NixOS"; repo="nixpkgs"; ref="nixpkgs-unstable"; };
		mosaic-wm = {
			type="github"; owner="CleoMenezesJr"; repo="MosaicWM";
			flake = false;
		};
	};

	outputs = inputs@{ flake-parts, ... }:
		flake-parts.lib.mkFlake { inherit inputs; } {
			systems = [ "x86_64-linux" "aarch64-linux" ];
			perSystem = { self', pkgs, lib, ... }: {
				packages = let pkgName = "mosaic-wm-gnome-extension"; in {
					default = self'.packages.${pkgName};
					${pkgName} = pkgs.stdenvNoCC.mkDerivation {
						name = pkgName;
						src = inputs.mosaic-wm;
						nativeBuildInputs = [pkgs.buildPackages.glib];

						buildPhase = ''
							glib-compile-schemas --strict ./extension/schemas/
						'';

						installPhase = ''
							install_path=$out/share/gnome-shell/extensions/mosaicwm@cleomenezesjr.github.io/
							${lib.getExe' pkgs.coreutils "mkdir"} --parents -- $install_path
							${lib.getExe' pkgs.coreutils "cp"} --recursive --no-target-directory -- ./extension/ $install_path
						'';

						meta = {
							description = "Rethinking window management for GNOME Shell";
							homepage = "https://github.com/CleoMenezesJr/MosaicWM";
							license = lib.licenses.gpl2;
							platforms = lib.platforms.linux;
						};
					};
				};
			};
		};
}		 
