sudo umount  /mnt/RAMDisk
sudo rmdir /mnt/RAMDisk
sudo sed -i '/RAMDisk/d' /etc/fstab
