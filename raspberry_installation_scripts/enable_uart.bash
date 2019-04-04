#Script to use UART Communication
#Make sure you've executed the stuff with the Virtualenv in the other scripts before this one

#Deactivate tty output on UART
sudo sed -i 's/console=serial0,115200//g' /boot/cmdline.txt
sudo bash -c 'echo "enable_uart=1" >> /boot/config.txt'
sudo apt-get install minicom cmake screen

cd 
workon cv
pip install pyserial
