{ config, pkgs, ... }:

# ========================================
# NixOS Configuration - Portable
# ========================================
# สำหรับ: Dell Inspiron 7447
# CPU: i7-4700HQ | GPU: GTX 850M | RAM: 8GB
# 
# ⚠️ IMPORTANT: ห้ามใช้ hardware-configuration.nix ข้ามเครื่อง!
# ต้อง generate ใหม่ทุกครั้งที่ติดตั้ง
#
# Quick Restore: ดู README.md
# ========================================

{
  imports = [
    ./hardware-configuration.nix  # ← ไฟล์นี้ห้าม commit!
     "${builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz"}/nixos"
  ];

  # 1. Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "coretemp" "dell-smm-hwmon" ];
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "2G"; 
  programs.dconf.enable = true;

  # Kernel parameters เพื่อประหยัด RAM
  boot.kernelParams = [
      "elevator=kyber"
      #"snd_hda_intel.power_save=0"
      #"transparent_hugepage=madvise"
      "nvidia.NVreg_DynamicPowerManagement=0x02" 
      #"intel_pstate=disable"
      "mitigations=off"  # ปิด security mitigations เพื่อประสิทธิภาพ (ไม่แนะนำถ้าเชื่อมต่อ internet โดยตรง)
  ];
  
  # Optimize swap usage
  boot.kernel.sysctl = {
    "vm.swappiness" = 50;           # ลดการใช้ swap (ค่า default = 60)
    "vm.vfs_cache_pressure" = 50;   # ลดการ cache ที่ไม่จำเป็น
    "vm.dirty_ratio" = 10;          # ลดการใช้ RAM สำหรับ write cache
    #"vm.dirty_background_ratio" = 5;
    #"vm.dirty_writeback_centisecs" = 1500;
    #"kernel.nmi_watchdog" = 0;
  };

  environment.variables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    "WEBKIT_DISABLE_COMPOSITING_MODE" = "1";
    "LIBVA_DRIVER_NAME" = "i965";
    "MOZ_DISABLE_RDD_SANDBOX" = "1";
  };

    environment.sessionVariables = {
    "MOZ_USE_XINPUT2" = "1";
    "MOZ_ENABLE_WAYLAND" = "0";
    "MOZ_WEBRENDER" = "1";
    "MOZ_X11_EGL" = "1";
    "MOZ_ACCELERATED" = "1";
    "LIBVA_DRIVER_NAME" = "i965";
    "VDPAU_DRIVER" = "va_gl";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # สำคัญสำหรับการเล่นเกมหรือรันโปรแกรม 32-bit
    extraPackages = with pkgs; [
      libvdpau-va-gl
      libva-vdpau-driver
      intel-vaapi-driver
      intel-media-driver
    ];
  };

  # 1.2 system auto delete nix rollback
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };
    nix.settings.auto-optimise-store = true;
    boot.loader.systemd-boot.configurationLimit = 5;  

   zramSwap = {
    enable = true;
    memoryPercent = 60;  # ใช้ 50% ของ RAM (8GB → มี zram 4GB)
    algorithm = "zstd";   # อัลกอริทึมบีบอัดที่เร็ว
    priority = 10;       # ให้ใช้ zram ก่อน swap ปกติ
  };

  # earlyoom - ป้องกันระบบแฮงเมื่อ RAM เต็ม
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;  # เริ่มทำงานเมื่อ RAM เหลือ 5%
    freeSwapThreshold = 10; # เริ่มทำงานเมื่อ Swap เหลือ 10%
  };

