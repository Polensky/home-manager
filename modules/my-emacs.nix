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
    sha256 = "";
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
		pkgs.overlays = [
			emacs-overlay
		];
    services.emacs = {
      enable = true;
			package = my-emacs;
    };
  };
}
