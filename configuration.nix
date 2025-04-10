{ lib, config, pkgs, ... }:

let 
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz;
  nixos-hardware = builtins.fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
in
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
        # We use the VSCode package to configure vscodium
        "hello-unfree" 
    ];

  imports =
    [
      (import "${nixos-hardware}/lenovo/thinkpad/p50")
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  console.useXkbConfig = true;

  services.xserver = {
    enable = true;
    
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    xkb = {
      layout = "us";
      variant = "";

      # Needs to be run afterwards manually
      # gsettings reset org.gnome.desktop.input-sources xkb-options
      #	gsettings reset org.gnome.desktop.input-sources sources
      options = "caps:escape";
    };
  };

  hardware = {
    pulseaudio.enable = false;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.defaultUserShell = pkgs.fish;
  users.users.hermanno = {
    isNormalUser = true;
    description = "hermanno";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };
  home-manager.useGlobalPkgs = true;
  home-manager.users.hermanno = { pkgs, ... }: {
    # We install VSCodium using the VSCode package,
    # but point to VSCodium. This allows us to configure
    # It to correctly use keyboard configuration from xkb
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
	ms-python.python
	jnoortheen.nix-ide
	elixir-lsp.vscode-elixir-ls
	foxundermoon.shell-format
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
	{
          name = "srcery-colors";
          publisher = "srcery-colors";
          version = "0.3.8";
          sha256 = "f550d8aa662ee238ab8d61996af4aa18cd94dfa271170caa11e5e12625ccbd18";
	}
      ];
      userSettings = {
        "keyboard.dispatch" = "keyCode";	
	# "workbench.colorTheme" = "";
	# Disable top bar 
	"window.titleBarStyle" = "custom";
	"editor.titleBar.enabled" = false;
	# Minimalist shit
	"breadcrumbs.enabled" = false;
	"editor.minimap.enabled" = false;
	"editor.renderLineHighlight" = "gutter";
  	"workbench.activityBar.visible" = false;
	"workbench.tree.indent" = 10;
	# Theme
	"workbench.colorTheme" = "Srcery";
      };
    };

    home.stateVersion = "24.11";
  };

  programs = {
    thefuck = {
      enable = true;
    };
    dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              enable-animations = false; 
            };
          };
        }
      ];
    };
    git = {
      enable = true;
    };
    vim = {
      enable = true;
      defaultEditor = true;
    };
    fish = {
      enable = true;
      vendor = {
        completions.enable = true; 
        config.enable = true; 
        functions.enable = true; 
      };
    };


  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    ERL_AFLAGS = "-kernel shell_history enabled"; # iex shell history
  };
  
  environment.systemPackages = with pkgs; [
    
    # LIBRE
    librewolf
    signal-desktop
    ghostty

    # TERMINAL TROVE
    # https://terminaltrove.com/list/
    wtfis 
    btop
    fzf

    # Elixir
    elixir

    # Python
    python314
    poetry
    
    # CLI shit
    gh
    
    # Tools
    gnumake
    tree
    
    # Closed source gui
    _1password-gui
    spotify
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
