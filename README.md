# Lab 2 - Simple Antivirus Daemon

CC373 Operating Systems - Alexandria University

## Overview

- `antivirusd.sh` - checks a folder every few seconds. When the folder changes it
  scans the files, and every malicious file is printed, copied to the quarantine
  folder and deleted.
- `restore.sh` - lists the quarantined files so you can restore, delete or leave
  each one.
- `antivirus-cron.sh` - does one check like the daemon, run by cron (bonus 1).
- `Makefile` - runs the two scripts and creates the quarantine folder.

### Folder hierarchy

```
lab2-antivirus/
├── antivirusd.sh
├── restore.sh
├── antivirus-cron.sh
├── Makefile
├── README.md
├── files/                 # folder being monitored
├── malicious/             # quarantine folder (made by make)
├── directory-info.last    # made when running
├── directory-info.new     # made when running
└── whitelist.txt          # made by restore.sh (bonus 2)
```

## Prerequisites

Ubuntu with bash (already installed) and make:

```bash
sudo apt update
sudo apt install make
```

## Running the antivirus

1. Go to the project folder and create the folder to monitor:

   ```bash
   cd lab2-antivirus
   mkdir files
   ```

2. Add some files to test with:

   ```bash
   echo "hello" > files/notes.txt
   echo "test" > files/demo.exe
   echo "this has MALWARE in it" > files/report.txt
   ```

3. Run:

   ```bash
   make
   ```

   This creates `malicious/` and runs `./antivirusd.sh files malicious 5`.
   To change the interval: `make INTERVAL=2`.

4. You'll see:

   ```
   demo.exe is malicious and it is DELETED
   report.txt is malicious and it is DELETED
   ```

5. Press Ctrl+C to stop.

## Running the restore tool

1. Stop the antivirus first.
2. Run:

   ```bash
   make restore
   ```

3. It shows the quarantined files as a numbered list:

   ```
   Choose a file:
   1: demo.exe
   2: report.txt
   > 1
   For demo.exe:
   1: Restore this file back into dir (it was a false positive)
   2: Permanently delete this file from malicious_dir (it was genuinely malicious)
   3: Go back
   > 1
   Restored demo.exe to files.
   ```

4. It stops when there are no files left (`No malicious files to review.`), or
   press Ctrl+C.

## Where the flagged lists are

At the top of `antivirusd.sh` (and the same in `antivirus-cron.sh`):

```bash
EXTENSIONS=(".exe" ".bat" ".vbs" ".scr" ".ps1")
KEYWORDS=("virus" "trojan" "malware" "worm" "ransomware")
```

## Bonus 1 - Cron job

### Prerequisites

- Install and start cron:

  ```bash
  sudo apt install cron
  sudo service cron start
  ```

- Make the script executable: `chmod +x antivirus-cron.sh`
- The `files/` and `malicious/` folders must exist.
- You need the full path of the project folder (run `pwd` inside it).

### Steps

1. Open the crontab:

   ```bash
   crontab -e
   ```

2. Add this line (change `/home/USER/lab2-antivirus` to your path):

   ```
   * * * * * sleep 23 && cd /home/USER/lab2-antivirus && ./antivirus-cron.sh files malicious
   ```

   Cron can't use seconds, so it runs every minute and `sleep 23` makes it start
   at second 23.

3. Save and close, then check it with:

   ```bash
   crontab -l
   ```

4. Put a file like `files/test.exe` and after a minute it will be moved to
   `malicious/`.

### Every 3rd Friday of the month at 12:31 am

```
31 0 15-21 * * [ "$(date +\%u)" = 5 ] && cd /home/USER/lab2-antivirus && ./antivirus-cron.sh files malicious
```

The 3rd Friday is always between day 15 and 21, so it runs on days 15-21 at
00:31 and only continues if the day is Friday (`date +%u` gives 5 for Friday).
`31 0 15-21 * 5` would not work because cron runs when either the day of month
**or** the day of week matches.

## Bonus 2 - Whitelist

**How a file is added:** when you choose `1` (restore) in `restore.sh`, the file
is copied back to `files/` and its name is added as a new line in
`whitelist.txt`.

**How the daemon checks it:** in `scan()`, before checking the extension and
keywords, it checks if the file name is in `whitelist.txt`
(`grep -qxF "$name" whitelist.txt`). If it is, the file is skipped.

`whitelist.txt` is a normal file so it stays after stopping and starting the
daemon again.
