# -----------------------------------------
# FEDORA DEVEL INSTALATION KICKSTARTER FILE
# -----------------------------------------
# this file is made for Czech language version, with CZ keyboard and "root_password". Besides load of packages, everything else is general.
# -----------------------------------------
# for more info look at Fedora documentation: https://docs.fedoraproject.org/en-US/Fedora/20/html/Installation_Guide/s1-kickstart2-options.html
# -----------------------------------------

install
text				# Use text install
reboot

# Keyboard layouts
keyboard --vckeymap=cz --xlayouts='cz','us' --switch='grp:alt_shift_toggle'	# Handy to use full keyboard potentional from beginning
# System language
lang cs_CZ.UTF-8

network --bootproto dhcp
timezone --utc Europe/Prague
firstboot --disable		# Do not run the Setup Agent on first boot

# Users
rootpw root_password
# user --name=first_user --password=user_password --gecos="First_user"

# Security
firewall --enabled --ssh
selinux --disabled
#selinux --enforcing

# Disk setup
bootloader --location=mbr --append="console=tty0 console=ttyS0,115200 rd_NO_PLYMOUTH"
zerombr
clearpart --all --initlabel
autopart



# -----------------------

%packages
openssh
openssh-clients
wget				# should be commented out for centos
nano				# my favourite :p
tree

# to this point it was just basic install

fedora-packager
@development-tools
rpmdevtools
rpm-build
fedora-review
mc				# midnight commander
mock
meld

gcc
gcc-c++
gdb

fedpkg

sssd				# packages for Kerberos
krb5-workstation		#
pam_krb5			#

coreutils
base64				# decoding TAR

%end

# -----------------------

%post --nochroot

if [ -f /tmp/TAR ]; then
  base64 -d /tmp/TAR > /tmp/TAR_decoded
  tar -xf /tmp/TAR_decoded -C /mnt/sysimage/root
fi

%end

# -----------------------

%post

dnf upgrade -y
systemctl enable sshd

echo -e "# user defined aliases\n
export EDITOR=nano
export UAEDITOR=nano
export VISUAL=nano" > /etc/profile.d/alias.sh;

%end

# -----------------------
