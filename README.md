# Mikrotik Backup

`backup.sh` is a simple script that reads a list of hostnames from stdin, logs
in via ssh, and does `/export` on each of them. The output of each is saved to
a file. These files are then committed to a git repository. This provides an
incremental backup that can be run periodically with a tool like cron.

## Usage

```
./hamwan_routers.sh | ./backup.sh
```
