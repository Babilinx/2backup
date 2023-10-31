# 2backup (btrfs backup), a simple snapshots management and backup tool for btrfs

## Note

⚠️ The project is actually in active developpement, so things can change dramatically! If you test it now, I'm not responsible of anything that can go wrong on your computer!

## Goal

The goal is to provide a simple - yet powerfull - snapshots management tool. It can create them periodically or manually, with description and metadata. Delete them automatically when they expire. Backup them to an external drive for backing-up data, because **snapshots are not backups**.

## Installation

Clone the repository and get inside it
```
git clone https://github.com/Babilinx/2backup && cd 2backup
```

Install it with `make`
```
sudo make install
```

## Usage

> Note: you can use `2backup` command as well as `bb` for faster use.

**All commands needs root rights** (except some but it's better with root anyways)

### Initialisation

For every subvolume that you want to backup, you will need to have a `.snapshots` subvolume at is root (mounted or nested).
When that's done, you can continue with the profiles section.

### Profiles

Profiles are specific for one (or more) subvolume(s). They contains rules about auto-snapshoting and auto-deletion.

#### Exemple

"system" profile:
```sh
#/etc/2backup/profiles/system

# Affects only @, @var, @root and @boot subvolumes
SUBV=("@" "@var" "@boot" "@root")
# Mount points of each subvolume
SUBV_MNTPT=("/" "/var" "/boot" "/root")

TIMELINE_LIMIT_HOURLY="5"   # Keep 5 hourly snapshots
TIMELINE_LIMIT_DAILY="7"    # Keep 7 daily snapshots
TIMELINE_LIMIT_WEEKLY="0"   # Do not make/keep weekly snapshots
TIMELINE_LIMIT_MONTHLY="0"  # Do not make/keep mounthly snapshots
TIMELINE_LIMIT_YEARLY="0"   # Do not make/keep yearly snapshots
```

#### Profile creation

Create it
```
2backup profile create <profile>
```

And edit the settings
```
sudoedit /etc/2backup/profiles/<profile>
```

> Note: `sudoedit` is a tool to edit files as root without doing `sudo <editor> <file>`. You can use any editor as root instead.

#### Profile deletion

Just delete it
```
2backup profile delete <profile>
```

And say "y" (or "n" if you want to keep it)

#### Profile list

List them
```
2backup profile list
```

#### Get infos on one specific profile

Get the infos
```
2backup profile show <profile>
```

### Snapshots

#### Creating a manual snapshot

> Note: They are never deleted automaticaly

##### Short description

Create it
```
2backup snapshot create <profile> -m <description>
```

##### Long description

Create it
```
2backup snapshot create <profile>
```

And enter the description with your file editor

#### Deleting a snapshot

> Note: It can contain more than one snapshot!

List snapshots
```
2backup snapshot list -p <profile>
```

And delete it
```
2backup snapshot delete <snapshot ID> -p <profile>
```

#### Deleting a single snapshot

Get his hash
```
2backup snapshot list
```

And delete it
```
2backup snapshot delete <snapshot hash>
```

#### List all snapshots

List them
```
2backup snapshot list
```

#### List all snapshots of a specific profile

List them
```
2backup snapshot list -p <profile>
```

#### Access the content of a snapshot

Mount it
```
2backup snapshot mount <snapshot hash>
```

Access it

Unmount it
```
2backup snapshot umount <snapshot ID | snapshot hash>
```

### Rollback

#### Rollback an entire profile to a previous snapshot

```
2backup rollback <snapshot ID> -p <profile>
```

#### Rollback only one snapshot

```
2backup rollback <snapshot hash>
```

## Updating

Go inside 2backup repository, and execute
```
make update
```

Re-install it if there is any updates
```
sudo make install
```

## Removing

Go inside 2backup repository, and execute
```
sudo make uninstall
```

Get out the repo and delete it
```
cd .. && rm -rf 2backup/
```
