{ config, pkgs, ... }:

# Test push to GitHub 

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # 1. Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #hardware.graphics.enable = true;
  boot.kernelModules = [ "coretemp" "dell-smm-hwmon" ];

  # 1.1 mount thunar can go win
  services.udisks2.enable = true;
  security.polkit.enable = true;
  fileSystems."/mnt/win_data" = {
    device = "/dev/sda3";
    fsType = "ntfs3";
    options = [ "nofail" "rw" "uid=1000" "force" ];
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # สำคัญสำหรับการเล่นเกมหรือรันโปรแกรม 32-bit
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # 1.2 system auto delete nix rollback
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

# 1.3 เปลี่ยน Shell เป็น Zsh เพื่อให้มีสีตอนพิมพ์คำสั่ง
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

      interactiveShellInit = ''
      # ตั้งค่าสี Prompt ให้เป็น Dracula (ม่วง-ฟ้า)
      export PROMPT='%F{141}%n%f@%F{147}%m%f:%F{81}%~%f$ '
      
      # ตั้งค่า alias ให้ ls มีสีเสมอ
      alias ls='ls --color=auto'
      alias ll='ls -la'
    '';
  };
  # Test push to GitHub
  # 1.4 backup github auto
 environment.shellAliases = {
   nix-save = "bash /etc/nixos/scripts/backup.sh";
};

  # 2. Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # 3. Time zone and Locale
  time.timeZone = "Asia/Bangkok";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "th_TH.UTF-8";
    LC_IDENTIFICATION = "th_TH.UTF-8";
    LC_MEASUREMENT = "th_TH.UTF-8";
    LC_MONETARY = "th_TH.UTF-8";
    LC_NAME = "th_TH.UTF-8";
    LC_NUMERIC = "th_TH.UTF-8";
    LC_PAPER = "th_TH.UTF-8";
    LC_TELEPHONE = "th_TH.UTF-8";
    LC_TIME = "th_TH.UTF-8";
  };

  # 4. X11 and Desktop
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      dmenu i3status i3lock
    ];
  };

  # 5. Layout
  services.xserver.xkb = {
    layout = "us,th";
    variant = ",";
    options = "grp:ctrl_space_toggle";
  };

  # 6. Nvidia Driver 470.256.02 (Dell Inspiron 7447 / GTX 850M / i7 Gen4)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:10:0:0";
    };
  };

  # 6.1 Thunar drive & Samba
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  networking.firewall.allowPing = true;
  services.samba.enable = true;
  services.thermald.enable = true;

  # 7. เสียง
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
   services.power-profiles-daemon.enable = false;

   services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    }; # อันนี้ปิด settings
  };   # อันนี้ปิด services.tlp

  # 8. Programs
  environment.systemPackages = with pkgs; [
    firefox
    pkgs.librewolf
    kdePackages.kate
    alacritty
    arandr
    rofi
    psmisc
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    lxappearance
    pavucontrol
    samba
    cifs-utils
    flameshot
    polkit_gnome
    fastfetch
    veracrypt
    picom
    feh
    git
    pkgs.chromium
    lm_sensors
    mpv
    obsidian
 
    google-fonts
    noto-fonts
    noto-fonts-cjk-sans
    font-awesome
  ];

  # 9. Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome_6
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.symbols-only
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Serif" "Noto Serif Thai" ];
      sansSerif = [ "Noto Sans" "Noto Sans Thai" "DejaVu Sans" ]; # เพิ่ม DejaVu กันเหนียว
      monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
    };

    antialias = true;
    hinting = {
      enable = true;
      style = "slight"; # ทำให้เส้นฟอนต์ไทยไม่บางจนเกินไป
    };
    subpixel = {
      rgba = "rgb"; # สำหรับหน้าจอ LCD ทั่วไปจะทำให้ตัวหนังสือคมขึ้น
      lcdfilter = "default";
    };
  };
  # 10. User Account
  users.users.nixka = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "nixka";
    extraGroups = [ "wheel" "networkmanager" "video" "storage" "disk" ];
  };

  system.stateVersion = "24.11";

    # --- Home Manager ---
    home-manager.backupFileExtension = "backup";
    home-manager.users.nixka = { pkgs, lib, ... }: {
    home.stateVersion = "25.11"; 
    home.enableNixpkgsReleaseCheck = false;
    
    # ติดตั้ง polybar ที่มี i3 + pulse support ใน home-manager
    home.packages = with pkgs; [
      (polybar.override { 
        i3Support = true;
        pulseSupport = true;
      })
    ]; 
   # ตัวอย่างการตั้งค่าสีใน Alacritty ผ่าน Home Manager
      programs.alacritty.settings = {
         colors = {
            primary = {
       background = "#282a36";
       foreground = "#f8f8f2";
     };
     normal = {
       black =   "#21222c";
       red =     "#ff5555";
       green =   "#50fa7b";
       yellow =  "#f1fa8c";
       blue =    "#bd93f9";
       magenta = "#ff79c6";
       cyan =    "#8be9fd";
       white =   "#f8f8f2";
     };
   };
 };
    xsession.windowManager.i3 = {
      enable = true;
      config = null;
      extraConfig = ''
        set $mod Mod1
        font pango:JetBrainsMono Nerd Font 8

        bindsym $mod+Shift+e exec --no-startup-id "echo -e 'Logout\nReboot\nShutdown' | rofi -dmenu -p 'Power Menu:' -i | xargs -I{} bash -c 'case {} in Logout) i3-msg exit;; Reboot) systemctl reboot;; Shutdown) systemctl poweroff;; esac'"

        # Keybindings
        bindsym $mod+c exec alacritty
        bindsym $mod+q kill
        bindsym $mod+d exec rofi -show drun
        bindsym $mod+z exec thunar
        bindsym $mod+x exec librewolf
        bindsym $mod+Shift+c reload
        bindsym Print exec flameshot gui
        bindsym $mod+Shift+r restart
        
        # Focus
        bindsym $mod+h focus left
        bindsym $mod+j focus down
        bindsym $mod+k focus up
        bindsym $mod+l focus right
        # Focus with arrow
        bindsym $mod+Left focus left
        bindsym $mod+Down focus down
        bindsym $mod+Up focus up
        bindsym $mod+Right focus right
        # Focus move
        bindsym $mod+Shift+Left move left
        bindsym $mod+Shift+Down move down
        bindsym $mod+Shift+Up move up
        bindsym $mod+Shift+Right move right
       
        # Stacked and Tabbed Layout
        bindsym $mod+s layout stacking
        bindsym $mod+w layout tabbed
        # Toggle Spliit
        bindsym $mod+e layout toggle split
        bindsym $mod+b split h
        bindsym $mod+v split v 

        # Floating
        bindsym $mod+Shift+space floating toggle
        floating_modifier $mod        

        # work space
        bindsym $mod+1 workspace number 1
        bindsym $mod+2 workspace number 2
        bindsym $mod+3 workspace number 3
        bindsym $mod+4 workspace number 4
        bindsym $mod+5 workspace number 5
        bindsym $mod+6 workspace number 6
        bindsym $mod+7 workspace number 7
        bindsym $mod+8 workspace number 8
        bindsym $mod+9 workspace number 9
        bindsym $mod+0 workspace number 10

        # --- move  Workspaces (Shift + Number) ---
        bindsym $mod+Shift+1 move container to workspace number 1
        bindsym $mod+Shift+2 move container to workspace number 2
        bindsym $mod+Shift+3 move container to workspace number 3
        bindsym $mod+Shift+4 move container to workspace number 4
        bindsym $mod+Shift+5 move container to workspace number 5
        bindsym $mod+Shift+6 move container to workspace number 6
        bindsym $mod+Shift+7 move container to workspace number 7
        bindsym $mod+Shift+8 move container to workspace number 8
        bindsym $mod+Shift+9 move container to workspace number 9
        bindsym $mod+Shift+0 move container to workspace number 10

        # All Auto Start
        exec_always --no-startup-id bash /home/nixka/.screenlayout/monitor.sh
        exec_always --no-startup-id systemctl --user restart polybar
        exec --no-startup-id nm-applet
        exec --no-startup-id /run/current-system/sw/libexec/polkit-gnome-authentication-agent-1 &
        exec_always --no-startup-id feh --bg-fill --randomize --slideshow-delay 500 /home/nixka/Downloads/wallpaper/
       
        gaps inner 15
        gaps outer 10
        for_window [class=".*"] border pixel 0

        mode "resize" {
            bindsym h resize shrink width 10 px or 10 ppt
            bindsym j resize grow height 10 px or 10 ppt
            bindsym k resize shrink height 10 px or 10 ppt
            bindsym l resize grow width 10 px or 10 ppt
           
            bindsym Left resize shrink width 10 px or 10 ppt
            bindsym Down resize grow height 10 px or 10 ppt
            bindsym Up resize shrink height 10 px or 10 ppt
            bindsym Right resize grow width 10 px or 10 ppt

            bindsym Return mode "default"
            bindsym Escape mode "default"
        }
        bindsym $mod+a mode "resize"
      '';
    };

     services.picom = {
    enable = true;
    backend = "glx"; # หรือใช้ "glx" ถ้าเครื่องมี GPU และอยากให้ลื่นขึ้น
    vSync = true;
    settings = {
      glx-no-stencil = true;
      glx-no-rebind-pixmap = true;
      corner-radius = 12;
      round-borders = 1;
      active-opacity = 1.0;
      inactive-dim = 0.15; 
      inactive-opacity = 0.90;

       opacity-rule = [
      "100:class_g = 'librewolf' && fullscreen"
      "100:class_g = 'LibreWolf' && fullscreen"
      
      "97:class_g = 'librewolf' && !fullscreen"
      "97:class_g = 'LibreWolf' && !fullscreen"
      
      "97:class_g = 'Thunar'"
      "85:class_g = 'Alacritty'"
      ];
      detect-client-opacity = true;
      detect-transient = true;
      use-damage = true;
    };
  };

     services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };
      script = "pkill polybar; polybar mybar &";
      config = {
        "bar/mybar" = {
          # --- ตั้งค่าความโปร่งใสหลัก ---
          height = "22pt";
          radius = 0;
          background = "#00000000";
          foreground = "#F8F8F2";
          width = "100%";
          
          # ระยะห่างจากขอบจอ (เพื่อให้ดูเหมือนลอย)
          border-size = "4pt";
          border-color = "#00000000";

          padding-left = 30;
          padding-right = 25;
          module-margin = 1;

          font-0 = "JetBrainsMono Nerd Font:size=9;2";
          font-1 = "Noto Color Emoji:scale=10;2";
          font-2 = "Symbols Nerd Font Mono:size=10;2";

          modules-left = "cpu memory temperature disk";
          modules-center = "i3";
          modules-right = "pulseaudio xkeyboard date";

          tray-position = "right";
          
          scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
          scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
        };

        # --- ส่วนกลาง: ตัวเลข Workspace แบบมีกล่องล้อมรอบ (สไตล์ในรูป) ---
        "module/i3" = {
          type = "internal/i3";
          format = "<label-state> <label-mode>";
          pin-workspaces = true;
          show-urgent = true;
          enable-click = true;
          enable-scroll = true;          
          index-sort = true;

          # ตัวเลขที่เลือก (Focused)
          label-focused = " %index% ";
          label-focused-background = "#6272A4"; # สีม่วงน้ำเงินเข้ม
          label-focused-foreground = "#FFFFFF";
          label-focused-underline = "#FF79C6";    # เส้นใต้ชมพู
          label-focused-padding = 2;

          # ตัวเลขที่ไม่ได้เลือก
          label-visible = " %index% ";
          label-visible-padding = 2;
          label-unfocused = " %index% ";
          label-unfocused-background = "#282A36"; # สีเทาเข้ม
          label-unfocused-padding = 2;
        };
        "module/cpu" = {
         type = "internal/cpu";
         interval = 2; # เพิ่มช่วงเวลาการอัปเดต (วินาที)
  
          warn-percentage = 80;

          format = "<label>";
          format-background = "#282A36";
          format-padding = 2;
          label = "🧠 %percentage%%";
          label-foreground = "#BD93F9"; # สีม่วงอ่อนปกติ

          format-warn = "<label-warn>";
          format-warn-background = "#282A36";
          format-warn-padding = 2;
          label-warn = "🧠 %percentage%%";
          label-warn-foreground = "#FF5555"; # สีแดง (Dracula Red)
        };
        "module/memory" = {
          type = "internal/memory";
          interval = 3; # อัปเดตทุก 3 วินาที
          warn-percentage = 80;

          format = "<label>";
          format-background = "#282A36";
          format-padding = 2;
          label = "🐏 %gb_used:1:5%/%gb_total:1:5%";
         #label = "🐏 %percentage_used%%";
         #label = "🐏 %used%/%total%";
          label-foreground = "#50FA7B"; # สีเขียว (Dracula Green)

          format-warn = "<label-warn>";
          format-warn-background = "#282A36";
          format-warn-padding = 2;
          label-warn = "🐏 %gb_used:1:5%/%gb_total:1:5%";     
         #label-warn = "🐏 %used%/%total%"; 
         #label-warn = "🐏 %percentage_used%%";
          label-warn-foreground = "#FF5555"; # สีแดง (Dracula Red)
        };
        
        "module/temperature" = {
          type = "internal/temperature";
          interval = 2;  # อัพเดททุก 2 วินาที
          thermal-zone = 4;  # ใช้ thermal zone แรก (CPU)
          warn-temperature = 80;  # เตือนเมื่อร้อนเกิน 70°C
          
          format = "<label>";
          format-background = "#282A36";
          format-padding = 2;
          label = "🔥 %temperature-c%";
          label-foreground = "#F1FA8C";
          
          format-warn = "<label-warn>";
          format-warn-background = "#282A36";
          format-warn-padding = 2;
          label-warn = "🔥 %temperature-c%";
          label-warn-foreground = "#FF5555";
        };

        "module/disk" = {
          type = "internal/fs";
          mount-0 = "/";
          format-mounted-background = "#282A36";
          format-mounted-padding = 2;
          label-mounted = "📦 %free%";
          label-mounted-foreground = "#8BE9FD"; # สีฟ้า
        };

        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          use-ui-max = true;
          interval = 5;

          format-volume = "<label-volume>";
          format-volume-background = "#282A36";
          format-volume-padding = 2;
          label-volume = "📣 %percentage%%";
          label-volume-foreground = "#FFB86C"; # สีส้ม
       
          format-muted = "<label-muted>";
          label-muted = "🔇";
          label-muted-foreground = "#6272A4";
          label-muted-background = "#282A36";
          label-muted-padding = 2;
        };

        "module/xkeyboard" = {
          type = "internal/xkeyboard";
          format-background = "#282A36";
          format-padding = 2;
          label-layout = "👾%layout%";
          label-layout-foreground = "#FF79C6"; # สีชมพู
        };

         "module/date" = {
          type = "internal/date";
          interval = 1;
          date = "%a %d %b %Y ⌛ %H:%M:%S"; 
         #date = "%a %d %b %Y  📅 %H:%M:%S";
          format-background = "#282A36";
          format-padding = 2;
          label = "%date%";
          label-foreground = "#F8F8F2";
        };
      };
    };
  };
}
