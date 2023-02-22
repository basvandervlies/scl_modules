# docker_network promise type

## Synopsis

* *Name*: `docker_network`
* *Version*: `1.0.0`
* *Description*:  Create/Delete docker network(s)

## Requirements

* docker network (command line tool)

## Attributes

| Name            | Type      | Description                                                                                                             | Mandatory | Default  |
| --------------- | --------- | ----------------------------------------------------------------------------------------------------------------------- | --------- | -------- |
| `name`          | `string`  | network name                                                                                                            | Yes       | Promiser |
| `state`         | `string`  | state of the network: present or absent                                                                                 | Yes       | -        |

## Examples

Make sure that the docker images are specified in the yaml file are running
```cfengine3
bundle agent main
{
    docker_network:
        "public"
            state => "present";
}
```

## Authors

This software was created by the team at [SURF HPCV](https://www.surf.nl/en/)

## Contribute

Feel free to open pull requests to expand this documentation, add features or fix problems.
You can also pick up an existing task or file an issue in [our bug tracker](https://github.com/basvandervlies/scl_modules/issues).

## License

This software is licensed under the GNU General Public License v2.0. See LICENSE in the root of the repository for the full license text.
