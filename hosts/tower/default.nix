{ ... }:

{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix # Include the results of the hardware scan.
    #./modules # TODO organise into separate files
  ];
}