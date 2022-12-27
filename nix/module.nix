inputs: { config, lib, pkgs, ... }:
with lib; let
  cfg = config.programs.libvfio;
  arcd = inputs.self.packages.${pkgs.system}.default;

in {
  options.programs.libvfio = {
    enable = mkEnableOption ''

    '';

    intel = mkEnableOptions ''
    '';

    amd = mkEnableOptions ''
    '';
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [ arcd ];
    };
    users.groups = [ kvm ];

    boot = {
      kernelParams = if intel then [ "intel_iommu=on" "iommu=pt" "vfio_pci" "vfio" "mdev" ]
        else [ "amd_iommu=on" "iommu=pt" "vfio_pci" "vfio" "mdev" ];

      blacklistedKernelModules = [ "nouveau" "amdgpu" "amdkfd" ];
    };
  };
}

  
  
