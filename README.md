# Mac_HA_HB

## Setup

```
docker-compose up -d
```

## Edit configuration.yml in local 'config' Folder

Add:

```
homekit:
  - name: HASS Bridge
    port: 51827
    advertise_ip: "xxx.xxx.xxx.xxx"
```

Then Reboot

## Run In Background in MacOS

```
sudo ./dns-sd.sh
```
