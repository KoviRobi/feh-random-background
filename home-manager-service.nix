{ config, lib, pkgs, ... }:

with lib;

let
  prog = pkgs.callPackage ./default.nix {};

  cfg = config.services.feh-random-background;

  flags = lib.concatStringsSep " " (
    [
      "--bg-${cfg.display}"
    ]
    ++ lib.optional (!cfg.enableXinerama) "--no-xinerama"
  );

in

{
  meta.maintainers = [ maintainers.kovirobi ];

  options = {
    services.feh-random-background = {
      enable = mkEnableOption "random desktop background";

      prog = mkOption {
        type = types.str;
        default = "${prog}/bin/feh-random-background";
        example = "\${pkgs.feh}/bin/feh";
        description = ''
          The program to call to set the random background. Uses the
          environment variable BGDIR for the imageDirectory option.
        '';
      };

      imageDirectory = mkOption {
        type = types.str;
        example = "%h/backgrounds";
        description = ''
          The directory of images from which a background should be
          chosen. Should be formatted in a way understood by systemd,
          e.g., '%h' is the home directory.
        '';
      };

      stateFile = mkOption {
        type = types.str;
        example = "%h/.feh-random-background-list";
        description = ''
          The state file of the not-yet-seen random backgrounds. Should be
          formatted in a way understood by systemd, e.g., '%h' is the home
          directory.
        '';
      };

      display = mkOption {
        type = types.enum [ "center" "fill" "max" "scale" "tile" ];
        default = "fill";
        description = "Display background images according to this option.";
      };

      interval = mkOption {
        default = null;
        type = types.nullOr types.str;
        example = "1h";
        description = ''
          The duration between changing background image, set to null
          to only set background when logging in. Should be formatted
          as a duration understood by systemd.
        '';
      };

      enableXinerama = mkOption {
        default = true;
        type = types.bool;
        description = ''
          Will place a separate image per screen when enabled,
          otherwise a single image will be stretched across all
          screens.
        '';
      };
    };
  };

  config = mkIf cfg.enable (
    mkMerge ([
      {
        systemd.user.services.feh-random-background = {
          Unit = {
            Description = "Set random desktop background using feh";
            After = [ "graphical-session-pre.target" ];
            PartOf = [ "graphical-session.target" ];
          };

          Service = {
            Type = "oneshot";
            Environment = [
              "BGDIR=${escapeShellArg cfg.imageDirectory}"
              "BGSTATE=${escapeShellArg cfg.stateFile}" ];
            ExecStart = "${cfg.prog} ${flags}";
            IOSchedulingClass = "idle";
          };

          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      }
      (mkIf (cfg.interval != null) {
        systemd.user.timers.feh-random-background = {
          Unit = {
            Description = "Set random desktop background using feh";
          };

          Timer = {
            OnUnitActiveSec = cfg.interval;
          };

          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
      })
    ]));
}
