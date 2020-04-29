# Folding@Home
Simple to set up image equipped with the Folding@Home client.

## Running the server
```bash
docker run --detach --name folding-at-home --publish 7396:7396 --publish 36330:36330 hetsh/folding-at-home
```

## Stopping the container
```bash
docker stop folding-at-home
```

## Configuring
The Folding@Home client can be configured via its [web interface](http://localhost:7396).
This requires some additional cli parameters at startup:
```bash
docker run ... hetsh/folding-at-home --web-allow=0/0:7396 --allow=0/0:7396
```

## Creating persistent storage
```bash
STORAGE="/path/to/storage"
mkdir -p "$STORAGE"
chown -R 1362:1362 "$STORAGE"
```
`1362` is the numerical id of the user running the server (see Dockerfile).
The user must have RW access to the storage directory.
Start the server with the additional mount flags:
```bash
docker run --mount type=bind,source=/path/to/storage,target=/folding-at-home ...
```

## Time
Synchronizing the timezones will display the correct time in the logs.
The timezone can be shared with this mount flag:
```bash
docker run --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly ...
```

## Automate startup and shutdown via systemd
```bash
systemctl enable folding-at-home --now
```
The systemd unit can be found in my [GitHub repository](https://github.com/Hetsh/docker-folding-at-home).
By default, the systemd service assumes `/etc/folding-at-home` for storage and `/etc/localtime` for timezone.
Also, ports for the web interface and the controller are not exposed.
You need to adjust these to suit your setup.

## Fork Me!
This is an open project hosted on [GitHub](https://github.com/Hetsh/docker-folding-at-home). Please feel free to ask questions, file an issue or contribute to it.