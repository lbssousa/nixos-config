# System-level Homebrew (Linuxbrew) — analogous to Flatpak: a shared
# /home/linuxbrew/.linuxbrew prefix, managed declaratively at the NixOS
# level. Users can install additional packages manually via `brew install`.
#
# Division of labor with the nix-linuxbrew NixOS module (imported below):
#   - nix-linuxbrew: creates /home/linuxbrew with proper ownership and the
#     /bin+/usr/bin compatibility symlinks the Homebrew installer expects
#     (activation script "linuxbrew", runs as root).
#   - this module (runs after it, via deps=["linuxbrew"]): bootstraps
#     Homebrew on first activation, pre-installs the declarative
#     taps/formulae/casks, and wires brew into every user's environment.
#
# Options enableSystemSetup, brewPrefix, owner and compatSymlinks are owned
# by the nix-linuxbrew NixOS module; this module only adds taps/brews/casks
# and friends.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.programs.linuxbrew;
  inherit (cfg) brewPrefix;

  # brew needs a working git (also for private taps over SSH), so we wrap the
  # Nix git with openssh on PATH and point HOMEBREW_GIT_PATH at it.
  brewGit = pkgs.writeShellScript "brew-git" ''
    export PATH="${pkgs.openssh}/bin:$PATH"
    exec ${pkgs.git}/bin/git "$@"
  '';

  # The Homebrew installer on Linux expects a full POSIX toolchain. The
  # nix-linuxbrew compat symlinks cover the classic /bin+usr/bin names, but
  # activation scripts run with a minimal PATH, so we also make sure the
  # remaining tools are reachable by name. These match the upstream lists.
  installerDeps = [
    pkgs.coreutils
    pkgs.util-linux
    pkgs.gnugrep
    pkgs.gawk
    pkgs.git
    pkgs.curl
    pkgs.glibc.bin
    pkgs.findutils
    pkgs.gnused
    pkgs.gnutar
    pkgs.gzip
    pkgs.which
    pkgs.ruby
  ];

  # Tools brew itself needs at run time while this script syncs packages.
  runtimeDeps = [
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gawk
    pkgs.gnused
    pkgs.findutils
    pkgs.gnutar
    pkgs.gzip
    pkgs.which
    pkgs.openssh
  ];

  githubTokenPath = if cfg.githubApiTokenFile == null then "/dev/null" else cfg.githubApiTokenFile;

  extraEnvExports = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "export ${name}=${lib.escapeShellArg value}") cfg.extraBrewEnv
  );

  # Single activation script: bootstrap Homebrew (if missing) then sync the
  # declarative taps/formulae/casks. One shell, so the HOMEBREW_* env exports
  # are done once at the top and carry through to every brew invocation.
  linuxbrewInstallScript = pkgs.writeShellScript "linuxbrew-install" ''
    set -u

    BREW_PREFIX="${brewPrefix}"

    ${lib.optionalString (!cfg.allowContainerInstall) ''
      if [ -f /.dockerenv ] || grep -q 'lxc' /proc/1/cgroup 2>/dev/null; then
        echo "Skipping linuxbrew setup in container environment (allowContainerInstall = false)"
        exit 0
      fi
    ''}

    # Environment used by the Homebrew installer and by every brew call below.
    export HOMEBREW_PREFIX="$BREW_PREFIX"
    export HOMEBREW_CELLAR="$BREW_PREFIX/Cellar"
    export HOMEBREW_REPOSITORY="$BREW_PREFIX/Homebrew"
    export HOMEBREW_CURL_PATH="${pkgs.curl}/bin/curl"
    export HOMEBREW_GIT_PATH="${brewGit}"
    ${extraEnvExports}
    if [ -f "${githubTokenPath}" ]; then
      export HOMEBREW_GITHUB_API_TOKEN="$(${pkgs.coreutils}/bin/cat "${githubTokenPath}")"
    fi

    # Bootstrap Homebrew on first activation.
    if [ ! -x "$BREW_PREFIX/bin/brew" ]; then
      echo "Installing Homebrew to $BREW_PREFIX..."
      export PATH="${lib.makeBinPath installerDeps}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH"
      NONINTERACTIVE=1 ${pkgs.bash}/bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      if [ ! -x "$BREW_PREFIX/bin/brew" ]; then
        echo "Error: Homebrew installer did not produce $BREW_PREFIX/bin/brew" >&2
        exit 1
      fi
    fi

    # Runtime PATH for the brew invocations below.
    export PATH="${lib.makeBinPath runtimeDeps}:$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"

    # Add taps (continue on failure).
    ${lib.concatStringsSep "\n" (
      map (tap: ''
        if ! "$BREW_PREFIX/bin/brew" tap | ${pkgs.gnugrep}/bin/grep -q "^${tap}$"; then
          echo "Adding tap: ${tap}"
          "$BREW_PREFIX/bin/brew" tap "${tap}" || echo "Warning: Failed to add tap ${tap}"
        fi
      '') cfg.taps
    )}

    # Install and link formulae (continue on failure).
    ${lib.concatStringsSep "\n" (
      map (formula: ''
        if ! "$BREW_PREFIX/bin/brew" list "${formula}" &>/dev/null; then
          echo "Installing formula: ${formula}"
          "$BREW_PREFIX/bin/brew" install "${formula}" || echo "Warning: Failed to install ${formula}"
        fi
        "$BREW_PREFIX/bin/brew" link --overwrite "${formula}" 2>/dev/null || true
      '') cfg.brews
    )}

    # Install casks (continue on failure).
    ${lib.concatStringsSep "\n" (
      map (cask: ''
        if ! "$BREW_PREFIX/bin/brew" list --cask "${cask}" &>/dev/null; then
          echo "Installing cask: ${cask}"
          "$BREW_PREFIX/bin/brew" install --cask "${cask}" || echo "Warning: Failed to install cask ${cask}"
        fi
      '') cfg.casks
    )}

    # Optionally install a compiler for building formulae from source.
    ${lib.optionalString cfg.ensureCompiler ''
      if ! "$BREW_PREFIX/bin/brew" list llvm &>/dev/null; then
        echo "Installing LLVM (compiler toolchain for building from source)..."
        "$BREW_PREFIX/bin/brew" install llvm || echo "Warning: Failed to install LLVM"
      fi
    ''}

    echo "Homebrew setup complete!"
  '';
