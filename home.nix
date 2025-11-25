{ config, pkgs, ... }:

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
    userName  = "Laércio de Sousa";
    userEmail = "laercio@sivali.sousa.nom.br";
    signing = {
      key = "5AB657FF72C72F35";
      signByDefault = true;
    };
    extraConfig = {
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

  # Niri compositor configuration
  programs.niri = {
    enable = true;
    
    settings = {
      # Input configuration
      input = {
        keyboard = {
          xkb = {
            layout = "br";
            variant = "";
            options = "";
          };
        };
        
        touchpad = {
          tap = true;
          natural-scroll = true;
          dwt = true;
        };
        
        mouse = {
          accel-speed = 0.0;
        };
      };
      
      # Layout configuration
      layout = {
        gaps = 8;
        center-focused-column = "never";
        preset-column-widths = [
          { proportion = 0.33; }
          { proportion = 0.5; }
          { proportion = 0.67; }
        ];
        default-column-width = { proportion = 0.5; };
      };
      
      # Prefer dark theme
      prefer-no-csd = true;
      
      # Cursor
      cursor = {
        size = 24;
        theme = "Adwaita";
      };
      
      # Screenshot path
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      
      # Hotkey configuration
      binds = {
        # Mod key is Super (Windows key)
        "Mod+Return".action.spawn = ["ghostty"];
        "Mod+D".action.spawn = ["fuzzel"];
        "Mod+Q".action.close-window = [];
        
        # Screenshots
        "Print".action.screenshot = [];
        "Shift+Print".action.screenshot-screen = [];
        "Mod+Print".action.screenshot-window = [];
        
        # Focus navigation
        "Mod+Left".action.focus-column-left = [];
        "Mod+Right".action.focus-column-right = [];
        "Mod+Up".action.focus-window-up = [];
        "Mod+Down".action.focus-window-down = [];
        "Mod+H".action.focus-column-left = [];
        "Mod+L".action.focus-column-right = [];
        "Mod+K".action.focus-window-up = [];
        "Mod+J".action.focus-window-down = [];
        
        # Move windows
        "Mod+Shift+Left".action.move-column-left = [];
        "Mod+Shift+Right".action.move-column-right = [];
        "Mod+Shift+Up".action.move-window-up = [];
        "Mod+Shift+Down".action.move-window-down = [];
        "Mod+Shift+H".action.move-column-left = [];
        "Mod+Shift+L".action.move-column-right = [];
        "Mod+Shift+K".action.move-window-up = [];
        "Mod+Shift+J".action.move-window-down = [];
        
        # Workspaces
        "Mod+1".action.focus-workspace = [1];
        "Mod+2".action.focus-workspace = [2];
        "Mod+3".action.focus-workspace = [3];
        "Mod+4".action.focus-workspace = [4];
        "Mod+5".action.focus-workspace = [5];
        
        "Mod+Shift+1".action.move-window-to-workspace = [1];
        "Mod+Shift+2".action.move-window-to-workspace = [2];
        "Mod+Shift+3".action.move-window-to-workspace = [3];
        "Mod+Shift+4".action.move-window-to-workspace = [4];
        "Mod+Shift+5".action.move-window-to-workspace = [5];
        
        # Window management
        "Mod+F".action.maximize-column = [];
        "Mod+Shift+F".action.fullscreen-window = [];
        "Mod+Comma".action.consume-window-into-column = [];
        "Mod+Period".action.expel-window-from-column = [];
        
        # Column widths
        "Mod+R".action.set-column-width = ["-10%"];
        "Mod+T".action.set-column-width = ["+10%"];
        
        # Exit niri
        "Mod+Shift+E".action.quit = [];
      };
      
      # Autostart programs
      spawn-at-startup = [
        { command = ["mako"]; }
        { command = ["nm-applet" "--indicator"]; }
        { command = ["quickshell"]; }
      ];
    };
  };

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
    defaultTimeout = 5000;
    ignoreTimeout = true;
    maxVisible = 5;
    font = "sans-serif 11";
    backgroundColor = "#1e1e2e";
    textColor = "#cdd6f4";
    borderColor = "#89b4fa";
    borderSize = 2;
    borderRadius = 8;
    padding = "10";
    margin = "10";
    layer = "overlay";
    anchor = "top-right";
  };

  # QuickShell - configurable status bar/shell
  home.packages = with pkgs; [
    quickshell
  ];

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
  programs.bash.profileExtra = ''
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
      exec niri-session
    fi
  '';

  programs.zsh.profileExtra = ''
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
      exec niri-session
    fi
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
