# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/home-manager/home.nix)
{ config, pkgs, lib, inputs, ... }:

{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule
    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  # FIXME Set your username
  home = {
    username = "vee";
    homeDirectory = "/home/vee";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];
  home.packages = with pkgs; [
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Adrian";
    userEmail = "adrian@adrian.com";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
