{ ... }:

{
  home-manager.users.kaizen = {
    # Enable Natural Scrolling
    programs.plasma.input.touchpads = [{
      enable = true;
      name = "ETPS/2 Elantech Touchpad";
      vendorId = "0002";
      productId = "000e";

      naturalScroll = true;
    }];

  };
};

