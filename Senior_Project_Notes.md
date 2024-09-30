# Senior Project Notes

Personal notes - Alex Chan-Nui

## 9/28

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

## 9/29

### Flash LPs

**Please Note used windows box to flash LP boards**

using Uniflash use auto-detect feature to find board connected to my windows box

from Caden's email downloaded the new images of the boarder router and nodes for the LPs

2VL flashed with boarder router image

L45002UP (2UP) flashed with nodes image

### TI Wi-SUN FAN Fundamentals Guide 

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
cd ~/ti/simplelink_cc13xx_cc26xx_sdk_7_41_00_17/tools/ti_wisunfan
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

when connecting router node (RN) it will take a few minutes for it to return connected 

**Please Note** - wisunstack will show stop even after a start command it given. Will show start after connected

**Please Note** - when RN connects to border router (BR) the RN will not display IP address