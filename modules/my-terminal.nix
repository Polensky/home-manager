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

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      plugins = with pkgs.yaziPlugins; {
        inherit git;
      };
    };

    programs.alacritty = {
      enable = true;
      theme = "everforest_dark";
      settings = {
        window = {
          decorations = "buttonless";
          opacity = 0.94;
        };
        font = {
          size = 16;
          normal = {
            family = "Fira Code";
            style = "Regular";
          };
        };
      };
    };

    programs.wezterm = {
      enable = false;
      enableZshIntegration = true;
      extraConfig = ''
        local wezterm = require 'wezterm'
        local config = {}

        config.enable_tab_bar = false
        config.window_close_confirmation = 'NeverPrompt'

        config.font = wezterm.font_with_fallback { "Fira Code" }

        config.font_size = 16.0
        config.color_scheme = 'Everforest Dark (Gogh)'
        config.window_background_opacity = 0.95

        -- Set window decorations based on OS
        if wezterm.target_triple:find('linux') then
          config.window_decorations = "NONE"
        elseif wezterm.target_triple:find('darwin') then
          config.window_decorations = "RESIZE"
        else
          -- Default to RESIZE for any other OS
          config.window_decorations = "RESIZE"
        end

        config.window_padding = {
          left = 5,
          right = 5,
          top = 5,
          bottom = 5,
        }
        return config
      '';
    };
  };
}
