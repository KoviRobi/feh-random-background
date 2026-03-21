{ config, lib, pkgs, ... }:

with lib;

let
  feh-random-background = pkgs.callPackage ./default.nix { };

  cfg = config.services.feh-random-background;
in

{
  meta.maintainers = [ maintainers.kovirobi ];

  options = {
    services.feh-random-background = {
      enable = mkEnableOption "random desktop background";

      command = mkOption {
        type = types.listOf types.str;
        default = "${pkgs.feh}/bin/feh --no-fehbg --bg-fill --no-xinerama $BGFILE";
        example = "\${pkgs.feh}/bin/feh --no-fehbg --bg-fill --no-xinerama $BGFILE";
        description = ''
          The command to `eval`, with $BGFILE being replaced by the image,
          $BGDIR for the image directory.
          Defaults to example.
        '';
      };

      imageDirectory = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/backgrounds";
        example = "\${config.home.homeDirectory}/backgrounds";
        description = ''
          The directory of images from which a background should be
          chosen. Should be formatted in a way understood by systemd.
          Defaults to example.
        '';
      };

      stateFile = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/.feh-random-background-list";
        example = "\${config.home.homeDirectory}/.feh-random-background-list";
        description = ''
          The state file of the not-yet-seen random backgrounds. Should be
          formatted in a way understood by systemd.
          Defaults to example.
        '';
      };

      extensionRegEx = mkOption {
        type = types.str;
        default = "png\\|jpg\\|jpeg\\|gif\\|tiff";
        example = "png\\|jpg\\|jpeg\\|gif\\|tiff";
        description = ''
          Regular expression matching the extensions of the files
          to be used as wallpapers.
          Defaults to example.
        '';
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
              "BGSTATE=${escapeShellArg cfg.stateFile}"
              "BGEXTENSIONRE=${escapeShellArg (escape [ "\\" ] cfg.extensionRegEx)}"
            ];
            ExecStart = "${feh-random-background}/bin/feh-random-background ${lib.strings.escapeShellArgs cfg.command}";
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
