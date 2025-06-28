{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # Enable MangoHud with session-wide support
  programs.mangohud = {
    enable = true;
    # enableSessionWide = true; # Allows MangoHud in all apps (not just games)
  };
  # Configure MangoHud (creates ~/.config/MangoHud/MangoHud.conf)
  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    ### CPU Metrics
    cpu_stats
    cpu_temp
    cpu_mhz
    cpu_text=CPU

    ### GPU Metrics
    gpu_stats
    gpu_temp
    gpu_junction_temp
    gpu_mem_temp
    gpu_power
    vram
    gpu_core_clock
    gpu_mem_clock
    gpu_text=GPU

    ### System/FPS
    fps
    frametime
    ram
    fsr
    wine
    winesync
    gamemode
    background_alpha=0.4
    round_corners=10

    ### Appearance
    position=top-left
    table_columns=6
    toggle_hud=Shift_R+F12
  '';
}
