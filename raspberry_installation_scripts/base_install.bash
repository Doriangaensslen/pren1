##Based on Tutorial found in 
#https://www.pyimagesearch.com/2017/09/04/raspbian-stretch-install-opencv-3-python-on-your-raspberry-pi/

#lxrandr helps for the screen resolution

#Expand FS
sudo raspi-config --expand-rootfs

mkdir /home/pi/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCW1BFO/++g1DbCp8V5ZDgj6Qan+zJCJ2AZ8qorwwpIfI73LtUpYF+5be9eEniqaE7vH73YSUls9wPz53aMuJrTyjNDOfd1GFfOwk/MtlpcDbR5IdlPoL/2UzBJ+a5v7WHT3FMYa9e8QtCEkegU1FeEJ62VgRkMpZh0rfiEFygNxayL/gGXk/5ISsTQEaBGCLAZO/UqH+uS7bjJ4iBj0JDWVjzN1A+S4vrdzKwj91y8CUiIwJ6TF5Zv3vh8XuTsxTnlYMowsO14Mi7p+whH3LlxngBkkijPGX0gFlwEhRcVwcYYw+NFQBSUsBUmmOKa4uYp+ORamVVoD3Nt+l9KEBnH dorian@Dorians-MacBook-Pro.local" >> /home/pi/.ssh/authorized_keys

#Install Kernel Headers
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y linux-headers-$(uname -r)

#Remove unnessecary stuff
sudo apt-get purge -y wolfram-engine
sudo apt-get purge -y libreoffice*
sudo apt-get clean
sudo apt-get autoremove -y

#################################3#Install OpenCV 3 + Python
#CMAKE helps configure OpenCV
sudo apt-get install -y build-essential cmake pkg-config

#Allow to load various image media types
sudo apt-get install -y libjpeg-dev libtiff5-dev libpng-dev 

#Allow to load various  video media types
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install -y libxvidcore-dev libx264-dev

#Install highgui dependencies
sudo apt-get install -y libgtk2.0-dev libgtk-3-dev

#opencv optimisation libraries
sudo apt-get install -y libatlas-base-dev gfortran

#Python headers
sudo apt-get install -y python2.7-dev python3-dev

#Download opencv and make a zip file
cd ~
#wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.3.0.zip because newer version is available
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.0.0-rc.zip
unzip opencv.zip

#Download opencv additional libraries
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.0.0-rc.zip 
unzip opencv_contrib.zip

#Install Python pip with virtualenv
sudo apt-get install -y virtualenv virtualenvwrapper python3-pip python-pip
sudo rm -rf ~/.cache/pip
sudo pip3 install virtualenv virtualenvwrapper


echo -e "\n# virtualenv and virtualenvwrapper" >> ~/.profile
echo "export WORKON_HOME=$HOME/.virtualenvs" >> ~/.profile
echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.profile
echo "source /usr/share/virtualenvwrapper/virtualenvwrapper.sh" >> ~/.profile
source ~/.profile

#Create virtualenv
mkvirtualenv cv --python=/usr/bin/python3
workon cv
pip install numpy picamera

#Compile OpenCV
cd ~/opencv-4.*/
mkdir build
cd build
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1024/g' /etc/dphys-swapfile
sudo systemctl restart dphys-swapfile.service
cmake -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D INSTALL_PYTHON_EXAMPLES=ON \
  -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-4.0.0-rc/modules \
  -D BUILD_EXAMPLES=ON ..

sudo make -j4
sudo sed -i 's/CONF_SWAPSIZE=1024/CONF_SWAPSIZE=100/g' /etc/dphys-swapfile
sudo systemctl restart dphys-swapfile.service
sudo make install

#Copy stuff oround so its accessible from the environment
cd /usr/local/lib/python3.5/site-packages/
sudo mv cv2*.so cv2.so
cd ~/.virtualenvs/cv/lib/python3.5/site-packages/
ln -s /usr/local/lib/python3.5/site-packages/cv2.so cv2.so
cd 
sudo rm opencv* -rf

#Install git
sudo apt-get install -y git

#Install Tesseract from Source
sudo apt-get install -y libleptonica-dev git
git clone --depth 1  https://github.com/tesseract-ocr/tesseract.git
cd tesseract/
./autogen.sh
./configure
make
sudo make install
sudo ldconfig
tesseract -v
cd 
mkdir tessdata
cd tessdata
wget https://github.com/Shreeshrii/tessdata_shreetest/raw/a2266e2164e06dd337369afcd0ec161ac9f5bded/digits.traineddata 
#wget https://github.com/tesseract-ocr/tessdata_fast/blob/master/eng.traineddata
echo "export TESSDATA_PREFIX=/home/pi/tessdata" >> ~/.profile 

pip3 install pytesseract

#Just VBOX Settings
#sudo apt-get install -y virtualbox-guest-dkms virtualbox-guest-x11
#sudo adduser pi vboxsf
#sudo shutdown -r now

#Make Sure, the i2c stuff is installed and nabled
sudo bash -c 'echo -e "i2c-bcm2708\ni2c-dev" >> /etc/modules'
sudo apt-get install -y i2c-tools python-smbus

sudo bash -c 'echo "dtparam=i2c_arm=on" >> /boot/config.txt'
