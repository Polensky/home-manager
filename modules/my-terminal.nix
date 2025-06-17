{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.my-terminal;
in {
  ##### interface
  options = {
    programs.my-terminal = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable my terminal.";
      };
    };
  };

  ##### implementation
  config = mkIf cfg.enable {
    programs.ranger = {
      enable = true;
      extraPackages = with pkgs; [ueberzugpp];
      extraConfig = ''
        set preview_images true
        set preview_images_method ueberzug
      '';
    };

    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = ''
        local wezterm = require 'wezterm'
        local config = {}

        config.enable_tab_bar = false

        config.font = wezterm.font_with_fallback { "Fira Code" }

        config.font_size = 14.0
        config.color_scheme = 'Everforest Dark (Gogh)'
        config.window_background_opacity = 0.9
        config.window_padding = {
          left = 1,
          right = 1,
          top = 1,
          bottom = 1,
        }
        return config
      '';
    };
  };
}
