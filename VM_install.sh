#!/bin/bash
#-----------------------------------------------------------------------------------------------------
#	INFO:
#		Additional informations for installation are stored inside *.ks files
#		If you look for set root password for example, that is the right file, not this script
#-----------------------------------------------------------------------------------------------------
# Colors for mossages
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
WHITE='\033[1;37m'
DEFAULT='\e[0m'

# Prints help if no arguments were provided by the user
function script_info
  {
   echo -e "${WHITE}"
   echo -e "
    SCRIPT USAGE: ${LIGHT_GREEN}
        $0 -n name_of_new_VM -s source_url_or_ISO -ks kickstart_file -d VM_image_dir [--size size_in_GB] [-c] [--GUI] ${WHITE}

        -n|--name <name_of_new_VM>${DEFAULT}
              Name of the new Virtual Machine${WHITE}
        -s|--source <source_url_or_ISO>${DEFAULT}
              Either URL to the OS repository (containing 'repodata' folder) or the OS ISO.
              Example: http://mirror.vutbr.cz/fedora/releases/24/Everything/x86_64/os/${WHITE}
        -ks <kickstart_file>${DEFAULT}
              Path to Anaconda kickstart file to use. Some basic ones are provided on Git.${WHITE}
        -d VM_image_dir${DEFAULT}
              Directory where the VM image will be stored.${WHITE}
        --size size_in_GB${DEFAULT}
              Specify size of the VM image in GB. Default is 15 GB.${WHITE}
	-c | --copy_files${DEFAULT}
	      Set, if you want to copy content of config_files folder to VM${WHITE}
        --GUI${DEFAULT}
              Set, if you want to go through instalation in graphic mode. Text mode is default.${WHITE}

    SCRIPT PURPOSE:${DEFAULT}
        This script will install new VM. When correct kickstart file provided, the installation
        is completely non-interactive.${WHITE}

    WARNING:${DEFAULT}
        This particular copy of the script is optimized for Fedora Rawhide instalation.
        For RHEL or CentOS instalations, some minor changes must be made.${WHITE}

    INFO:${DEFAULT}
        This script must be run under root user.
   " 1>&2
   echo -e "${DEFAULT}"
   exit 1
  }

[[ $EUID -ne 0 ]] && { # Force script to be run under root user
    echo -e "${LIGHT_RED}"
    echo "The script must be run as root user!"
    echo -e "${DEFAULT}"
    script_info
}

#-----------------------------------------------------------------------------------------------------
# Check the basics - if virtualization tools are installed in the host system

dnf install -q -y @virtualization coreutils base64
systemctl start libvirtd && systemctl enable libvirtd && systemctl start virtlogd

#-----------------------------------------------------------------------------------------------------
# Gets arguments

GUI="--nographics"
SIZE="10"	# default size of disk in GB

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--name)
    VM_NAME="$2"
    shift # past argument
    ;;
    -s|--source)
    SOURCE="$2"
    shift # past argument
    ;;
    -ks)
    KS_FILE="$2"
    shift # past argument
    ;;
    -d|--dest)
    DEST="$2"
    shift # past argument
    ;;
    --size)
    SIZE="$2"
    shift # past argument
    ;;
    -c|--copy_files)
    FILES="./config_files"
    shift # past argument
    ;;
    --GUI)
    GUI=""
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
  esac
  shift # past argument or value
done

# Check, if following variables exists
if [ -z ${VM_NAME+x} ] || [ -z ${SOURCE+x} ] || [ -z ${KS_FILE+x} ] || [ -z ${DEST+x} ]; then
    echo -e "${LIGHT_RED}"
    echo "Use at least the following required options: -n, -s, -ks, -d"
    echo -e "${DEFAULT}"
    script_info
fi

# Check, if *.ks file exist
if [ ! -f "$KS_FILE" ]; then
    echo -e "${LIGHT_RED}"
    echo "$KS_FILE does not exist !"
    echo -e "${DEFAULT}"
    exit 1;
fi

# Check, if *.ks file is readable
if [ ! -r "$KS_FILE" ]; then
    echo -e "${LIGHT_RED}"
    echo "$KS_FILE can't be read. Check its permissions !"
    echo -e "${DEFAULT}"
    exit 1;
fi

# Check, if config_files dir exist
if [ ! -z ${FILES+x} ]; then
  if [ ! -d "$FILES" ]; then
    echo -e "${LIGHT_RED}"
    echo "config_files folder does not exist !"
    echo -e "${DEFAULT}"
    exit 1;
  fi
fi

#-----------------------------------------------------------------------------------------------------
# Installation arguments

rm -f "/var/local/$(basename $KS_FILE)"
cp -u $KS_FILE /var/local/

# make tarball form ./config_files/ folder
TAR=$(tar -cO $FILES | base64)
# write it into ks file
echo -e "%pre\necho \"$TAR\" >> /tmp/TAR \n%end" >> /var/local/$(basename $KS_FILE)



virt-install                                                     \
    --connect   qemu:///system                                   \
    --network   bridge:virbr0                                    \
    --initrd-inject /var/local/$(basename $KS_FILE)              \
    --name      "$VM_NAME"                                       \
    --disk      "$DEST/$VM_NAME".qcow2,size="$SIZE",format=qcow2 \
    --memory    2048                                             \
    --location  "$SOURCE"                                        \
    --hvm                                                        \
    --vcpus=2                                                    \
    --check-cpu                                                  \
    --accelerate                                                 \
    $GUI                                                         \
    --extra-args    "ks=file:/$(basename $KS_FILE) console=tty0 console=ttyS0,115200"

rm -f "/var/local/$(basename $KS_FILE)"

# for more info use "man virt-install"
#-----------------------------------------------------------------------------------------------------