# 1.3 เปลี่ยน Shell เป็น Zsh เพื่อให้มีสีตอนพิมพ์คำสั่ง
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

      ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "kubectl" ];
      theme = "agnoster"; # ธีมยอดนิยม (หรือจะใช้ "robbyrussell" ซึ่งเป็นค่าเริ่มต้น)
    };

    interactiveShellInit = ''
      alias ls='ls --color=auto'
      alias ll='ls -la'
      export COLORTERM=truecolor
      export TERM=xterm-256color
    '';
  };
  # Test push to GitHub
  # 1.4 backup github auto
 environment.shellAliases = {
   nix-save = "sudo bash /etc/nixos/scripts/backup.sh";
 };
  
 services.flatpak.enable = true;
 xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  }; 
 
  # 1.5 SSD Optimization
  services.fstrim.enable = true;
  services.fstrim.interval = "weekly"; # ทำงานสัปดาห์ละครั้ง

  # 2. Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

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
  
  # Display Manager - ใช้ LightDM แทน SDDM (เบากว่า ไม่ต้องพึ่ง KDE)
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.enable = true;
  
  # Window Manager - i3 เท่านั้น
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      dmenu i3status i3lock
    ];
  };

  services.xserver.displayManager.defaultSession = "none+i3";

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
    
    # เพิ่ม power management เพื่อลดความร้อน
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    nvidiaPersistenced = false;    

    prime = {
     #sync.enable = true;
      offload.enable = true;
      offload.enableOffloadCmd = false;  # เพิ่มคำสั่ง nvidia-offload
      reverseSync.enable = false;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:10:0:0";
    };
  };

  # 6.1 Thunar drive & Samba
  services.gvfs.enable = true;      # ปิดถ้าไม่ mount network drives (ประหยัด ~80MB)
  services.tumbler.enable = true;   # ปิดถ้าไม่ใช้ thumbnail preview (ประหยัด ~50MB)
  networking.firewall.allowPing = true;
  # services.samba.enable = true;  # ปิดถ้าไม่ได้แชร์ไฟล์ (ประหยัด ~100MB)
  services.thermald.enable = true;

  # 7. เสียง
  # services.printing.enable = true;  # ปิดถ้าไม่มี printer (ประหยัด ~50MB)
  # services.pulseaudio.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
   services.power-profiles-daemon.enable = false;
   security.rtkit.enable = true;

   services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_MAX_FREQ_ON_AC = 3200000;  # จำกัดไว้ที่ 2.4GHz
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_BOOST_ON_AC = 1;
      CPU_MAX_PERF_ON_AC = 80;
      #CPU_MIN_PERF_ON_AC = 0;           # ให้ลดได้ถึง 0% เมื่อไม่ใช้งาน
      #SCHED_POWERSAVE_ON_AC = 0;        # ไม่รวม tasks (ให้กระจาย core)
      #NMI_WATCHDOG = 0; 
      RUNTIME_PM_ON_AC = "on";
    }; # อันนี้ปิด settings
  };   # อันนี้ปิด services.tlp

  # 8. Programs
  environment.systemPackages = with pkgs; [
    firefox
    # pkgs.librewol
    # pkgs.luakidt     
    xfce.mousepad  
    alacritty
    arandr
    rofi
    psmisc
    xfce.thunar
    # xfce.thunar-archive-plugin  # ปิดถ้าไม่จำเป็น
    # xfce.thunar-volman          # ปิดถ้าไม่จำเป็น
    lxappearance
    pavucontrol
    # samba  # ย้ายไปอยู่ใน services แล้ว
    # cifs-utils      # ปิดถ้าไม่ mount Windows shares
    flameshot
    lxqt.lxqt-policykit
    fastfetch
    veracrypt     
    picom
    feh
    git
    lm_sensors
    mpv
    zip
    nodejs_20
    playwright-driver.browsers
    xarchiver 
    pkgs.bottles
    pulseaudio
    pamixer
    papirus-icon-theme
    gnome-themes-extra
    adwaita-icon-theme
    wireplumber
    pkgs.chromium    
    matcha-gtk-theme 
    papirus-icon-theme
    bibata-cursors  

    # Fonts - ลดจำนวน fonts ลง
    noto-fonts
    noto-fonts-cjk-sans
    font-awesome
  ];


    environment.shellAliases = {
    # อันนี้คือคำสั่งสั้นๆ (Aliases)
    extract = "7z x";
    compress = "7z a -t7z -m0=lzma2 -mx=9";
  };

  # อันนี้คือที่สำหรับวางสคริปต์ "แตกไฟล์อัตโนมัติ" (Function)
  environment.interactiveShellInit = ''
    ex ()
    {
      if [ -f "$1" ] ; then
        case "$1" in
          *.tar.bz2)   tar xjf "$1"     ;;
          *.tar.gz)    tar xzf "$1"     ;;
          *.bz2)       bunzip2 "$1"     ;;
          *.rar)       unrar x "$1"     ;;
          *.gz)        gunzip "$1"      ;;
          *.tar)       tar xf "$1"      ;;
          *.tbz2)      tar xjf "$1"     ;;
          *.tgz)       tar xzf "$1"     ;;
          *.zip)       unzip "$1"       ;;
          *.Z)         uncompress "$1"  ;;
          *.7z)        7z x "$1"        ;;
          *)           echo "'$1' cannot be extracted via ex()" ;;
        esac
      else
        echo "'$1' is not a valid file"
      fi
    }
  '';

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
    extraGroups = [ "wheel" "networkmanager" "video" "storage" "audio"  "disk" ];
  };

  system.stateVersion = "25.11";

    ############### --- Home Manager --- #####################  

    home-manager.backupFileExtension = "bak-${builtins.toString builtins.currentTime}";
    home-manager.users.nixka = { pkgs, lib, ... }: {
    home.stateVersion = "25.05"; 
    home.enableNixpkgsReleaseCheck = false;
    
    # ติดตั้ง polybar ที่มี i3 + pulse support ใน home-manager
    home.packages = with pkgs; [
      (polybar.override { 
        i3Support = true;
        pulseSupport = true;
      })
    ]; 

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 9;
      };

        colors = {
          primary = {
            background = "#161821";
            foreground = "#d2d4de";
          };
               normal = {
            black   = "#161821";
            red     = "#e27878";
            green   = "#b4be82";
            yellow  = "#e2a478";
            blue    = "#84a0c6";
            magenta = "#a093c7";
            cyan    = "#89b8c2";
            white   = "#c6c8d1";
          };
          bright = {
            black =   "#6b7089";
            red =     "#e98989";
            green =   "#c0ca8e";
            yellow =  "#e9b189";
            blue =    "#91acd1";
            magenta = "#ada0d3";
            cyan =    "#95c4ce";
            white =   "#d2d4de";
          };
        };    
      window = {
        padding = {
          x = 10;
          y = 10;
        };
      };
    };
  };
      
            gtk = {
    enable = true;
    theme = {
      name = "Arc-Dark";   # เปลี่ยนจาก aliz → azul (Iceberg)
      package = pkgs.arc-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";        # เปลี่ยนจาก Vimix
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";   # เปลี่ยน cursor
      package = pkgs.bibata-cursors;
      size = 16;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 9;
    };
     gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };  
         qt = {
      enable = true;
        platformTheme.name = "gtk";
        style.name = "adwaita";
    };

    xsession.windowManager.i3 = {
      enable = true;
      config = null;
      extraConfig = ''
        set $mod Mod1
        font pango:JetBrainsMono Nerd Font 8

        # Hide edge borders
        #hide_edge_borders smart
       
        bindsym $mod+Shift+e exec --no-startup-id "echo -e 'Logout\nReboot\nShutdown' | rofi -dmenu -p 'Power Menu:' -i | xargs -I{} bash -c 'case {} in Logout) i3-msg exit;; Reboot) systemctl reboot;; Shutdown) systemctl poweroff;; esac'"
        #bindsym $mod+Shift+z exec nvidia-offload flatpak run org.vinegarhq.Sober
        bindsym $mod+Tab exec --no-startup-id feh --bg-fill --randomize /home/nixka/Downloads/wallpaper/*       

        # Keybindings
        bindsym $mod+c exec alacritty
        bindsym $mod+q kill
        bindsym $mod+d exec rofi -show drun
        bindsym $mod+z exec thunar
        bindsym $mod+x exec firefox
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
        exec --no-startup-id lxqt-policykit-agent &
        #exec_always --no-startup-id feh --bg-fill --randomize --slideshow-delay 2000 /home/nixka/Downloads/wallpaper/
        exec --no-startup-id feh --bg-fill --randomize /home/nixka/Downloads/wallpaper/

        # Dracula border color
        client.focused          #bd93f9 #282a36 #f8f8f2 #ff79c6   #bd93f9
        client.focused_inactive #44475a #282a36 #f8f8f2 #44475a   #44475a
        client.unfocused        #282a36 #282a36 #6272a4 #282a36   #282a36       
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

         programs.mpv = {
   enable = true;
   # ติดตั้งสคริปต์เสริม เช่น uosc (UI ใหม่) หรือ sponsorblock
   scripts = with pkgs.mpvScripts; [ 
     uosc 
     mpris 
     sponsorblock 
   ];
   # การตั้งค่าใน mpv.conf
    config = {
     profile = "high-quality";
     hwdec = "auto-safe"; # เปิดใช้ Hardware Acceleration
     vo = "gpu";
     ytdl-format = "bestvideo+bestaudio";
   };
   # การตั้งค่าปุ่มลัดใน input.conf
   bindings = {
     "WHEEL_UP" = "seek 10";
     "WHEEL_DOWN" = "seek -10";
   };
 };
    

     services.picom = {
    enable = true;
    backend = "glx"; # เปลี่ยนจาก glx เป็น xrender (ประหยัด RAM ~50MB)
    vSync = false;       # ปิด vsync เพื่อประหยัดทรัพยากร
    settings = {
      #glx-no-stencil = true;
      #glx-no-rebind-pixmap = true;
      corner-radius = 0;         # ปิด rounded corners (ประหยัดเล็กน้อย)
      #round-borders = 0;
      xactive-opacity = .98;
      inactive-dim = 0.05;           # ลดจาก 0.15
      inactive-opacity = 0.95;      # ลดจาก 0.90 (ใสน้อยลง = ประหยัดมากขึ้น)
      blur-method = "none";

       opacity-rule = [
      "100:class_g = 'firefox' && fullscreen"
      "100:class_g = 'librewolf' && fullscreen"
      "100:class_g = 'Luakit' && fullscreen"
      "100:class_g = 'luakit' && fullscreen"
      
      "97:class_g = 'firefox' && !fullscreen"
      "97:class_g = 'librewolf' && !fullscreen"
      "97:class_g = 'Luakit' && !fullscreen"
      "97:class_g = 'luakit' && !fullscreen"
      "97:class_g = 'Thunar'"
      "90:class_g = 'Alacritty'"    # ลดจาก 85
      ];
       focus-exclude = [
      "class_g = 'luakit'"
      "class_g = 'Luakit'"
      "class_g = 'mpv'"
      ];
      detect-client-opacity = true;
      detect-transient = true;
      use-damage = true;
      unredir-if-possible = true;
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
          modules-right = "pulseaudio xkeyboard time date";

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
         interval = 3; # เพิ่มช่วงเวลาการอัปเดต (วินาที)
  
          warn-percentage = 96;

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
          interval = 5; # อัปเดตทุก 3 วินาที
          warn-percentage = 96;

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
          interval = 5;  # อัพเดททุก 2 วินาที
          thermal-zone = 4;  # ใช้ thermal zone แรก (CPU)
          warn-temperature = 95;  # เตือนเมื่อร้อนเกิน 70°C
          
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
  
          scroll-up = "wpctl set-volume 59 5%+";
          scroll-down = "wpctl set-volume 59 5%-";
          click-left = "wpctl set-mute 59 toggle";
          click-right = "env GTK_THEME=Adwaita pavucontrol &";
          enable-click = true;

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
          label-layout-foreground = "#FF79C6";              
        };

               "module/date" = {
          type = "internal/date";
          interval = 5;
          date = "☕ %a %b %d";
          format = "<label>";
          format-background = "#282a36"; # Iceberg Background
          format-foreground = "#bd93f9"; # Iceberg Blue
          format-padding = 1;
          label = "%date%";
        };

              "module/time" = {
          type = "internal/date";
           interval = 1;
           date = "⏰ %H:%M:%S";
           format = "<label>";
           format-background = "#282a36"; # Iceberg Background
           format-foreground = "#ff79c6"; # Iceberg Foreground (Low Contrast)
           format-padding = 1;
           label = "%date%";
        };
      };
    };
  };
}
