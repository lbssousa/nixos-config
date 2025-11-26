{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "laercio";
  home.homeDirectory = "/home/laercio";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Set git config
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Laércio de Sousa";
        email = "laercio@sivali.sousa.nom.br";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
      rebase = {
        autostash = true;
      };
    };
    signing = {
      key = "5AB657FF72C72F35";
      signByDefault = true;
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    bat
    fd
    gh
    glab
    ripgrep
    neovim
    nix-index
    zathura
    # Distrobox for running any Linux distribution in containers
    distrobox
    # QuickShell - configurable status bar/shell
    quickshell

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
  ];

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
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/laercio/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # ZSH configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    history = {
      size = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      share = true;
    };
    
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -lah";
      vim = "nvim";
      cat = "bat";
      grep = "rg";
      find = "fd";
    };
    
    initContent = ''
      # Case insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      
      # Better history search
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    
    settings = {
      add_newline = true;
      
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$nodejs"
        "$python"
        "$rust"
        "$golang"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };
      
      git_branch = {
        symbol = "🌱 ";
        style = "bold purple";
      };
      
      git_status = {
        style = "bold yellow";
      };
      
      nix_shell = {
        symbol = "❄️ ";
        style = "bold blue";
      };
      
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow)";
      };
    };
  };

  # Niri compositor configuration via config file
  home.file.".config/niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "br"
            }
        }
        
        touchpad {
            tap
            natural-scroll
            dwt
        }
        
        mouse {
            accel-speed 0.0
        }
    }
    
    layout {
        gaps 8
        center-focused-column "never"
        
        preset-column-widths {
            proportion 0.33
            proportion 0.5
            proportion 0.67
        }
        
        default-column-width { proportion 0.5; }
    }
    
    prefer-no-csd
    
    cursor {
        size 24
        theme "Adwaita"
    }
    
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
    
    // Keybindings
    binds {
        Mod+Return { spawn "ghostty"; }
        Mod+D { spawn "fuzzel"; }
        Mod+Q { close-window; }
        
        // Screenshots
        Print { screenshot; }
        Shift+Print { screenshot-screen; }
        Mod+Print { screenshot-window; }
        
        // Focus navigation
        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down { focus-window-down; }
        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }
        Mod+K { focus-window-up; }
        Mod+J { focus-window-down; }
        
        // Move windows
        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up { move-window-up; }
        Mod+Shift+Down { move-window-down; }
        Mod+Shift+H { move-column-left; }
        Mod+Shift+L { move-column-right; }
        Mod+Shift+K { move-window-up; }
        Mod+Shift+J { move-window-down; }
        
        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        
        Mod+Shift+1 { move-window-to-workspace 1; }
        Mod+Shift+2 { move-window-to-workspace 2; }
        Mod+Shift+3 { move-window-to-workspace 3; }
        Mod+Shift+4 { move-window-to-workspace 4; }
        Mod+Shift+5 { move-window-to-workspace 5; }
        
        // Window management
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Comma { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }
        
        // Column widths
        Mod+R { set-column-width "-10%"; }
        Mod+T { set-column-width "+10%"; }
        
        // Exit niri
        Mod+Shift+E { quit; }
    }
    
    spawn-at-startup "mako"
    spawn-at-startup "nm-applet" "--indicator"
    spawn-at-startup "quickshell"
  '';

  # Ghostty terminal configuration
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
      font-family = "FiraCode Nerd Font";
      font-size = 11;
      cursor-style = "block";
      cursor-style-blink = false;
      shell-integration = "zsh";
      confirm-close-surface = false;
      window-padding-x = 8;
      window-padding-y = 8;
    };
  };

  # Mako notification daemon
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      ignore-timeout = true;
      max-visible = 5;
      font = "sans-serif 11";
      background-color = "#1e1e2e";
      text-color = "#cdd6f4";
      border-color = "#89b4fa";
      border-size = 2;
      border-radius = 8;
      padding = "10";
      margin = "10";
      layer = "overlay";
      anchor = "top-right";
    };
  };

  # QuickShell configuration
  home.file.".config/quickshell/shell.qml".text = ''
    import Quickshell
    import Quickshell.Wayland

    ShellRoot {
      WlSessionLock {
        // Lock screen implementation
      }

      Variants {
        model: Quickshell.screens
        
        PanelWindow {
          property var screen: modelData
          
          anchors {
            top: true
            left: true
            right: true
          }
          
          height: 32
          color: "#1e1e2e"
          
          // Simple bar with time
          Text {
            anchors.centerIn: parent
            text: new Date().toLocaleTimeString()
            color: "#cdd6f4"
            
            Timer {
              interval: 1000
              running: true
              repeat: true
              onTriggered: parent.text = new Date().toLocaleTimeString()
            }
          }
        }
      }
    }
  '';

  # Noctalia theme (dark theme configuration)
  home.file.".config/noctalia/config.toml".text = ''
    # Noctalia - Dark theme configuration
    [theme]
    name = "catppuccin-mocha"
    
    [colors]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    primary = "#89b4fa"
    secondary = "#f5c2e7"
    accent = "#cba6f7"
    error = "#f38ba8"
    warning = "#fab387"
    success = "#a6e3a1"
    
    [gtk]
    theme = "Adwaita-dark"
    icon_theme = "Adwaita"
    cursor_theme = "Adwaita"
  '';

  # GTK configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Start Niri on login from tty1
  programs.zsh.loginExtra = ''
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
      exec niri-session
    fi
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
