# ExpidusOS Config

A configuration management system for ExpidusOS. This solves some issues with immutable systems such as the hostname setting.

## Planned features

- Daemon mode (w/ DBus)
- Dry-run
- Config validation
- Mount point management

## Configs

ExpidusOS's configuration is split between two files. The first one is the vendor config (`/etc/expidus/vendor.json`), the second is the system config (`/data/config/system.json`).

### System

Here is a list of available options

#### `hostname`

Type: `string` **required**

This changes the system's hostname.

#### `locale`

Type: `string` **required**

This changes the system's locale.

#### `timezone`

Type: `string` **required**

This changes the system's timezone.

### Vendor

*To-do*: this side of the config system is not implemented yet.
