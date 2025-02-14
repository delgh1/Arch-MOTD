     __________________________________
    / MOTD for Arch Linux Systems      \
    | This repository is for you Arch  |
    \__________________________________/
       \
        \
          .--.
         |o_o |
         |:_/ |
        //   \ \
       (|     | )
      /'\_   _/`\
      \___)=(___/

![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/delgh1/Arch-MOTD/issues)

These scripts look great for your MOTDS on Arch Linux systems.

You can see the [Installation Guide](https://github.com/lfelipe1501/Arch-MOTD/wiki/Installation-Guide) in the [WIKI](https://github.com/lfelipe1501/Arch-MOTD/wiki) session

And also how these [MOTD's look](https://github.com/lfelipe1501/Arch-MOTD/wiki/MOTD-captures)

### Forked from

Developer / Author: [Luis Felipe Sánchez](https://github.com/lfelipe1501)
Also inspired by [Johnny Mileham](https://github.com/jrmileham/arch-motd)

## WARNING
[07-Sept-2020] A linux pam update arrived in August 2020: `pam-1.4.x` and `pambase 20200721.x`. This update changes the `/etc/pam.d/system-login` and might cause conflicts with changes by the steps below. This protentially prevents user login (affecting `sudo` and `su` too) after update. **Make sure you back up the `/etc/pam.d/system-login` before making changes and check it after the `pam 1.4.x` update has been applied to your system**

## Features
Pretty self explanatory. It works for Arch linux on:
-  x86_64 machines (Intel/AMD based)
-  ARM based machines (Raspberry Pi) 

It will auto detect which architecture your system is and work accordingly.

Currently it can only display temperatures for Raspberry Pi, but using the `lm_sensors` package this could be done.

## Usage
The MOTD is usually displayed when a user logs into the system (via KB and mouse or ssh or other means). The Linux PAM config specifies the when to display the MOTD. 

The `generate_motd.sh` script executes on user login to output to the motd. Then at the "display motd" step of user login the new generated output is displayed. - _This is what makes the motd dynamic._

Once installed, log in to your system and the script will update your `/etc/motd` with system data.

This happens before the user is given a prompt and after successful login.

## Setup

**Please Note: Editing the PAM configuration can be dangerous and will break your system if done incorrectly. It is recommended to back up before making changes otherwise you may not be able to log into your system again.**

1. Install the `update_motd.sh` in `/usr/bin/` directory
2. Give the script the same permissions as any other app in `/usr/bin` (run as root or sudo): `chmod 755 /usr/bin/update_motd.sh`
3. Make sure the script has the correct ownership: `chown root:root /usr/bin/update_motd.sh`
4. Update the `system-login` pam config file to execute the script before displaying the `motd`
  
### Updating the pam file (method 2):
The below changes will affect all logins (local, ssh etc.) If you wish to do just ssh, then do something different. **Please understand what changes your are making and their impact before you do it**

In the file: `/etc/pam.d/system-login` add the new line.

Go from this:
```
session    include    system-auth
session    optional   pam_motd.so          motd=/etc/motd
```
To this:
```
session    include    system-auth
session    optional   pam_exec.so          /bin/generate_motd.sh
session    optional   pam_motd.so          motd=/etc/motd
```

**Please Note: Check these settings against the Linux PAM manual and be aware of changes you are making mean for your system.**

Information about linux PAM can be found here:
- [https://dzone.com/articles/linux-pam-easy-guide](https://dzone.com/articles/linux-pam-easy-guide)
- [https://linux.die.net/man/8/pam](https://linux.die.net/man/8/pam)
- [https://linux.die.net/man/5/pam.d](https://linux.die.net/man/5/pam.d)
- [https://wiki.archlinux.org/index.php/PAM](https://wiki.archlinux.org/index.php/PAM)
