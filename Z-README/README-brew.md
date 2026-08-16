# Brew Maintence

## Change Log

**08-Jun-2026**
- Created/installed

**14-Aug-2026** 
- Started list for new install of needed brew packages
  
**15-Aug-2026**
- Updated README.brew.md

## Brew maintence and housekeeping
Steps:

```zsh
% brew update
% brew outdated --greedy    # Gets the list of outdated packages
% brew upgrade --greedy     # Does the updates
% brew cleanup              # House keeping removing cruft

% # Make sure the config files for brew migrations are updated
% cd {path to /brew_options on NAS or USB-stick}
% ./brew_export --execute

```

## Brew installs on new system

Defines a **'brew_options'** that has export, import, and remove concepts. The idea is to create a installer process ```brew kit``` of brew on an existing machine, then migrate/share on a new/refreshed machine.

### Terms
- **Host** the machine that has the current/baseline *brew* install, casts, leaves, and taps
- **Target** the machine that will get/install brew, casts, leaves, and taps from the **Host** machine as part of the porting/migration of *brew* to a new machine
- **/brew_options** is the folder on a NAS or USB-stick that has ```zsh-shell``` files used to import/export/remove *brew* from the **Host** to the **Target**

The concept is -
- brew_export => Export from the 'master' machine a series of files (casts, leaves, and taps) of the current brew configuration
- brew_import => Imports the config files from brew_export and installs the casts, leaves, and taps from the 'host' machine
- brew_remove => ***DANGER*** this does an uninstall of Brew, casts, leaves, and taps and is intended for testing (on the target machine)

### Testing loop

- % ./brew_import --dry-run          # iterate on logic, minutes each
- % ./brew_remove --dry-run          # read the plan
- % ./brew_remove                    # weekend operation
- % exec zsh
- % ./brew_import
- % flutter doctor -v

This is for the **Target** machine to check if the installing of *brew* and its casts, leaves, and taps.

This requires that ```./brew_export``` has been run so the needed files for import are in place in the **brew_options:**

- brew_casks.txt
- brew_leaves.txt
- brew_taps.txt
- manifest.txt

## Production install steps

From **Target** machine

```zsh
% cd {path to /brew_options on NAS or USB-stick}
% ./brew_export --execute
```
Creates the files needed for the **Target** machine.

From the **TARGET** machine

```zsh
% cd {path to /brew_options on NAS or USB-stick}}
% ./brew_import --dry-run    # Review what will happen
% ./brew_import --execute    # Installs brew, casts, leaves, and taps
```

***Everything*** ```brew``` should be installed and ready.

#### Notes:

There should be a ```readme.txt``` file in the ```/brew_optons``` folder with similiar instructions

The commands ```./brew_export``` and ```./brew_import``` *must* be run from the ```/brew_options``` folder, and that folder must be write-able because of the manifest files are written and read from there.

#### Files and Folders:

```/lib```: folder with helper methods the zsh-files

```brew_caskets.txt```: Configuration file for brew caskets

```brew_leaves.txt```: Configuration file for brew leaves

```brew_taps.txt```: Configuration file for brew taps

```manifest.txt```: Manifest file of that needed files for import

```read_me.txt```: Similar to this file README.md

```brew_export```: Gets the current (**HOST**) brew information and creates the configuration files used for new (**TARGET**) importing

```brew_import```: Takes the manifest files and installs brew, all the casts, leaves, and taps on the new (**TARGET**) machine

```brew_remove``` **DANGER**: this removes brew from a machine. Its primary use is to test/develop this kit, but can be used for ***fresh*** install of brew.
