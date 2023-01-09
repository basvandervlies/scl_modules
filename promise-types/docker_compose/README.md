# scl_docker_compose promise type

## Synopsis

* *Name*: `scl_docker_compose`
* *Version*: `1.0.0`
* *Description*:  Handle the state of the containers defined in the yaml file

## Requirements

* jq (json command line tool)
* docker compose (command line tool)

## Attributes

| Name            | Type      | Description                                                                                                             | Mandatory | Default  |
| --------------- | --------- | ----------------------------------------------------------------------------------------------------------------------- | --------- | -------- |
| `file`          | `string`  | Docker compose yaml file                                                                                                | Yes       | Promiser |
| `state`         | `string`  | State of the docker images: start, stop, restart, kill, up                                                              | Yes       | -        |
| `envfile`       | `string`  | Specify which env-file needs to be included                                                                             | Yes       | -        |

## Examples

Make sure that the docker images are specified in the yaml file are running
```cfengine3
bundle agent main
{
    scl_docker_compose:
        "/srv/traefik/docker_compose.yaml"
            state => "start";
}
```

THis is how we handle a restart if the docker compose file has been changed
```cfengine3
bundle agent main
{
    scl_docker_compose:                                                                                                                                                                                             
        "/srv/traefik/docker_compose.yaml"
            state => "restart",                                                                                                                                                                                 
            if => not(canonify("$(this.promiser)_restarted"));  
}
```

## Authors

This software was created by the team at [SURF HPCV](https://www.surf.nl/en/)

## Contribute

Feel free to open pull requests to expand this documentation, add features or fix problems.
You can also pick up an existing task or file an issue in [our bug tracker](https://github.com/basvandervlies/scl_modules/issues).

## License

This software is licensed under the GNU General Public License v2.0. See LICENSE in the root of the repository for the full license text.
