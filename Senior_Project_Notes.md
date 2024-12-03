# Senior Project Notes

Personal notes - Alex Chan-Nui

## 9/28/2024

### Update XDS110 Probe

Worked on LP board tried flashing boarder router image on board L45002VL (2VL) using Uniflash - Errored out

Error Message : IcePick_C: Error initializing emulator: A firmware update is required for the XDS110 probe. The current
firmware is version 3.0.0.15. The probe must be upgraded to firmware version 3.0.0.31 to be compatible with this
software. Click the "Update" button to update the firmware. DO NOT UNPLUG THE DEBUG PROBE DURING THE UPDATE. (Emulation
package 12.8.0.00194)

Found fix on how to update XDS110 probe - [Failed to flash CC26X2R1 with Z-Stack 3.0 · Issue #150 ·
Koenkk/Z-Stack-firmware (github.com)](https://github.com/Koenkk/Z-Stack-firmware/issues/150)

See vanlooverenkoen’s last post for solution to update XDS110 probe

I downloaded CCS using full install

Tried into installed ns_br example code from CCS resource explorer. Needed to install SIMPLELINK-LOWPOWER-SDK first (
auto installed)

used xdsdfu program found in path below

**Please Note I used my M1 macbook to update XDS110 Probe**

I did tried to update XDS110 probe on my windows machine and after using the "./xdsdfu.exe -m" command the probe
wouldn't reappear when
enumerated. As well using a VM on my windows box the LPs did not even enumerate in the vm.

```commandline
C:/ti/ccs1280/ccs/ccs_base/common/uscif/xds110
```

used -e option to show boards the computer can see.

```commandline
./xdsdfu -e
```

used -m to boot LP in to DFU mode

```commandline
./xdsdfu -m
```

use -f command when in DFU mode to load new firmware for the XDS110. -r restarts the board automatically after it's
finished uploading new firmware

**Please note sometimes will not auto restart** - if that happens just unplug and replug in the device after the
firmware flash complete message

```commandline
./xdsdfu -f <firmware file> -r
```

## 9/29/2024

### Flash LPs

**Please Note used windows box to flash LP boards**

using Uniflash use auto-detect feature to find board connected to my windows box

from Caden's email downloaded the new images of the boarder router and nodes for the LPs

2VL flashed with boarder router image

L45002UP (2UP) flashed with nodes image

### TI Wi-SUN FAN Fundamentals Guide (spinel)

Following setup guild
from [TI Wi-SUN FAN Fundamentals](https://dev.ti.com/tirex/explore/node?node=A__AEC7OIp.3CPq3lrOwxTFog__com.ti.SIMPLELINK_ACADEMY_CC13XX_CC26XX_SDK__AfkT0vQ__6.40.00.00)

downloaded python 3.10

downloaded SimpleLink CC13xx CC26xx SDK(7.41.00.17)

ran setup_pyspinel.sh script in SDK download pyserial and ipaddress

**Please note when using a USB hub VM may have issues connecting to both LPs at the same time**

I had an issue where using a usb hub only 1 LP would connect to the VM at a time **Note fix for that is plug LPs into
different USB ports**

SDK Path :

```commandline
cd ~/ti/simplelink_cc13xx_cc26xx_sdk_7_41_00_17/tools/ti_wisunfan/pyspinel_repo/ti-wisunfan-pyspinel
```

ran command below can run help command but errors out with running ncpversion command

```commandline
python3 spinel-cli.py -u /dev/ttyACM0
```

**Please Note when running command above with LPs connected using usb setting vm ncpversion would error out**

serial ports will enumerate but will not be able to communicate to them

**Work Around** - Forward host COM port to VM rather than USB device

1. find serial port settings
2. set port mode to host device
3. set path to "COM\<number>:" (e.g. COM3:)

**Please Note** - set port speed in Windows device manager to 115200 bits per second. Devices will show under "Ports (
COM & LPT)" as "XDS110 Class Application/User UART" or "XDS110 Class Auxiliary Data Port"

use command below to find the tty port to use when starting up spinel-cli.py

```commandline
sudo dmesg | grep tty
```

ttyS(0-3) are COM ports used. you just have to know the order you assigned them

```commandline
python3 spinel-cli.py -u /dev/ttyS<Number>
```

After setting following set steps ncpversion now works

when in spinal use command below to check if node is border router and will error if not

```commandline
connecteddevices
```

must run following commands before using wfanctrl on boarder router

```commandline
ifconfig up
```

```commandline
wisunstack start
```

```commandline
routerstate
```

when connecting router node (RN) it will take a few minutes for it to return connected

**Please Note** - wisunstack will show stop even after a start command it given. Will show start after connected

**Please Note** - when RN connects to border router (BR) the RN will not display IP address

Question: where to get good cases for LPs

### wfantund Guide

Following [wfantund guide](https://github.com/TexasInstruments/ti-wisunfantund/blob/release/INSTALL.md)

use all processors

```commandline
make -j $(nproc)
```

additional instruction for beagleplay setup **good to know**

Follow instructions at wfandtund guild for download and build instructions

this command will bring up wfantund with BR

check BR ttyS number before running command - must also exit spinal if connected to BR before running

```commandline
sudo /usr/local/sbin/wfantund -o Config:NCP:SocketPath /dev/ttyS0
```

used to control wfantund

```commandline
sudo /usr/local/bin/wfanctl
```

commands below bring up wfantund after running command above

```commandline
sudo wfanctl set interface:up true
sudo wfanctl set stack:up true
```

after starting up wfantund you can start up the connection between the BR and RN just bring up the RN like shown in
above section. after that is complete you can ping the RN ip address from the host machine

## 10/01/2024

### Failed boot up of wfantund

**Must bring BR up with wfanctl**

if not you will see "garbage on the line" from wfantund

reset with command below with spinal on the BR after stopping all wfantund and wfanctl

```commandline
reset
```

gets ip addresses of connected devices

```commandline
get connecteddevices
```

see all ipv6 addresses in the BR in wfantund

```commandline
get IPv6:AllAddresses
```

can't type b letter in spinal - reason unknown

Issue: find a way to talk to LPs through USB `ttyACM<number>` and not through serial port

### boot up instructions

first boot up wfantund

first should be done in one terminal

```commandline
sudo wfantund -o Config:NCP:SocketPath /dev/wisun-br0
```

These commands should be done in another

```commandline
sudo wfanctl 
```

```commandline
set interface:up true
```

```commandline
set stack:up true
```

these command should be done on the RN in a separate terminal as well

```commandline
spinel-cli.py -u /dev/ttyACM<number>
```

```commandline
ifconfig up
wisunstack start
```

after all those are completed ping the RN address from the host by using the following command in wfanctl to find the
address

```commandline
get connecteddevices
```

## 10/02/2024

### Kea Quick Start

Following [kea quick start guide](https://kea.readthedocs.io/en/latest/arm/quickstart.html)

failed openssl test when running ./configure

found correct package by checking config.log - then reading configure at the line where error occurred

installed libssl-dev

failed test - configure: error: Missing required header file (logger.h) from the log4cplus package

installed liblog4cplus-dev

installed libboost-system-dev

### After Meeting

tried building Kea dhcp server - not enough space in VM

needed to add space in vm

copied VM's VDI to resize

tried to resize VDI using Ubuntu VM but didn't boot well

downloaded system rescue ISO to boot into so I could run parted, resizepart, resize2fs and e2fsck on the VDI

once done was able to attach the new VDI to the VM

## 10/04/2024

communicated with Caden so that we have new LP firmware to work with external DHCP servers

### Kea Quick Start Continued

built Kea

## 10/07/2024

### VM USB work around

changed USB settings in VM to USB3

added filter of USB device - deleted all but

- name
- vendor id
- product id
- port
- remote = no

shut down Virtualbox fully after added filter

assume first connection is the correct connection

use pyspinal to check if port `ACM<number>` accepts commands

Question - what does the second connection do? why is it there?

## 10/08/2024

cloned [ti-wisunfantund-UTD](https://github.com/AChannui/ti-wisunfantund-UTD) fork

rebuilding wfantund see **wfantund Guild** under **9/28/2024**

### kea Quick start Cont.

using keactrl started up kea dhcp IPv6 version

```commandline
sudo keactrl start -s dhcp6
```

Flashed boards with new firmware

### create startup shell scripts

how to get info on usb port

```commandline
udevadm info /dev/ttyACM<number>
```

**all scripts assume 2 devices**

created a sim link script to create simlinks of the ports used by the LPs - simlinks used in all scripts

created script to start up the BR and RN - **NOTE** when piping into wfanctl from commandline wfanctl will error out

edited startup script so that the wfantund needs to be started in separate terminal

created script to shutdown wfantund and reset LPs

created script to print status of BR and RN

### boot up and shut down instructions external dnsmasq

1. run sim_link_setup.sh

```commandline
~/senior_project/sim_link_setup.sh
```

2. start wfantund and dnsmasq commands bellow uses separate terminals

```commandline
sudo wfantund -o Config:NCP:SocketPath /dev/wisun-br0
```

```commandline
~/senior_project/startup.sh
```

```commandline
cd ~/ti-wisunfantund-UTD/external-servers
```

```commandline
docker-compose run --rm dnsmasq
```

3. OPTIONAL run status.sh

```commandline
~/senior_project/status.sh
```

4. run shutdown.sh and you will need to kill dnsmasq manually

```commandline
~/senior_project/shutdown.sh
```

### dnsmasq boot

following [external servers README](https://github.com/AChannui/ti-wisunfantund-UTD/tree/feature-external-dhcp-server/external-servers)

installed docker-compose

commands with `docker compose` don't work need to say `docker-compose`

```commandline
docker-compose build
```

```commandline
docker-compose run --rm dnsmasq
```

encountered error:
`/bin/sh: 1: sudo: not found
ERROR: Service 'dnsmasq' failed to build : The command '/bin/sh -c sudo apt update && sudo apt install -y nano iproute2 curl systemctl' returned a non-zero code: 127`

fixed by deleting sudo in Dockerfile

Question: let caden know that sudo is not needed in Dockerfile in dnsmasq

get access to IPv6 leases with docker - this command gets you into the docker

```commandline
docker exec -it <CONTAINER ID> /bin/sh
```

lease in file bellow

```commandline
/var/lib/misc/dnsmasq.leases
```

started wfantund with external DHCP server dnsmasq

learned about arguments used in Dockerfile

created a dnsmasq.conf using the arguments from the Dockerfile

edited Dockerfile again to use the new dnsmasq.conf file I created

## 10/11/2024

set up working environment on beelink - scripts don't work properly must bring up and down by hand

helped larry download wfantund and tried to solve issue with XDS110 prob but couldn't find solution -

status while loop to check rn

```commandline
while sleep 1 ; do echo $(date) $(echo "routerstate" | spinel-cli.py -u /dev/wisun-rn0) ; done 
```

## 10/12/2024

convert json to yml for easier editing

```commandline
cat kea-dhcp6.conf | grep -v " *//" | yq -y . >| ~/tmp1
```

convert back to json

```commandline
yq . < tmp1 > tmp1.json
```

## 10/13/2024

wrote kea-dhcp6.conf - not working kea wont lease out addresses - kea will reposond to wfandtund

```commandline
sudo kea-dhcp6 -c tmp1.json 
```

I think the issue is I might be shutting down the dhcp server to quickly or wanting a response to quickly - possible
next time is to time how long it takes the RN to get a lease from dnsmasq

timed how long it takes for RN to go from state 4 to state 5 from dnsmasq server response using wireshark - ~8 seconds

time was not the issue

saved relpy packet from dnsmasq and kea and looking into differences

| Difference                 | dnamasq   | Kea           |
|----------------------------|-----------|---------------|
| IPv6 - Traffic class, DSCP | 0xc0, CS6 | 0x00, CS0     |
| Message Type               | Reply (7) | Advertise (9) |

difference in message type due to the 4-way exchange procedure solicit, advertise, request, reply

fix - add rapid-commit: true to subnet setting to skip advertise and request steps

After enabling rapid commit kea now leases addresses and RN returns state 5

Next task - dockerize kea - look at dnsmasq Dockerfile - figure out what is needed

wrote initial version of Dockerfile using apt install kea-dhcp6-server - old 2.0.2 version of kea - ran into issue of
not supporting part of config file - next step write docker to use source instead

## 10/14/2024

found ADD command for Dockerfile - use # after git ssh link to specify branch

wrote working Dockerfile for kea dhcp server

build kea docker

```commandline
docker build --progress=plain -t alex-kea kea 
```

start up kea docker

```commandline
docker run --rm --net=host alex-kea
```

## 10/15/2024

usb power cycle on remote host

can also do `/dev/tty<number>` or `/dev/wisun-<thing>`

```commandline
usbpower.py -r 1,2
```

## 10/18/2024

second port used for other project

don't need to shut the whole thing down - to make

could set lease time to short -

## 10/19/2024

successfully built kea with working reserved address - issue was that the reservation was global and not put inside the
subnet. default reservation-state is all which ignores global reservations- fixed the issue and moved it into subnet *
*NOTE** do not forget to rebuild the Docker when changing conf file

wrote new shell script to remove kea-conf.json and remake it with updated kea-conf.yml and builds the docker with the
new kea-conf.json. The script then runs kea

next steps should be preparing for demo of ramp up tasks on the 10/23/2024 with better shell scripts. That means making
shell scripts to do each part like one to start wfantund, one to do what the current start up script is doing and lastly
stating kea / dnsmasq

## 10/20/2024

send command to other terminal. used in tmux scripts

```commandline
tmux send-keys -t '.0' <command>
```

NOCR when set to one will not have the character turn to run the scripts automatically.

```commandline
NOCR=1
```

for pushing to TI-wi-sun-project use command below to pull rebase then use git push

```commandline
git pull --rebase
```

wrote new shell scripts so it is easier for my team and myself to bring up the network - the new scripts are numbered
and to take command line options for custom paths

wrote tmux start up and shutdown shell scripts so that starting up and shutting down the network is very easy

## 10/29/2024

edited kea-conf to run external script hook

enters docker image without having to copy and paste

```commandline
docker exec -it $(docker ps -qf "ancestor=alex-kea") bash
```

## 11/3/2024

starting working on figuring out the mac address [hook github](https://github.com/serverzone/Kea-dhcp-hooks/tree/master)

I also commented out the test line in the CMake because I didn't not download gtest

one error when trying to build was that I was not able to run the compile.sh script because it could not find the
hooks/hooks.h file

the solution to this is to sym link the kea build into the third

```commandline
ln -sf <path to kea> kea
```

got hook github built after some small trouble with the CMake library paths

new issue - 2024-11-04 02:21:48.629 ERROR [kea-dhcp6.dhcp6/1662238.134517153421184] DHCP6_INIT_FAIL failed to initialize
Kea server: configuration error using file 'kea-conf.json': hooks libraries failed to validate - library or libraries in
error are: /usr/local/lib/kea/hooks/libmac2ipv6.so (kea-conf.json:85:5)

getting failed to validate new hook library - unknown cause -

tried to add print debugging to the src of the kea but it
will take a long time to debug due to long build time - running on non docker kea to maybe speed up debugging - in
theory it should be easier to debug -

tried upping logging but logs wont come out of stdout when assigned and messages are sill the same even with elevated
debugging levels - even when point to a file kea will still not create one. I believe this is due to how early the fail
is happening and I'm lost

grep for error in src and added a error throw at the start of the file to see if it even works - not even getting to
it - unknown where this error is being called

## 11/05/2024

figure out it issue with yaml file and setting up the reporting of logging - set severity to DEBUG and debug level to 99

was able to figure out that the multi threading
problem - [this website](https://reports.kea.isc.org/dev_guide/df/d46/hooksdgDevelopersGuide.html) go to the section
**The "multi_threading_compatible" function** and addd the multi_threading compatible.cc file to the src directory of
the kea-dhcp-hooks

the issue is that kea needs to know if the hook is multi threading safe or not and without the hook declaring either way
the kea will invalidate the hook library

was able to log the new address out and also changed logging to see - HOOKS_CALLOUT_EXCEPTION exception thrown by
callout on hook lease6_select registered by library with index 1 (callout address 0x715d835ea2e2): Failed to convert
string to address '2020:abcd:0000:0212:4bff:fe00:29bd7e45': Invalid argument (callout duration: 0.527 ms)

the error is that the address is malformed the fix for this is to modify the mac2ip.cc in the Kea-dhcp-hooks

fixed the error of the malformed address - on line 38 in mac2ip.cc change the 5 to 6

after trying to ping the address it didn't work I believe this is due to the address pool being to restrictive in the
yaml - up side to all of this though is that the RN is consistently getting the same address assigned to it

after reconfiguring the address pool in the yaml this was not the case

## 11/07/2024

to run gdb on kea you need to source the correct kea build to do that you need to run source on the loadpath file - that
will point the kea to use the correct kea build

```commandline
source loadpath
```

you can check where it is getting the files with ldd - this will print out the libraries and where they are getting them
from

```commandline
ldd <path to kea / executable> 
```

then you need to use nm which gets the names of the items in the object file / gets function names - used to get
function signatures to set break points in gdb

c++filt just makes the output of nm more readable

```commandline
nm <libarary path> | c++filt | grep <function name>
```

## 11/11/2024

got gdb working with kea. ran down the problem of infinite looping to be that the tmp file created for the kea database.
if the lease is not expired it will end up in an infinite loop.

found that the reason the ping is not working is that the prefix is too long for the ip route. need to change it from 64
to 32 for the ping to work

need to fix kea so that if the address is in the lease database so that they

fix wfantund so that the ip6 route has 32 bit prefix not 64 bit prefix

## 11/12/2024

TunnelIPv6Interface.cpp line 614 - add_address(&test_addr, 64)

change the 64 to 32 - didn't work unknown why - next steps run with gdb and see how its taking in the prefix length

I know the test_addr effects the name of the route in the route table. unknown why it is not working.

## 11/13/2024

after meeting Caden emailed me where the other network is hard coded with a 64 bit prefix. wfantund now starts with a 32
bit network

## 11/16/2024

memfile_lease_mgr.cc - found issue was with the check on the status returning false for the address. The fix found for
this is to assign the fake_allocation var to be true. This is done in the lease6_select.cc in the hook dir.

Implementing change said above kea with hook works with assignment of lease and pings

## 11/17/2024

dockerized the kea hook by forking the github and adding it to the Dockerfile in the external-servers/kea dir.

Also fix up Dockerfile to have as minimal layers in it as possible.

After the change above were done and checks on it were completed I can now say that the Kea Hook task are done per the
TI slides. yippee \ (•◡•) /

## 11/24/2024

did previous work forgot to write notes

installed following libs in sysroot

- libdbus-1-dev
- libsystemd-dev
- libreadline-dev
- libboost-system1.81-dev
- libboost1.81-dev
- liblog4cplus-dev

found that wfantund builds on beagleplay

## 11/25/2024

deferring cross compiling

started setting up beagleplay booting of micro sd card

booting off sd card needed to read off serial usb

## 11/27/2024

installing wfantund and building on beagleplay

install .deb file with apt

```commandline
sudo apt install <package.deb>
```

installing kea packages

- [isc-kea-dhcp6](https://cloudsmith.io/~isc/repos/kea-2-6/packages/detail/deb/isc-kea-dhcp6/2.6.1-isc20240725093407/a=arm64;xc=main;d=debian%252Fbookworm;t=binary/)
- [isc-kea-common](https://cloudsmith.io/~isc/repos/kea-2-6/packages/detail/deb/isc-kea-common/2.6.1-isc20240725093407/a=arm64;xc=main;d=debian%252Fbookworm;t=binary/)

## 11/29/2024

kea-dhcp-hooks-UTD failed compile.sh because hooks/hooks.h was not found

installing kea packages cont.

- [isc-kea-hooks](https://cloudsmith.io/~isc/repos/kea-2-6/packages/detail/deb/isc-kea-hooks/2.6.1-isc20240725093407/a=arm64;xc=main;d=debian%252Fbookworm;t=binary/)
- [isc-kea](https://cloudsmith.io/~isc/repos/kea-2-6/packages/detail/deb/isc-kea/2.6.1-isc20240725093407/a=arm64;xc=main;d=debian%252Fbookworm;t=binary/)

isc-kea has hooks/hooks.h - added /usr/include/kea to include_directories in CMakeLists.txt

rewrote 30-kea-start.sh script to handle options. Also added option for local kea start with config file.

need to disable package from starting with systemctl disable <process> rewrote 30-kea-start.sh script to handle options.
Also added option for local kea start with config file.

## 12/01/2024

following [stork quick start](https://kb.isc.org/docs/stork-quickstart-guide)

installing stork packages for bookworm on BP

- [isc-stork-agent](https://cloudsmith.io/~isc/repos/stork/packages/detail/deb/isc-stork-agent/2.0.0.241112162746/a=arm64;xc=main;d=any-distro%252Fany-version;t=binary/)
- [isc-stork-server](https://cloudsmith.io/~isc/repos/stork/packages/detail/deb/isc-stork-server/2.0.0.241112162749/a=arm64;xc=main;d=any-distro%252Fany-version;t=binary/)
- [isc-stork-hooks](https://cloudsmith.io/~isc/repos/stork/packages/detail/deb/isc-stork-server-hook-ldap/2.0.0.241112162811/a=arm64;xc=main;d=any-distro%252Fany-version;t=binary/)

installing postgresql - package name postgresql - used apt

got stork server and stork agent started but unable to see kea this is because the kea control agent is not active

installed [isc-kea-ctrl-agent](https://cloudsmith.io/~isc/repos/kea-2-6/packages/detail/deb/isc-kea-ctrl-agent/2.6.1-isc20240725093407/a=arm64;xc=main;d=debian%252Fbookworm;t=binary/(https://cloudsmith.io/~isc/repos/stork/packages/detail/deb/isc-stork-server-hook-ldap/2.0.0.241112162811/a=arm64;xc=main;d=any-distro%252Fany-version;t=binary/))

kea stork need to be run as sudo so that it is visible in stork

```commandline
sudo /usr/sbin/kea-ctrl-agent -c /etc/kea/kea-ctrl-agent.conf
```

use systemctl to bring up and down the stork

```commandline
sudo systemctl <command> <service>
```
