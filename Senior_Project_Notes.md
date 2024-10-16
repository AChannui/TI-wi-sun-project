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

### TI Wi-SUN FAN Fundamentals Guide (spinal)

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