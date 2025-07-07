{
  config,
  pkgs,
  inputs,
  pkgs_25_05,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "charles";
  home.homeDirectory = "/Users/charles";

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
    # dev
    alacritty
    lazygit
    gnumake
    tmux
    fzf
    awscli2
    ssm-session-manager-plugin
    terraform
    htop
    wget
    pgcli
    tabview # csv viewer
    magic-wormhole
    inputs.snsm.packages.${system}.default
    numbat # very cool calculator
    nix-output-monitor

    # media
    mpv
    cmus
    ffmpeg
    cmus
    pngpaste
    yt-dlp
    inputs.yt-x.packages."${system}".default

    # llm
    pkgs_25_05.aider-chat-full

    # email
    neomutt
    mutt-wizard
    isync
    msmtp
    lynx
    notmuch
    abook

    fira-code

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    (writeShellScriptBin "edit-home" ''
      cd ~/.config/home-manager && nvim ./devices/mbp-m4.nix
    '')
    (writeShellScriptBin "hms" ''
      home-manager switch --flake ~/.config/home-manager#charles@mbp-m4  |& nom
    '')
    (writeShellApplication {
      name = "ssm";
      runtimeInputs = with pkgs; [awscli2 ssm-session-manager-plugin fzf];
      text = ''
        profile="''${1:-default}"

        instance_id=$(
          aws ec2 describe-instances \
            --query "Reservations[].Instances[].[InstanceId, Tags[?Key=='Name'].Value]" \
            --output text \
          --profile "$profile" \
          | paste -d ' ' - - \
          | fzf \
          | awk '{print $1}'
        )

        aws ssm start-session --profile "$profile" --target "$instance_id"
      '';
    })
  ];

  fonts.fontconfig.enable = true;

  programs.my-terminal.enable = true;
  programs.my-zeditor.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      v = "nvim";
      wkc = "cd $(ls -d ~/workspace/* | fzf)";
      wko = "cd $(ls -d ~/workspace/* | fzf); nvim";
    };
  };

  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    config = {
      sync.server.url = "http://192.168.1.242:10222";
    };
  };

  services.ollama = {
    enable = true;
    environmentVariables = {
      OLLAMA_API_BASE = "http://127.0.0.1:11434";
      OLLAMA_CONTEXT_LENGTH = "8192";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      battery = {
        display = [
          {
            threshold = 15;
            style = "green";
          }
        ];
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Charles Sirois";
    userEmail = "charles@rumandcode.io";
    hooks = {
      "prepare-commit-msg" = ./scripts/prepare-commit-msg.sh;
    };
    aliases = {
      sw = "switch";
      co = "checkout";
      # doesnt quite work
      lg = "log --graph --abbrev-commit --decorate --format=format:\"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)\"";
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

    ".config/skhd/skhdrc".source = dotfiles/skhdrc;
    ".config/yabai/yabairc".source = dotfiles/yabairc;

    ".config/alacritty/alacritty.toml".source = dotfiles/alacritty/alacritty.toml;
    ".config/alacritty/everforest_dark.toml".source = dotfiles/alacritty/everforest_dark.toml;

    ".qutebrowser/everforest.py".source = dotfiles/qutebrowser/everforest.py;
    ".qutebrowser/config.py".source = dotfiles/qutebrowser/config.py;
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
