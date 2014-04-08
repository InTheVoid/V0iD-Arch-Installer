#! /bin/bash

#-------------------------------------------------------------------
#                                                                  #
# Coded By: TheV0iD                                                #
#                                                                  #
# V0iD Pwns!                                                       #
#                                                                  #
# Contact: VoidPwn@Linuxmail.org                                   #
#                                                                  #
#-------------------------------------------------------------------


#------------------------------------------
# 				      Vars   Default
#
# Basic Info
h0stname = "arch"
username = "user"
password = "pass"
rootpass = "root"

# Partition Info
boot_hd = "/dev/sda1/"
root_hd = "/dev/sda2/"
home_hd = "/dev/sda3/"
swap_hd = "/dev/sda4/"
yn = "yes"

#
#------------------------------------------

# Functions:
#-------------------------------------------------------------------

# Basic Information:
function basicinfo() {
echo "Type the basic information to install:"
echo "Hostname:"
read $h0stname
echo "Type your new username:"
read $username
echo "Type your new password:"
read $password
echo "Type your new ROOT password:"
read $rootpass
echo "Is this info right? (y/n)"
read $yn
if [$yn = "no"] then
	 basicinfo
fi
}


# Partition Information
function getpart () {
echo "Now type what your new partitions."
echo "Boot:"
read $boot_hd
echo "Root:"
read $root_hd
echo "Home:"
read $home_hd
echo "Swap:"
read $swap_hd

echo "Are your partitions right? (y/n)"
read $yn
if [$yn = "no"] then
	 getpart
fi
}


#-------------------------------------------------------------------


# Welcome!
#-------------------------------------------------------------------


echo "------------------------------------"
echo " Welcome to the V0iD Arch Installer "
echo "------------------------------------"
echo
echo "Requirements:"
echo "-> Logged as Root on Arch Install CD/DVD First Boot"
echo "-> Internet Connection (DHCPCD)"
echo "-> Know how to use CFdisk"
echo
echo 
sleep 2
#-------------------------------------------------------------------






# Getting Basic Info:
#-------------------------------------------------------------------

basicinfo

#-------------------------------------------------------------------




# Setting Keyboard-Lang
#-------------------------------------------------------------------

loadkeys br-abnt2 &
echo "Keyboard Configured"
echo "Press Any Key to Continue..."
read $anykey

#-------------------------------------------------------------------



# Getting Partition Info:
#-------------------------------------------------------------------
clear
echo
echo "-------------------"
echo "Partitions Config:"
echo "-------------------"

echo "You will be moved to CF Disk to configure your partitions"
echo "Boot / Root / Home / Swap"
echo "After you must type they here!"
echo "SWAP MUST BE SEPARATED"
sleep 2
echo
echo
echo " Examples:
+----------------+----------+-----------+----------+--------------+
| Example:       |Boot      | Root      |Home      | Swap         |
+----------------+----------+-----------+----------+--------------+
| All in One     |/dev/sda1 |/dev/sda1  |/dev/sda1 |/dev/sda2     |
+----------------+----------+-----------+----------+--------------+
| Separated      |/dev/sda1 |/dev/sda2  |/dev/sda3 |/dev/sda4     |
+----------------+----------+-----------+----------+--------------+
| Separated Grub |/dev/sda1 |/dev/sda2  |/dev/sda2 |/dev/sda3     |
+----------------+----------+-----------+----------+--------------+
"
echo 
echo "Press Any Key to Continue..."
read $anykey

# Iniciating CFDISK for user particionate the disk:

echo
echo "Starting cfdisk..."
sleep 2
cfdisk

# Getting Partitions from user:

getpart

echo "Partitions configured sucessfully"

#-------------------------------------------------------------------




#Formating Partitions
#-------------------------------------------------------------------
clear
echo "-------------------"
echo "Partition Formating"
echo "-------------------"
echo
echo "In this script we use EXT4"
echo "Starting Partition Formating..."
sleep 2
echo
echo
echo "Formating Boot Partition..."
mkfs.ext4 $boot_hd
echo "Done"
echo
echo "Formating Root Partition..."
mkfs.ext4 $root_hd
echo "Done"
echo
echo "Do you want to format home partition? (yes/no)"
read $yn
if [$yn = "yes"] then
	mkfs.ext4 $home_hd
