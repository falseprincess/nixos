#
#   _____          ____                    __  _                  _     
#  / ___/__  ___  / _(_)__ ___ _________ _/ /_(_)__  ___    ___  (_)_ __
# / /__/ _ \/ _ \/ _/ / _ `/ // / __/ _ `/ __/ / _ \/ _ \_ / _ \/ /\ \ /
# \___/\___/_//_/_//_/\_, /\_,_/_/  \_,_/\__/_/\___/_//_(_)_//_/_//_\_\ 
#                   /___/                                              
# 
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
#
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable grub
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub.enable = true;
    grub.devices = [ "nodev" ];
    grub.efiSupport = true;
    grub.useOSProber = true;
    grub.backgroundColor = "#D8DEE9";
    grub.configurationLimit = 10;
    grub.splashImage = /home/sudozelda/Pictures/Wallpapers/nix.png;
  };

  # Kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelParams = [ "nomodeset" ];
  boot.kernelModules = [ "fuse" ];

  # Udev rules.
  services.udev = {
  packages = [ pkgs.android-udev-rules ];
  extraRules = ''
  # Allow user access to some USB devices.
  SUBSYSTEM=="usb", ATTR{idVendor}=="04e6", ATTR{idProduct}=="e001", TAG+="uaccess", RUN{builtin}+="uaccess"
  ''; 
  };
  # Enable adb.
  programs.adb.enable = true;

  # Network.
  networking.networkmanager.enable = true;
  networking.hostName = "NixBox"; # Define your hostname.

  # Wireguard
  networking.wireguard.enable = true;
  # networking.iproute2.enable = true; # Needed for mullvad daemon
  # services.mullvad-vpn.enable = true;

  # Timezone.
  time.timeZone = "America/Boise";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Xorg, Keyboard and Nvidia.
  services.xserver = {
  enable = true; 
  autorun = true;
  layout = "us";
  displayManager.startx.enable = true;
  windowManager.berry.enable = true;
  videoDrivers = [ "nvidia" "modesetting" ];   
  };

  # Bash configuration.
  programs.bash = {
  # Start neofetch, and auto startx at tty1
  shellInit = "if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then exec startx; fi";
  shellAliases = {
  # ls aliases  
  l = "ls -alh";
  ll = "ls -l";
  ls = "ls --color=tty";
  # Nixos related aliases.
  edit-nix = "sudo vim /etc/nixos/configuration.nix";
  nix-i = "nix-env -iA";
  nix-d = "nix-env -e";
  };  
  # Enable extra colors in directory listings.
  enableLsColors = true;
  # Enable Bash completion for all interactive bash shells.
  enableCompletion = true;
  };

  # Audio. 
  sound.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio = {
  enable = true;
  support32Bit = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sudozelda = {
    isNormalUser = true;
    home = "/home/sudozelda";
    description = "Sudozelda";
    extraGroups = [ 
      "wheel" "sudoers" "adbusers" "networkmanager" "video" "audio" 
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl 
    git
    vim
    udisks2
    udiskie
    nitrogen
    htop
    polybarFull
    neofetch
    xorg.xinit
    wireguard 
    wireguard-tools
    xdg-user-dirs
    ungoogled-chromium
  ];

  # Enabling some fonts for my user.
  fonts.fonts = with pkgs; [
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  liberation_ttf
  siji
  font-awesome-ttf
  dina-font
  ];

  # Use librsvg's gdk-pixbuf loader cache file as it enables gdk-pixbuf to load SVG files (important for icons)
  environment.sessionVariables = {
    GDK_PIXBUF_MODULE_FILE = "$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)";
  };

  # Enable steam.
  # programs.steam.enable = true;

  # Enabling unfree packages system-wide.
  nixpkgs.config.allowUnfree = true;

  # some programs need suid wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

