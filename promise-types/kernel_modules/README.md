# kernel_modules promise type

## Synopsis

* *Name*: `kernel_modules`
* *Version*: `1.0.0`
* *Description*:  Load/Unload kernel module

## Requirements

* modprobe (command line tool)

## Attributes

| Name            | Type      | Description                                                                                                             | Mandatory | Default  |
| --------------- | --------- | ----------------------------------------------------------------------------------------------------------------------- | --------- | -------- |
| `name`          | `string`  | kernel module name                                                                                                      | Yes       | Promiser |
| `policy`        | `string`  | Must the kernel module be: present or absent                                                                            | Yes       | -        |

## Examples

Make sure that the kernel module is loaded
```cfengine3
bundle agent main
{
    kernel_modules:
        "nvidia_uvm"
            policy => "present";
}
```

## Authors

This software was created by the team at [SURF HPCV](https://www.surf.nl/en/)

## Contribute

Feel free to open pull requests to expand this documentation, add features or fix problems.
You can also pick up an existing task or file an issue in [our bug tracker](https://github.com/basvandervlies/scl_modules/issues).

## License

This software is licensed under the GNU General Public License v2.0. See LICENSE in the root of the repository for the full license text.
