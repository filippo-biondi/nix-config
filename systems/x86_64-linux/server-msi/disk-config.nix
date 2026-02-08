{
  disko.devices = {
    disk = {
      my-ssd = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_2TB_S5RPNF0T604842M";
        content = {
          type = "gpt";
          partitions = {

            # 1. Boot Partition
            ESP = {
              priority = 1;
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            # 2. Swap Partition (New)
            swap = {
              priority = 2;
              size = "16G";
              content = {
                type = "swap";
                # 'discardPolicy' enables TRIM. Crucial for SSD longevity & performance.
                discardPolicy = "both";
                # 'resumeDevice' tells NixOS to use this for hibernation (suspend-to-disk).
                resumeDevice = true;
              };
            };

            # 3. Root Partition
            root = {
              priority = 3;
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };

          };
        };
      };
    };
  };
}
