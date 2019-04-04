sudo mkdir /mnt/RAMDisk
sudo bash -c 'echo -e "tmpfs /mnt/RAMDisk tmpfs nodev,nosuid,size=50M 0 0">> /etc/fstab'
sudo mount -a
