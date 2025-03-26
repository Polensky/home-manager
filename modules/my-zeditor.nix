{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.my-zeditor;
in {
  ##### interface
  options = {
    programs.my-zeditor = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the zed editor.";
      };
    };
  };

  ##### implementation
  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "elixir"
        "nix"
        "terraform"
        "make"

        "everforest"
      ];

      userSettings = {
        hour_format = "hour24";
      };
    };
  };
}
