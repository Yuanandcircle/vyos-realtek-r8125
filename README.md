# vyos-realtek-r8125
RTL8125B driver for VyOS
## Build DEB Package
Here is a guide to build `vyos-realtek-r8125` package for VyOS 1.3.x.
>VyOS 1.4.x is shippped with kernel 5.10.x, in which rtl8125 is natively supported.
### Prerequisites
On a linux machine with docker:
```
docker pull vyos/vyos-build:equuleus
git clone -b equuleus --single-branch https://github.com/vyos/vyos-build
cd vyos-build
docker run --rm -it --privileged -v $(pwd):/vyos -w /vyos vyos/vyos-build:equuleus bash
```
### Build Kernel
Kernel must be built first. Check out the required kernel version - see `vyos-build/data/defaults.json` file (example uses kernel 5.4.188)
```
cd packages/linux-kernel/
git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
cd linux
git checkout v5.4.188
cd /vyos/packages/linux-kernel
./build-kernel.sh
```
### Build r8125 Module
After building the kernel, we can build out-of-tree module so everything is lined up and the ABIs match.
```
git clone https://github.com/Yuanandcircle/vyos-realtek-r8125.git
chmod +x vyos-realtek-r8125/build-realtek-r8125.sh
./vyos-realtek-r8125/build-realtek-r8125.sh
```
The deb package `vyos-realtek-r8125_9.008.00-1_amd64.deb` can be found in current directory.
## Integration with VyOS
Follow instructions on [Build VyOS](https://docs.vyos.io/en/equuleus/contributing/build-vyos.html). Simply place the built deb package inside the `packages` folder within `vyos-build`. The build process will then pickup the package and integrate it into ISO.
