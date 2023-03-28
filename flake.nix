{
  description = "Flake for paymo-widget";

  inputs = {
    # Nixpkgs / NixOS version to use.
    # nixpkgs.url = "nixpkgs/nixos-unstable";

    paymo-widget-appimage = {
      url = "https://s3.amazonaws.com/widget.paymoapp.com/paymo-widget-7.2.8-x86_64.AppImage";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, paymo-widget-appimage }:
    let

      # System types to support.
      supportedSystems =
        [
          "x86_64-linux"
          # "x86_64-darwin"
          # "aarch64-linux"
          # "aarch64-darwin"
        ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        });
    in
    {

      # A Nixpkgs overlay.
      overlays.default = final: prev:
        with prev.pkgs; {
          paymo-widget = appimageTools.wrapType2 # or wrapType1
            {
              name = "paymo-widget";
              src = paymo-widget-appimage;
            };
        };

      # Package
      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) paymo-widget;
        default = self.packages.${system}.paymo-widget;
      });
    };
}
