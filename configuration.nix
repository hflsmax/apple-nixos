# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config.allowUnfree = true;
  };
  stable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-25.11.tar.gz") {
    config.allowUnfree = true;
  };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ./sandbox-config.nix
      ./eternal-terminal.nix
    ];

  nix.settings = {
    trusted-substituters = [ 
      "https://lexa-lang.cachix.org"
    ];
    trusted-public-keys = [
      "lexa-lang.cachix.org-1:+sLINOQTFyHLCppbo41mXzTeUpLl/7UR/uvCObyuSt0="
    ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Avoid using the unstable channel
  nix.registry.nixpkgs.to = { type = "path"; path = pkgs.path; };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.kernel.sysctl."kernel.sysrq" = 1;
  boot.kernel.sysctl."kernel.perf_event_paranoid" = -1;
  boot.kernel.sysctl."kernel.randomize_va_space" = 0;
  boot.kernelModules = [ "nct6775" "tcp_bbr" ];

  boot.kernel.sysctl = {
    # HIGH IMPACT: Buffer sizes (fixes your 208KB bottleneck)
    "net.core.rmem_max" = 134217728;        # 208KB → 128MB
    "net.core.wmem_max" = 134217728;        # 208KB → 128MB
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";   # max 6MB → 64MB
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";   # max 4MB → 64MB
    
    # MEDIUM IMPACT: Better congestion control
    "net.core.default_qdisc" = "fq";               # fq_codel → fq (works better with BBR)
    "net.ipv4.tcp_congestion_control" = "bbr";     # cubic → bbr
    
    # MEDIUM IMPACT: Handle more connections
    "net.netfilter.nf_conntrack_max" = 1048576;    # 262K → 1M connections
    
    # LOW IMPACT: Fine-tuning
    "net.ipv4.tcp_fastopen" = 3;                   # 1 → 3 (enable server side)
    "net.ipv4.tcp_fin_timeout" = 15;               # 60 → 15 seconds
    "net.ipv4.tcp_mtu_probing" = 1;                # 0 → 1 (auto MTU discovery)
  };

  boot.kernelPackages = pkgs.linuxPackages_6_11;

#  systemd.services.boost-off = {
#    description = "Disable Turbo Boost via boost-off";
#    wantedBy = [ "multi-user.target" ];
#    serviceConfig = {
#      Type = "oneshot";
#      RemainAfterExit = true;
#      ExecStart = [ "/run/current-system/sw/bin/python3 /run/current-system/sw/bin/applectl boost off" ];
#    };
#  };

  networking.hostName = "apple"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    package = unstable.tailscale;
  };

  users.motd = ''
    Welcome to the apple machine, the shared workstation in Yizhou lab.
    FAQ: https://tinyurl.com/uw-apple
  '';

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users = {
    apple = {
      isNormalUser = true;
      uid = 1000;
      description = "apple";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
      #  thunderbird
      ];
    };

    c24ma = {
      isNormalUser = true;
      uid = 1001;
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDIKES4c0hCUmWdMXVDuvJWUJ7VdaURkq8qhpT4X3grCH/FKi2Dfls6Z6pIbqR2sgm+np1KYvS9/6Ozbd7UGOesla5RYRqDj9lbfFHBKjiocinD8JWAxyjHT2dHQnXvEmQ3KVIZ4H/duDf8G0/G+YOug0iJ7PR0iSH6Ie7Bo3BXf8Sb81XvpsGcqQ9u0S0udLojxUtq5SHFkeCyjMuhfnX5ynE5Mik6U9eS0K2nFzIZqR4ONHEnuRmjKoYNbrPlnBbp1UffMiRYKa3SQs+wm7GyIPXa0sDBe8nBVBya3PT5TzRiXr0HfRhZkqeSSRn+EwIlOLyvxaCcdGNu/new/dCp9+W0Emf0HmMZs7YhdSY9xA0yNWGQlRyymgZoIT6Nqp82PfG1d5NyzS+Gz4+hwQlbd59fSYik1u97MCgqnrJlQHA/KRi6I7pwFkPTdSWUhtAZSqZjqkkLWNOCflhT5NcBePotGGAPy42/PKqcl2HmeT+zi/jVm9sqZHdl09pM3s= c24ma@Congs-MacBook-Air.local"
      ];
    };

    yizhou = {
      isNormalUser = true;
      uid = 1002;
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMz7siehNXmxfsqWnovhjCpe2dXHOGvHZ0m/BeZARnML"
      ];
    };

    j2655li = {
      isNormalUser = true;
      uid = 1003;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLXZhcD12XY9ouweLQoDtT4mvivQiWmfhNXLXTUqP2X jianlin.li@uwaterloo.ca"
      ];
    };

    gaga = {
      isNormalUser = true;
      uid = 1004;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDn1f78t0EoQDijNowfjxbUM0FxCwcUJwJ80hc859jXk1CgrCQB6G7qr3nEipoH+ZvD87YzUKROZFqiYCB8MHg0k8UrdmTyyvgNVlaE6Z0OrSznO6jK9AlrBs7H3QMhLv5LrLHdX2D11re2AQobbsN5tTHn4aA+1ZOyIeX8jcEhvpA38+ce+rqSwEQrWAYLLt+sRc3AXyJqe9t5CELX1apO9viMtfLDCex1gD0Cy+ut/uS//9Dtcp6ev8i89GD3I08gY9q0YhsMl28nCTNKzZhIetKAwWdeXDAh4I821vkrmU1KcnpwBKITirfmBPOgQfJZvogGPMoIou/IiR2DRCcBd29FSNO6YF+QbvPUzVRS1n0KkWqAlL2tnQtF+tA/m8uGN1wGjWYOZ/wbkEhyuV1IFT+1beDCKjfthsnKB9nClYhkIatdmOLhw4N48EFM1pkrAK8fnuifxTkAoKDcnHdnn1onJ/DCFsevx4Chu5X/fyhaAj6D6zlU3IWJOmkKFjE= gaga@gaga-mac"
      ];
    };

    z33ge = {
      isNormalUser = true;
      uid = 1010;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCp8vAjoM+WlclOaeGQJlu2sKZGnI32nla2HJYReqRgPbnL6sg/FjEMgS2Ybl4G4GqOK0hzErwM09qaz1V8/vKRnN3fyQC41PAOKplb5mJyb30bVO+VRGy65LJ9h24+a9Xh/K95M6XNKv0v6mzCmN5K/2bRM8my/0bqvF5vd1Ky5sAIouwY8y19V4IaljCeu+c4Zn//vH2+Cx2ovNSap4R9WaTwbkqVCGK1y0Qz5s6np0Ow90JvRNugfCf+BbC6mAu0uNsINow2nJcrmCK/Rz8sEr++jKChOmMSXcCKwH00yLEqwNuj3HNhgHAzQMdIMZs5wPRP277bDaOjPXpHnELZHTL3zlqhjzTHB8RpxvuLGjqjcIlbDejvXLVpGUHq0YgIGtzZMilCRmNmPn5fIT3Cf05SRhZ8yT0Ls3JV4K519IJjKvRRfy5NWId7gLJ8l/4OBXzJydhuQQ0PvSds1bBe1y4QtGG1lk1912J9oyHtYnnq+rqmfByJziJBhXQ8u8U= august@As-MacBook-Air.ht.home"
      ];
    };

    n9jin = {
      isNormalUser = true;
      uid = 1008;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuv/a/A3QeT0ZplAlTdI4gdHTyB8VZwtsO316bZtGJM8T+QZG1HRjzfyik/r4nmLT3gObZpngnuc87p5Vdiv4IISz1JbxwxdcLJm9pqzmKbUbzwA/s5k+p4JebVCeQRHSsD/cQwTvKEKoNLImPzUTqcAeywSIp5hAkixltLTMgYNikO5FWsTgkKl+x2dfLY60pV/XOEq6hWeXNNq0wqPMk4qXtmYscaeoOA/5asA0NGP5XV6uEH9fsjVSkR4mS0V1l+pSpDNOgL9Ulldk1bfcziVilubw/b/BuZo7IK7TRkAphqG8v44h8JRGrnxAXLw5yu/eJvZroGczhu2xoOzychO5nQzWj/YUJBpDNqAgEaQsC3+QnfEOgphgLxKua9Nq4BI3LnP/g+1hotJIoKMdEKRnazK2yGFpBfUd4bM1UDwigXlfxnJRqo43y3vXsnM4IkTtGhxHXTwYjNZhf7PAO9GlFHAmnXPM0HENsgcRlaEkZokRzX/ihEJnH5IP6zCU= nicolejin@v1040-wn-rt-b-114-58.campus-dynamic.uwaterloo.ca"
      ];
    };

    y3536zha = {
      isNormalUser = true;
      uid = 1009;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1g3R9e3L1uvTUCNK6hHDdHZqUT/BaW3XxGE2nxKqo4cboTRa8hPvJHuuRzLlyoYGVmBCoF5lGx5dUSolqRSr1QdFqBkn7Z2k3Pb7AJKX9niFxHmG8TDm1C/Ot1CuuA6kz5I6JSrKHxYw8Y8LqF5SDtRXTYxnL42fm8VVNz19FDasL3oQk6AmiVtM1640fN2PAFH4SzOMYdemqAxjYg7CxbOdYpIwUf9j7HE+o9JL4LdHI8YrFvbTMU20OUJPOTZpurKmbfZ8RBZVqL/W34pjdHtoy6Ijz7Wxy81VUU+Y962MhOVn4B1hSGk/nxtZXKf5k3QnQCl6la6zNylGOKs+xC1ZXz/fphprDPK8tzWR/pEILnEo3tN2ED0ho3BqkkZKXneyIj7txU4Yp37IWhF49cyFsNP1G6HmqoJsz8nai1z1WeufeE5nF+koJ4gc+qgHfcRvexpo6GKq5CzoIji695stwU/p3mlQ72CNyjE6T87ydoIznHyTh1N7oE0GQOt8= yixing@Yixings-MacBook-Pro.local"
      ];
    };

    mr2shah = {
      isNormalUser = true;
      uid = 1007;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDc7k1E5X92khDgQalOM78dCC4L+8V05KNqzTY7eSnVuGDq1f4NWn+RuUi/Zo2+LCXoUCPRm3Bw2y1N6vJoZWjoR5efqwT1TKP/W/fy5kJET7tqudVB7TCA8mZbLYM1in0BP0wezB1+LcuGLKRoG17eVVY6z+olzcRmIlOZGK2uKb/dHn/U/tsRs8omHz1b9YZlmfnIZu5WMNAyiGtcBmoFV/MrhHmgduCitJVbTc/ImUx9Yjm/CHzzGXls91UG8hYE95ZIxpidY6XFKlLaYLcdz6jURvx1mGJJvQQvivaCVCoFLK7JAakAajJYln9nIVvG7tzCxhu4VmZVJzVJsbnXGdFxcuXrxccyzpcj0hRS7NqeOgCVgLYKVXiHDhZ4FHDQR381B3a9HCFUgsE+eHRujWEB1dt1SdnYBBJQUDhVEMT2OgVUpD4mqa3S+WSpoNxG7A2khqn+oKgZbf+TKgzI5TPsI61Lr95NLqipCl+SSpgHTb1GJ2tw4VTwMz0kWRk= malha@DESKTOP-VOO168V"
      ];
    };

    cjian = {
      isNormalUser = true;
      uid = 1006;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDo06wxFW+vC6yvPuLF92l00tEfZjVuxbpE1oWbzb/yh3JuQyWdEjhnNyc+TJ6BtIUmmnNl9ph3nenHKYj9ZXYut5mQKJDdOh/HZRGDO8JDa9Dj0OuZzxdjpWb9Xwk8SQsRKlR/PKR+OFDZambdNR6RNIIdaCRC+TWwhJ2PRYHQDUZh5nj1z2Aar0I6jq8wfjQ/NadTbZvUdbcbcVnwn0T9GA3zNXZuanVmUEB6jwAO9ZWGsqq1s1mzY6iC+gb/pVEyQkdUoCXeJ9SK9YUfQo7M4DXDgC3lCimxiYMgviHNYSt8qdD0AC5S87wQuNApz9azsn7YgmDoMGLFVTpO36EboSRKDeOt2/CNbxhrv5SPdgpKgjCm+CsztYIoJab0XowiBBYaiG7LpImLGm+CSei/fOpmUrEM1zmZeobQBF3lOE5C85DfBrbU+3AJ0o1vT8U5dyodRbFtC3et15PmyzM/0xqY15lM2f8nWcPCxThTIM2YLLw3MtWL1a6IRZOP4Uc= charles@LAPTOP-PEKAH195"
      ];
    };

    z358zhao = {
      isNormalUser = true;
      uid = 1011;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDy3WLVscElkFkK/Ds9VnxuI9uViD0my8tdJdCTyj1CQU3HOs5/UiN8m4XkOCjnG9XVDGUAczWC0ciV61YACI6Q+q8050e8pWIo6JFMMyLYQNf+n6ChrnF6oud5mnmzwpfSniR2jX0qn/dyXtSS687jlYpAi4dqymkBnBiMGlPYtfRmH5zwhlE92l0ZEbzPF51W5YgtLDf1PBB1Z9spumTGICQoq0760kNEGAK55kPItd6uYe8Dc3YOi7zjlW29d9pKzW1oURPuL1QDHdB9Q3QhLSUs3o1lWDgy7MKTF81HfPr09XIF/NzneTg7VaxUGwtpkef4n6mYTSPVg//xizrYte/Sq2NCHY2cFyiWR8QBZ6m9OZwkircMo5kSkV4FTXOI7/sWJmstkBjijOoNpugZ9kRM9dy59rBQVM7+XITXQ1haG/88jKtV2M1TC8RG5BDR5m1f61QIGyM4zDp+fHfZ9FeI7gUzS2l1DvGISRrXAlX9A9a94riyzZqNHsIyl38= zhengyizhao@Zhengyis-MacBook-Air.local"
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0WFPNmw6H/NOooWMICbt4N8H/SPhs6VEaT/1d1HtOWX6i2R8s51i0sm4vTtz2vp4NNVxWUgotpq0W5OMn8XvlcogkQ1XVSd/g7yi7qDd9DB3+XJtb5lMdIds43kio797v0sQq2+kHes4be8j99zBbZ98jQgOWtF+Dt26pywfQ8YeoYucw32FwP+6ywKx8irqB49RIU5Bjo/OHiw6ZL4/ajF6OuQKHm6oqa+3cyeeQ6wnQ221F2qZ7W7wWobt53Gqzs8dv9TnEFKe6PpDG7g7CySAAzq1gATfDFVTPfDMUsRSgpj08wP10iJaCmyFib+0EUyQEdHv7kGNEt8Bp5GHc8sfUeQXYNNEbKMlZJR93jpXiT0Ns8ewW+KgBjjO/Z8WHAEgwewdEE4O1JopCV2fYEFzLS3lfCuhweoJLz8MM+bTajSiFAvbtTJY4oYDQDwMNr8MuM4ZPCyxNgcpbMjk+JrudJW/0lrgkY972HBH+t/toj5eGaAkF1PPxNBICod9ST86ZuvpYMR1ESexgYd+V4OsV8HtwNzdNJ5r92MHZBLZ4dpIAQ2COHJlogeWugYttZFQ4GISEDiMlFDlOAlW3wPW5xEjG65BciPiMBSlAaQ2dYIqB+KbFbW74a/Kh0QfsU+bPxp26AWQ2J7MMOqylN12lksjIbB610CwjGex3Kw== lexa_rsa"
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDgtbkeUcNEBEHmHXm/naKlxyubqSLMLJPNhtPcTMxbGXfXZI5qfHqTzrSY3ZsruKHGy/AB6wejYstyIfvRGUpp6AtcJI088Pt2NSAuS6vpAXOvo9ZZSQWCqwZ7wb3uCg+rDhw83T162RBIy8t+MhfDIiqIYIpGKboXkfFgiUbFAzQ/f/4mck6A8gJtyR+63ySVS6IwapK8S/A0CsZS+8jCsW7DMkO+Fl0heN4NdYXkmncUFTD6fhrpwImOUUBgJusWj/S7o4u1LK+QQqRGozWUBYA9hwmGGNL/BHedi35roJtzLVfueExJzBPhq1Ud/4qwAb574JTvUbfs212lz0N/ywVMXUmiZibxNDHmIL4k36Xtm1MH4GmeaS9Ys5kJ0fXbfdZgS/DUg0uU0EdRzXQmd389enBEYeqAgQd1PJyQidslhedF0OUMb5YHlp9k+D0RuEgtkQNhH3U/J2P5XWkghmwj2WAku/qUtJmRqq/WjV02q4XJ5PopCe3DHiphQmc= Zhengyi@LAPTOP-0V4B77LO"
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDIKES4c0hCUmWdMXVDuvJWUJ7VdaURkq8qhpT4X3grCH/FKi2Dfls6Z6pIbqR2sgm+np1KYvS9/6Ozbd7UGOesla5RYRqDj9lbfFHBKjiocinD8JWAxyjHT2dHQnXvEmQ3KVIZ4H/duDf8G0/G+YOug0iJ7PR0iSH6Ie7Bo3BXf8Sb81XvpsGcqQ9u0S0udLojxUtq5SHFkeCyjMuhfnX5ynE5Mik6U9eS0K2nFzIZqR4ONHEnuRmjKoYNbrPlnBbp1UffMiRYKa3SQs+wm7GyIPXa0sDBe8nBVBya3PT5TzRiXr0HfRhZkqeSSRn+EwIlOLyvxaCcdGNu/new/dCp9+W0Emf0HmMZs7YhdSY9xA0yNWGQlRyymgZoIT6Nqp82PfG1d5NyzS+Gz4+hwQlbd59fSYik1u97MCgqnrJlQHA/KRi6I7pwFkPTdSWUhtAZSqZjqkkLWNOCflhT5NcBePotGGAPy42/PKqcl2HmeT+zi/jVm9sqZHdl09pM3s= c24ma@Congs-MacBook-Air.local"
      ];
    };

    saurin = {
      isNormalUser = true;
      uid = 1012;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCn/7u4l2w1m/HYw38ztZpevJoa61w3bMBDs1g7zL1kgIOgyPWNopCxMLdp/1lWYuTbbcmXFWjdJuJtIjJBdx2sNFNjwc6rz5HXcE9w0T77xkFDpIndChFkmsBTgoG6/iU7xRFfQLBF3iLLRbXRs1l6Q/steJvjn/WEsBk3dkoPiKqK3FvXRX3PG2ebb4JTmWI/XpIKyix2pzUVIiYzqJQ1JRR2aawykNd/HZlnz+dVpbm0vdl1r++LWqeFv/t/70zRcdL87+LqyM/NUoTQ5GrFmtMhshSHXDGtxDEEEuFB/eIg76W7jdO/7+cttpOXpZb8aMrdir0oIqBA0spUX5AqavbFs59BDbe6ccnAkO5nd2vdlkM0T1V/W/M2+0vgG34Gc2j2mXtvPuvQM9fSu4SIFTit1R4L0VHHkaEmB4YyySBx7r3W7j/T4gi4tUoANqyUpcG3eLtMFWWI0TgHsjtSUo9rhtvHwWjQsb16FRNOYKW3KcYAwxRL+uvCqKk0xQU= saurin@Patel"
      ];
    };

    abright = {
      isNormalUser = true;
      uid = 1013;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2ttvYlGjzyGWLDuv9rnItr4BcQcvQb265VQ11Ff9UtF/7vcsVQO79cgiSMu+cSpNF6FjcSJNwFyyhUhThJ3gBBeqxV+HuDKGm7GmU1JkIWAEdeFvYrARaEDl61GUYFfFjuQGxzjg7jR2LUEq6ryNqs8rRaZURE0Xnsdiq76PkQuePrIKCu+Xzq31Z8xbzaPdOW/b68tFrw+pAU/DyiHau/w5Oyv8e2Alc20kD9j18WhB3qySzkNBqiMGDKRNleA9HDOsOHV38fXdP0cdoj+jfQayxqBeI3x+bdlpzasqRKlKgEaKiOmxSWk4Pm/HHF+ntEav9H4TIgTwjbn14Qt2Zula5f3vGyhhpDUd3Z51pmKqNsJkHuVYjydclrziXoX1rxxtlihT7KCtAGL/Xo4HVMjnLvvMhKSliSlWAsdOt2n/N+1Szlj6Xk0vqvhh3uwIod6EdnAgTCH16Voluzg6UJczGrPAPK34KvbyQP8/g31Fn5zFyo5Uisma2sWCRRl8= artb1@ArthurBrightVB"
      ];
    };

    y472zhan = {
      isNormalUser = true;
      uid = 1014;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDumB79BCSVlIjj4K5yEcpbsic/C2zq08Sq+MPMESQbxSJrRNlH7BT6cFenXENJy+ubwmYFiwP+yUdRwAwIgUEfgdLOK4BDgwuV6+VXO/kDiumq/ATM+LJR+44U2Ft8nPJB4KqaXOsXKU+30oAUUvz0C2oBAGTxTgqVZyjGvapxDqzFUfuW6tSwZ2GKJDkfFQQ9yl0QUQjAlPycOfIhciwuhh1cmD66N7xq8ehYVFQlAQHdK38C4Mu2yqQR2+Ir+3bm3DzDPZW90A+YTZSVzIwCvFs75+b8IFlDylHShSxMXvJe4VX2Nl/t8ms/Dpup2GyZaZ2QCgLzHJSe9gxoYYvCT4Sf9isJ9ZW0YE5bbUHm+SG+HvPeFPM9pw4uAgOElCVIyRPSs6HmUy+MFWjVqfcyCSip6YyMej+ELTAp3TLAibiCnEheGiboIR0Cuo888vh67YzcnrB7QLNkQbIw9qmMPxxG46gmZc4PvXvKVjT/M5NwYOHZDBRnUCTtKIDcFFE= yifanzhang@Yifans-MacBook-Pro-2.local"
      ];
    };

    m5jung = {
      isNormalUser = true;
      uid = 1015;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqb+fskB5qGUwEHgpTnhAshjc4Lhny2PKXYCx9aGr4OsuqvQOwQST05aot6VGxcrUlyukenAXfAfjdZytxw8GRU2DIEhig+O0VphmoszQYTVXIcxGoIc023sWUe+SGACddqB9GD9JeoinUTGje+ZfxxB13EehOkRInY657rFHDTf6tmGjYqGj/95PrDTIHB3b8sf+w++thXdf+0ZYzKX4uJ3VZBada+3G62h4dEoiLoBVJfN6lKRg1SyZ1aCxmW26hrZaGx1CLXDfbIuts0KcgxgLL3Xpm22JtB5va9HLWI1eXdSMFQe152MJd3E1tfOQe8CgEGl439MJAibK+J9/x07sSYyBAYkxl8jScapPLKZtAg2w4JHVDpEfJHjQ2xmz3BnZN1GZqY4HsMcdulEYclMFtyx8J6TX8ug0ZH2m0n3PLUo3W/gHfnL0hiAgbnc3iPB5CZlWOdEyjDRTrQkIQoABEYO6nzY+ET58V6LyPT6i6k6431s1zf5FBCNk5Y/k= maxjung@v1041-wn-rt-a-250-240.campus-dynamic.uwaterloo.ca"
      ];
    };

    e5jin = {
      isNormalUser = true;
      uid = 1016;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHytqivteEar+qEJqK2XvlevvOPCBrfsyQqnFedL30Co ende.jin@uwaterloo.ca"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMyG/uz8PSbNyn1QohSdwtX+FUG2jmCuAZnllaOfzV0 jinende1997@live.com"
        "AAAAC3NzaC1lZDI1NTE5AAAAIDMyG/uz8PSbNyn1QohSdwtX+FUG2jmCuAZnllaOfzV0 jinende1997@live.com"
      ];
    }; 

    mvcalabr = {
      isNormalUser = true;
      uid = 1017;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+mhMOyXDkFXU/TB7gIlzupC9jBeKrOOGuYERTmKfPsAbozqTmsTueGsfzECKRd0mtDwpCdQqcqFVZFID0/kOHP7J0cDbP0mUvi/DwcJR9fxpHZv9N+3beOnH2kuNWJoY9vowy84Fji9G3MK2P3SAtdF9YTCY0MlbLvTum/h8sO1iXFy4ChHQuIA29u0xOnajnKDtU9/rU9hEjuazxQnShY+FGfal2uKKlwI8mJvxLQtKiDmlBQRa+lB4kktz26wFsghb8cJUspvL869qh6x9682x0HUK/GA79Ifj7D0idptyzJSwOtLxcigWdValOST9slLb+PJ62NWNZFna+MTO51ZqJgRdqdAJKOjZWQpD2qbGmeJVC1Uh+3DpUc3W+VaTSxW1OZ7FNU5kzdQwTafdU+vXdwF6qRu7EAdI+UxefYk6FeoFg+t4CMjsNSczT1cSbU+bRUSXGzOa6+eqnsBrjwLYrddZAg50LenOI4BuxHO2bw6Rc7eNNSCQruBG3fgLSGdxyNNlzvRdn6jZxAMt+RE1WOZ/wLPasYcQS9NeJB4mRhCRSJTDnSAJB357g5w5Knz2UfRsd0b+L1veaERS8u5CLlJeU0M1TUwvurLKVXxBXDKqvpWIa1FQHuhG53cGNNmNkHtBgn8TzSGt6uF5jlxni3egaCvM+KyKzs5Ez5Q== marco@30pc"
      ];
    };

    kushal = {
      isNormalUser = true;
      uid = 1018;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNU5Ok8u4HjIc8J2EBxWBmWBRAi473egyWZ94Frq68Mvjip3wllYuHz0u0qXbOAwrSgHapGs2x9nlOsWYg2Mo5zmSXp7alEhbVy0FuyFWRDyDMN3/En3jHZJAw1hbPyAArRC7lpCHMQkBQMqMt/NpdV7qTrQFxp4o40+C1E3J2oLMEzktWWs2C/+jftqTEh0CFUonX8PtdCEjg9cmJzatxGIREEb+7A7gF3ejqsjqhWz6JLI84QuPzmVj/rPBz+yiZawEtoCs6rn/gJNbapeMSYzYa/7bjprGRHR+5dFU2LOPh2aCiMjje/jha82eCpX/3EhKtzNaF7BibFgmKqLPZvG13vy3AoTq7b20UHWD0JrJneeatJWlSxOLaf+wOQNbONpBW4x1dbk/wS4tpMsIlFtxPHVELf5fP6XRBrW2vfzfp/vnNJ2vFmIUembh1vVQEViAwvVlKv4I0TYr0QRH32jRXoAhJYlqk56qa7wMMOl5C/oJFuwX/y9aGXJ/LvfM= kushalgoel@Kushals-MacBook-Pro-4.local"
      ];
    };

    rtanweer = {
      isNormalUser = true;
      uid = 1019;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIidP4MIBD3SWV7ANOR95XBimIaBIqVIaPJzfVo8N10c tanweer.rayhaan@gmail.com"
      ];
    };

    fa2bhuiy = {
      isNormalUser = true;
      uid = 1020;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNRkKXk/pTFlbBvUGMQ+1TPh9e+LyZ00iGbjwWqQh4wLUSaa0TNi841im/pLsHviY1upyHnADuLT9ON56b0H3UlIL1pPURI3FTxYZldyec+LsD/YfCrzGZvQ1OxuxPaoXd8OuW0ngOMEkf/mv32FT9raeuvLVx95EcZfxdcG2qnJjUn2Q0QBVRpYr4ehkJIqoMmy548DPo+RlsasMgdLW7oJD2JTc/s5Ioqy66nenUU6s2Hq6/lWF8wRtEnVKaC/lRS5ymxt9PRy3WCpHALNdmGoN5FzfVvvceH5fwq4tpZdgwz1cCJL4tzm5PGNktD5xuPpHPr5FoLixjFPMwliY7 fa2bhuiy@cs-teaching"
      ];
    };

    s2sivath = {
      isNormalUser = true;
      uid = 1021;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTdxrUGsMw8b1oFN/6YSQAgSGcBoiruiRqSNaWD5Zn9 superclash554@gmail.com"
      ];
    };

    anadamal = {
      isNormalUser = true;
      uid = 1022;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGlp2ODIpa1VHMzbdRSTxNbKTEOiiIt0CVtRgkpY075"
      ];
    };

    d62liu = {
      isNormalUser = true;
      uid = 1023;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDumLfSaUzzskkTWTB7F1N2n2ry9562MybmE2hUrnRNu d62liu@uwaterloo.ca"
      ];
    };
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "apple";
  services.xserver.displayManager.gdm.autoSuspend = false;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.login1.suspend" ||
            action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
            action.id == "org.freedesktop.login1.hibernate" ||
            action.id == "org.freedesktop.login1.hibernate-multiple-sessions")
        {
            return polkit.Result.NO;
        }
    });
  '';

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with stable; [
    openssl
    stdenv.cc.cc.lib
    curl
  ];

  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    emacs
    git
    home-manager
    htop
    glances
    lm_sensors
    wget
    curl
    jq
    tree
    gdu

    (pkgs.writeScriptBin "applectl" (builtins.readFile ./applectl))
  ];

  security.sudo.extraRules = [
  {
    users = [ "ALL" ];
    commands = [
      {
        command = "/run/current-system/sw/bin/applectl";
        options = [ "NOPASSWD" ];
      }
    ];
  }
];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.LogLevel = "INFO";
    ports = [22 443];
  };


  services.fail2ban = {
    enable = true;
    jails.sshd.settings.mode = "aggressive"; 
    bantime = "1y";
    bantime-increment.enable = true;
    maxretry = 3;
    ignoreIP = [
      "10.0.0.0/8"
    ];
  };

  services.gitlab-runner = {
    enable = true;
    services.lexa = {
        authenticationTokenConfigFile = pkgs.writeText "config.toml" ''
          CI_SERVER_URL=https://git.uwaterloo.ca
          REGISTRATION_TOKEN=glrt-o9AvG4LAGFW2pFesj5VL
        '';
        executor = "shell";
    };
    settings = {
      session_server = {
        listen_address = "apple.cs.uwaterloo.ca:8093";
        session_timeout = 1800;
      };
    };
  };

  systemd.services.gitlab-runner = {
    serviceConfig = {
      Nice = 19;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      log-level = "warn";
    };
    logDriver = "local";
  };

  services.cadvisor = {
    enable = true;
    port = 9003;
  };

  services.grafana = {
    package = let
      pkgs = import (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/47c1824c261a343a6acca36d168a0a86f0e66292.tar.gz";
      }) {};
    in pkgs.grafana;
    enable = true;
    settings.log.level = "warn";
    settings.server.http_port = 2342;
    settings.server.http_addr = "127.0.0.1";
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    retentionTime = "180d";
    globalConfig.scrape_interval = "15s";
    extraFlags = [ "--log.level=warn" ];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" "processes" "buddyinfo" ];
        port = 9002;
        extraFlags = [ "--log.level=warn" ];
      };
    };
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
      {
        job_name = "cadvisor";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.cadvisor.port}" ];
        }];
      }
    ];
  };

  services.eternal-terminal = {
    enable = false;
    port = 2021;
    idleTimeout = 86400;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8093 5201 ];
  # networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    logRefusedConnections = false;
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
