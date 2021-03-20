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

  # Enabling the bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Network.
  networking.networkmanager.enable = true;
  networking.hostName = "NixBox"; # Define your hostname.

  # Wireguard
  networking.wireguard.enable = true;
  networking.iproute2.enable = true; # Needed for mullvad daemon
  services.mullvad-vpn.enable = true;

  # Timezone.
  time.timeZone = "America/Boise";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = false;
  # networking.interfaces.eno1.useDHCP = true;
  # networking.interfaces.wlp4s0.useDHCP = true;

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
  windowManager.herbstluftwm.enable = true;
  videoDrivers = [ "nvidia" "modesetting" ];   
  };
  
  # Audio. 
  sound.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio = {
  enable = true;
  support32Bit = true;
  package = pkgs.pulseaudioFull;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sudozelda = {
    isNormalUser = true;
    home = "/home/sudozelda";
    description = "Sudozelda";
    extraGroups = [ "wheel" "sudoers" "networkmanager" "video" "audio" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl 
    git
    vim
    nitrogen
    htop
    alsaTools
    neofetch
    xorg.xinit
    mullvad-vpn
    xdg-user-dirs
    palemoon
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
 programs.steam.enable = true;

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

