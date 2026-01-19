{
  config,
  pkgs,
  inputs,
  pkgs_25_05,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "polen";
  home.homeDirectory = "/home/polen";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # impala #for connecting to wifi nicely
    brave
    qutebrowser
    discord
    signal-desktop
    zathura
    vimiv-qt
    pcmanfm
    newsboat
    inputs.snsm.packages.${system}.default
    appimage-run
    sshfs

    # 3D stuff
    prusa-slicer
    orca-slicer
    openscad

    neovim
    ripgrep
    fzf
    fd
    brightnessctl
    unzip
    caligula

    # DE related
    hyprshot
    waycorner

    passExtensions.pass-otp
    (pass-wayland.withExtensions (ext: with ext; [pass-otp]))

    # media
    playerctl
    wayfarer
    mpv
    inkscape

    # dev
    lazygit
    gnumake
    magic-wormhole
    opencode
    taskwarrior3
    timewarrior

    nerd-fonts.fira-code

    (writeShellScriptBin "edit-home" ''
      cd ~/.config/home-manager && nvim ./devices/xps13.nix
    '')
    (writeShellScriptBin "batstatus" (builtins.readFile ./scripts/batstat.sh))
    (writeShellApplication {
      name = "hms";
      runtimeInputs = [pkgs.nix-output-monitor];
      text = ''
        home-manager switch --flake ~/.config/home-manager#polen@xps13 |& nom
      '';
    })
  ];

  fonts.fontconfig = {
    enable = true;
  };

  programs.protonmail-bridge.enable = true;
  programs.my-terminal.enable = true;

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=14";
      };
      colors = {
        alpha = 0.9;
        background = "2d353b";
        foreground = "d3c6aa";

        regular0 = "475258"; # black
        regular1 = "e67e80"; # red
        regular2 = "a7c080"; # green
        regular3 = "dbbc7f"; # yellow
        regular4 = "7fbbb3"; # blue
        regular5 = "d699b6"; # magenta
        regular6 = "83c092"; # cyan
        regular7 = "d3c6aa"; # white

        bright0 = "475258"; # bright black
        bright1 = "e67e80"; # bright red
        bright2 = "a7c080"; # bright green
        bright3 = "dbbc7f"; # bright yellow
        bright4 = "7fbbb3"; # bright blue
        bright5 = "d699b6"; # bright magenta
        bright6 = "83c092"; # bright cyan
        bright7 = "d3c6aa"; # bright white
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      v = "nvim";
      nrs = "sudo nixos-rebuild switch --flake ~/.config/nixos#default";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      right_format = "$time";
      battery = {
        display = [
          {
            threshold = 20;
            style = "green";
          }
          {
            threshold = 10;
            style = "bold red";
          }
        ];
      };
      time = {
        disabled = false;
        format = "[$time]($style)";
        time_format = "%H%M";
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
      "text/html" = ["brave-browser.desktop"];
      "image/*" = ["vimiv.desktop"];
      "x-scheme-handler/magnet" = ["userapp-transmission-gtk-C66AV2.desktop"];
    };
    defaultApplications = {
      "application/pdf" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
      "text/html" = ["brave-browser.desktop"];
      "image/*" = ["vimiv.desktop"];
      "x-scheme-handler/magnet" = ["userapp-transmission-gtk-C66AV2.desktop"];
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/alacritty/alacritty.toml".source = dotfiles/alacritty/alacritty.toml;
    ".config/alacritty/everforest_dark.toml".source = dotfiles/alacritty/everforest_dark.toml;

    ".config/qutebrowser/everforest.py".source = dotfiles/qutebrowser/everforest.py;
    ".config/qutebrowser/config.py".source = dotfiles/qutebrowser/config.py;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/polen/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {EDITOR = "nvim";};

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 46.3;
    longitude = -72.65;
  };

  services.flameshot = {
    enable = true;
    package = pkgs.flameshot.override {
      enableWlrSupport = true;
    };
    settings = {
      General = {
        useGrimAdapter = true;
        disabledTrayIcon = true;
        copyPathAfterSave = true;
        showDesktopNotification = false;
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
