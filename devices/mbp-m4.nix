{
  config,
  pkgs,
  inputs,
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
    brave

    # dev
    alacritty
    lazygit
    gnumake
    tmux

    font-awesome
    pkgs.nerd-fonts.fira-code

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
    (writeShellScriptBin "hms" ''
      home-manager switch --flake ~/.config/home-manager#charles@mbp-m4
    '')

    (pkgs.writeShellApplication {
      name = "start-session";
      runtimeInputs = with pkgs; [awscli2 fzf];
      text = ''
        if [ -n "$1" ]; then
        	profile="$1"
        else
        	profile="default"
        fi

        instance_id=$(
        	aws ec2 describe-instances \
        		--query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`].Value]' \
        		--output text \
        	--profile $profile \
        	| paste -d ' ' - - \
        	| fzf \
        	| awk '{print $1}'
        )

        aws ssm start-session --profile $profile --target $instance_id
      '';
    })
  ];

  programs.my-ghostty.enable = false;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      v = "nvim";
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
    ".config/skhd/yabairc".source = dotfiles/yabairc;

    ".config/alacritty/alacritty.toml".source = dotfiles/alacritty/alacritty.toml;
    ".config/alacritty/everforest_dark.toml".source = dotfiles/alacritty/everforest_dark.toml;
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