in
{
  imports = [
    # Owns enableSystemSetup/brewPrefix/owner/compatSymlinks and does the
    # root-level directory + compat symlink setup at activation time.
    inputs.nix-linuxbrew.nixosModules.default
  ];

  options.programs.linuxbrew = {
    taps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "homebrew/cask"
        "myorg/mytap"
      ];
      description = "List of Homebrew taps to add.";
    };

    brews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "hello"
        "wget"
        "jq"
      ];
      description = "List of Homebrew formulae to install.";
    };

    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "firefox"
        "visual-studio-code"
      ];
      description = "List of Homebrew casks to install.";
    };

    ensureCompiler = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Automatically install LLVM for building formulae from source.
        Set to false when every declared formula ships a bottle, to avoid a
        lengthy LLVM build on every activation.
      '';
    };

    githubApiTokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Optional path to a file containing a GitHub API token for Homebrew
        to reduce API rate limiting.
      '';
    };

    extraBrewEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        HOMEBREW_NO_ANALYTICS = "1";
      };
      description = "Extra environment variables to export before running brew.";
    };

    allowContainerInstall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "When false, skip Homebrew installation inside Docker/LXC containers.";
    };
  };

  config = lib.mkIf cfg.enableSystemSetup {
    # Runs after nix-linuxbrew's "linuxbrew" script (uses "./linuxbrew"
    # directory + symlinks).
    system.activationScripts.linuxbrew-install = {
      text = ''
        echo "Running Homebrew setup..."
        ${linuxbrewInstallScript}
      '';
      deps = [ "linuxbrew" ];
    };

    # System-wide integration: PATH for every shell (incl. Fish, which does
    # not read /etc/profile) plus the env vars so the manual `brew install`
    # users run uses Nix's curl/git and resolves against the shared prefix.
    environment.sessionVariables = {
      PATH = [
        "${brewPrefix}/bin"
        "${brewPrefix}/sbin"
      ];
      HOMEBREW_PREFIX = brewPrefix;
      HOMEBREW_CELLAR = "${brewPrefix}/Cellar";
      HOMEBREW_REPOSITORY = "${brewPrefix}/Homebrew";
      HOMEBREW_CURL_PATH = "${pkgs.curl}/bin/curl";
      HOMEBREW_GIT_PATH = brewGit;
    };
  };
}
