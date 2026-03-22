# Standalone NixOS module for Eternal Terminal with idle timeout support.
# Usage in configuration.nix:
#   imports = [ /path/to/EternalTerminal/nix/module.nix ];
{ config, lib, pkgs, ... }:

let
  cfg = config.services.eternal-terminal;

  eternal-terminal-pkg = pkgs.eternal-terminal.overrideAttrs (old: {
    version = "6.2.11-idle-timeout";
    src = pkgs.fetchFromGitHub {
      owner = "hflsmax";
      repo = "EternalTerminal";
      rev = "5d1c873050e7a3a65c4b1e1e23c64ad5b5b37e0b";
      fetchSubmodules = true;
      hash = "sha256-4rjGs7MlNSIBK3GJzPGJkrYc4bdakdj1CJb3fmCnKsg=";
    };
    cmakeFlags = (old.cmakeFlags or []) ++ [
      "-DBUILD_TESTING=OFF"
    ];
    doCheck = false;
  });
in
{
  disabledModules = [ "services/networking/eternal-terminal.nix" ];

  options.services.eternal-terminal = {
    enable = lib.mkEnableOption "Eternal Terminal server";

    package = lib.mkOption {
      type = lib.types.package;
      default = eternal-terminal-pkg;
      description = "The eternal-terminal package to use.";
    };

    port = lib.mkOption {
      default = 2022;
      type = lib.types.port;
      description = ''
        The port the server should listen on.
        Make sure to open this port in the firewall if necessary.
      '';
    };

    verbosity = lib.mkOption {
      default = 0;
      type = lib.types.enum (lib.range 0 9);
      description = "The verbosity level (0-9).";
    };

    silent = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "If enabled, disables all logging.";
    };

    logSize = lib.mkOption {
      default = 20971520;
      type = lib.types.int;
      description = "The maximum log size in bytes.";
    };

    idleTimeout = lib.mkOption {
      default = 0;
      type = lib.types.int;
      description = ''
        Idle timeout in seconds. Sessions are terminated after this long
        without any client activity. 0 means no timeout (default).
        Useful for cleaning up orphaned sessions.
        For example, 86400 = 1 day.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.eternal-terminal = {
      description = "Eternal Terminal server.";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/etserver --cfgfile=${pkgs.writeText "et.cfg" ''
          ; et.cfg : Config file for Eternal Terminal
          ;

          [Networking]
          port = ${toString cfg.port}
          idle_timeout = ${toString cfg.idleTimeout}

          [Debug]
          verbose = ${toString cfg.verbosity}
          silent = ${if cfg.silent then "1" else "0"}
          logsize = ${toString cfg.logSize}
        ''}";
        Restart = "on-failure";
        KillMode = "control-group";
      };
    };
  };
}
