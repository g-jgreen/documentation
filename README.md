# Waylay documentation portal

## Dependencies

`brew update && brew install hugo`

## Development

run `hugo server` and visit `http://localhost:1313/`

## Deployment

Drone will automatically create a new docker image `eu.gcr.io/quiet-mechanic-140114/documentation:latest`

To manually create a release:

`make && make publish`
