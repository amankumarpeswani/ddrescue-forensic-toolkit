# Forensic Acquisition Toolkit for Failing Drives

A Bash tool that automates forensic imaging of damaged drives using GNU ddrescue,
and produces an acquisition report.

## What it does
1. Sets the source device read-only (protects the evidence)
2. Pass 1: `ddrescue -n` copies the easily readable data first
3. Pass 2: `ddrescue -d -r3` retries the bad areas with direct disc access
4. Tracks progress in a mapfile, so interrupted runs can resume
5. Records rescue statistics with `ddrescuelog`
6. Computes a SHA-256 hash of the image
7. Verifies the filesystem with Sleuth Kit (`fsstat`)
8. Writes a report with case ID, examiner, timestamps and results

## Requirements
Ubuntu/Kali Linux: `sudo apt install gddrescue sleuthkit`

## Testing without a failing drive
`setup_baddisk.sh` uses `losetup` and `dmsetup` (the `error` target) to create
a fake drive with two unreadable regions.

```bash
./setup_baddisk.sh
sudo ./rescue.sh /dev/mapper/baddisk CASE001 "Your Name"
```

## Sample output
See `sample_report.txt` and `sample_case.map`.

## Limitations
- Built for logical errors and mild media damage. Drives with physical failure
  (clicking, not spinning) need a clean-room lab.
- A hardware write blocker should be used on real evidence.
- Tested on simulated bad sectors, not on real failing hardware.
- A hash of the source cannot match the image when sectors are unreadable,
  so the unreadable ranges are documented.
