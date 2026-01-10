# ApartmentLab [WIP]
This is my passion project, ApartmentLab. Repo is public for future employers to see my capabilities

The purpose of this project is to selfhost various services like below:
- Jira (planka)
- AIOstreams
- Jackett
- Prowlarr
- Python Scripts

Apartmentlab Folder Structure \
apartmentlab \
├── infra-down.sh \
├── infra-up.sh \
├── preprod-down.sh \
├── preprod-up.sh \
├── prod-down.sh \
├── prod-up.sh \
├── README.md \
├── scripts \
└── stacks \
    ├── preprod \
    │   ├── aiostreams \
    │   │   └── compose.yml \
    │   └── versions.env \
    └── prod \
        ├── aiostreams \
        │   └── compose.yml \
        ├── cloudflared \
        │   └── compose.yml \
        ├── portainer \
        │   └── compose.yml \
        └── versions.env \

Example preprod -> prod deployment
- https://github.com/iryandydanish/apartmentlab/pull/57

Example preprod -> prod failed deployment -> revert branch -> deploy rollback (CI/CD)
- https://github.com/iryandydanish/apartmentlab/pull/55
- https://github.com/iryandydanish/apartmentlab/pull/56