fi
echo "Done."
echo
echo "Formating Swap Partition..."
mkswap $swap_hd
swapon $swap_hd
echo "Done"
echo
echo
echo "Partitions Formated!"
sleep 3

#-----------------------------------------------------------------------



# Mounting Partitions
#-----------------------------------------------------------------------
echo "------------------"
echo "Partition Mounting"
echo "------------------"
echo
mount $root_hd /mnt
echo "$root_hd mounted in /mnt"
mkdir /mnt/{boot,home}
echo "Folders /mnt/boot and /mnt/home created."
mount $boot_hd /mnt/boot
echo "$boot_hd mounted in /mnt/boot"
mount $home_hd /mnt/home
echo "$home_hd mounted in /mnt/home"
sleep 2
#-----------------------------------------------------------------------



# Installing Base and Base Devel / Making the Fstab
#-----------------------------------------------------------------------

clear
echo "System Installation:"
echo "Installing Base and Base Devel"

# Install Base:
pacstrap /mnt base base-devel
echo "Base system sucessfully installed"
sleep 3
clear


echo "Installing Grub:"
# Install Grub:
pacstrap /mnt grub-bios
echo "Grub Sucessfully installed"
sleep 3
clear


# Fstab gen:
echo "Generating the fstab"
genfstab -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
echo "Fstab has been generated sucessfully."

#-----------------------------------------------------------------------

#Generating Host name and configuring
#-----------------------------------------------------------------------
clear
echo "-------------"
echo "Configuration"
echo "-------------"
#Define Hostname
echo "Defining hostname..."
echo $h0stname > /mnt/etc/hostname
echo "You Machine name has been defined, its $h0stname"

#Define local time
echo "Configuring Local time"
arch-chroot /mnt /bin/bash -c "ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime"
echo "Your system is configured to use Sao Paulo localtime."

#Setting language
echo "Configuring language"
arch-chroot /mnt /bin/bash -c echo "pt_BR.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c echo "pt_BR ISO-8859-1" >> /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen"
echo "Your system is configured in PT_BR"

#Preparing Randisk
echo "Preparing Randisk..."
arch-chroot /mnt /bin/bash -c "mkinitcpio -p linux"
echo "Randisk created sucessfully"

#Setting Grub Up!
echo "Configuring Grub..."
arch-chroot /mnt /bin/bash -c "modprobe dm-mod"
arch-chroot /mnt /bin/bash -c "grub-install --recheck --debug "${boot_hd:0:8}
arch-chroot /mnt /bin/bash -c "mkdir -p /boot/grub/locale"
arch-chroot /mnt /bin/bash -c "cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo"
arch-chroot /mnt /bin/bash -c "pacman -S osprober"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
echo "Grub Configured sucessfully"

# Configuring Root Password
echo "Configuring Root Password"
arch-chroot /mnt /bin/bash -c "passwd << EOF
$rootpass
$rootpass
EOF"
echo "Your Root password is: $rootpass"

# Adding new user
echo "Creating user..."
arch-chroot /mnt /bin/bash -c "useradd -m -G audio,dbus,lp,network,optical,power,storage,users,video,wheel -s /bin/bash $username"
arch-chroot /mnt /bin/bash -c "passwd $username << EOF
$password
$password
EOF"
echo
echo
echo "User created"
echo "Username: $username"
echo "Password: $password"
sleep 5

echo "-------------------------------------------------------------"
echo "			           INSTALLATION DONE   		               "
echo "-------------------------------------------------------------"
echo 
echo "Arch Linux Simple installer by TheV0iD"
echo "Thank you for using it"
echo
echo
echo
echo "Contact: VoidPwn@Linuxmail.org"
sleep 3
echo
echo
echo "Rebooting in 15 seconds..."
sleep 15
reboot
