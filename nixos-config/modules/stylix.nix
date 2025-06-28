{ pkgs, ... }:

{
  stylix.enable = true;
  stylix.autoEnable = true;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.cursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };
  stylix.fonts = {
    serif = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font";
    };

    sansSerif = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font";
    };

    monospace = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font Mono";
    };

    emoji = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font Mono";
    };
  };
  stylix.opacity = {
    terminal = 0.85;
    desktop = 0.85;
  };
  stylix.targets.fish.enable = false;
  home-manager.users."vee" = {
    stylix.targets.ghostty.enable = false;
    stylix.targets.neovim.enable = false;
  };
}
