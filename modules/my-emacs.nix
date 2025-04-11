{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.my-emacs;
	emacs-overlay = import (fetchTarball {
    url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
    sha256 = "1d9v66xqvccsbygkg508720lnr6ya9mf5hjgg968vplf1ha4vjl2";
  });
  my-emacs = pkgs.emacs29.override {
    withNativeCompilation = true;
    withSQLite3 = true;
    withTreeSitter = true;
    withWebP = true;
  };
in {
  ##### interface
  options = {
    programs.my-emacs = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the emacs editor.";
      };
    };
  };

  ##### implementation
  config = mkIf cfg.enable {
		nixpkgs.overlays = [
			emacs-overlay
		];
    programs.emacs = {
      enable = true;
			package = my-emacs;
    };
  };
}
