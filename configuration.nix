{ config, inputs, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    config.common.default = "kde";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; 

  # Enable networking
  networking.networkmanager = {
    enable = true;

    # Uncomment if network issue persists.
    # wifi.scanRandMacAddress = false;
    # wifi.macAddress = "permanent";
    # ethernet.macAddress = "permanent"; 
    
    wifi.powersave = false;
  };

  networking.firewall.allowedTCPPorts = [ 3000 5173 ]; # Node + Vite ports

  #Enable docker
  virtualisation.docker.enable = true;

  #For nixbuild.net servers
  #https://nixbuild.net/get-started
  programs.ssh.extraConfig = ''
  Host eu.nixbuild.net
  PubkeyAcceptedKeyTypes ssh-ed25519
  ServerAliveInterval 60
  IdentityFile /home/shreyas/.ssh/id_ed25519
  '';

  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      { hostName = "eu.nixbuild.net";
        system = "x86_64-linux";
        maxJobs = 100;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
    ];
  };

  time.timeZone = "Asia/Kolkata";

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # (Optional) Enable PipeWire for Bluetooth audio
  services.pulseaudio.enable = false;

  i18n.defaultLocale = "en_US.UTF-8";

  #NVIDIA
  # Enable OpenGL
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = { 
      amdgpuBusId = "PCI:6:0:0"; 
      nvidiaBusId = "PCI:1:0:0"; 
      # Enable On-Demand Mode
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Natural scroll on X11:-
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;

  #Enable Redis
  services.redis.servers.default = {
	  enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shreyas = {
    isNormalUser = true;
    description = "Shreyas";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "vboxusers"];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  #For vscode
  programs.nix-ld.enable = true;

  #more docs?
  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
  #compilers
  gcc
  python314
  clang-tools
  vtsls
  #LSP
  lua-language-server
  nil

  spotify
  google-chrome
  libreoffice
  obs-studio
  mpv #media-player
  cheese
  onlyoffice-desktopeditors
  easyeffects

  #devtools
  neovim
  git
  tmux
  docker-compose
  man
  man-pages
  man-pages-posix
  direnv
  ghidra
  vscode
  curl

  #webdev
  nodejs
  eslint
  eslint_d
  prettier

  xclip
  wl-clipboard
  ripgrep #for telescope.nvim
  alacritty
  starship
  xhost #for graphics perms
  unzip
  pciutils

  ];


  system.stateVersion = "25.05"; 

}
