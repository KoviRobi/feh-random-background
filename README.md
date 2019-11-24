# Feh Random Background script
- Why? Doesn't `feh --bg-max --randomize` do a good job?
- It does, for slideshows, but if you use that to set a random background, then
  you will run into the [birthday
  problem](https://en.wikipedia.org/wiki/Birthday_problem) meaning that you
  will start to see repeats more often than you would expect, and it will take
  you a long time to see all the pictures. This instead uses a state file
  BGSTATE (shell environment variable) to keep track of what has not been seen
  yet. It initially populates it with files from BGDIR (if it is not an
  absolute path, be sure to start this script in the same directory for all
  runs).

# Environment variables
BGDIR (defaults to "$HOME/backgrounds") the directory in which to look for
image files.
BGSTATE (defaults to "$HOME/.feh-random-background") the state file which holds
the not-yet-seen images.

# Home manager systemd service
The file `home-manager-service.nix` is usable with
[home-manager](https://github.com/rycee/home-manager/), e.g. with `imports = [
path/to/this/repo/home-manager-service.nix ]`. This probably wouldn't currently
work in a NixOS configuration as that uses a slightly different syntax for the
systemd service files (probably something like
`<nixpkgs/nixos/modules/services/x11/urxvtd.nix>` should be a good place to
start looking for the NixOS syntax).
