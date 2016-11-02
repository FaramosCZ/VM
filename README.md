# Virtual Machines easy autonomous instalation tool

Main file:
  VM_install.sh
 
Description:
  This script anyone can easily install VMs in Fedora, RHEL or CentOS.
  It does the install absolutely autonomous. All I/O is directed to the console.
  It uses *.ks Anaconda kickstarter files to configure instalation process.
  
  ---
  
*.ks - Anaconda kickstarter files:
  basic_install.ks
  fedora_devel_install.ks
  
Description:
  Theese files are used for automatic instalation. Modify them and create new in order to fully customize your instalation.
  
---

Other files:
  .nanorc
  fedora_devel_user_setup.sh
  
Description:
  Theese files are downloaded from this repo to the VM. They are used for easy preparation of VM's environment.
