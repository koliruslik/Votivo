# Votivo

Votivo is a microservices-based web application for creating polls, collecting votes, and viewing results.

## Components

| Component | Description | Repository (main) |
| --- | --- | --- |
| [User Service](backend/services/user-service) | Manages user profiles and integrates with Keycloak for authentication and authorization. | [Votivo-user-service](https://github.com/Volodymyr-Buryak/Votivo-user-service/tree/main) |
| [Poll Service](backend/services/poll-service) | Manages polls, questions, answer options, access settings, and poll lifecycle. | [Votivo-poll-service](https://github.com/Konnzy/Votivo-poll-service/tree/main) |
| [Vote Service](backend/services/vote-service) | Accepts and stores votes while enforcing participation rules and preventing duplicate voting. | [Votivo-vote-service](https://github.com/ReilEgor/Votivo-vote-service/tree/main) |
| [Result Service](backend/services/result-service) | Aggregates votes and provides poll results and statistics. | [Votivo-result-service](https://github.com/koliruslik/Votivo-result-service/tree/main) |
| [Frontend](frontend) | Provides the React interface for managing polls, casting votes, and viewing results. | [Votivo-frontend](https://github.com/koliruslik/Votivo-frontend/tree/main) |

## Repository layout

This integration repository connects independently developed components through Git submodules, each pinned to a specific commit.

```text
Votivo/
├── backend/
│   └── services/
│       ├── user-service/
│       ├── poll-service/
│       ├── vote-service/
│       └── result-service/
└── frontend/
```

Backend services are grouped under `backend/services/`, while the frontend remains a separate submodule at `frontend/` for independent Docker build contexts.

## Clone and update

Clone the project with its connected components:

```bash
git clone --recurse-submodules https://github.com/koliruslik/Votivo.git
cd Votivo
```

Update an existing checkout to the component versions recorded in this repository:

```bash
git pull
git submodule update --init --recursive
```

## Development workflow

Develop each component in its own repository and merge changes through a pull request. Then open a pull request in this repository to update the corresponding submodule reference to a published commit. Component updates are not pulled into this repository automatically.

When working inside a submodule, switch to a development branch before editing files; submodule updates may check out a detached HEAD.

## Run the backend locally

```bash
git submodule update --init --recursive
cd backend
cp .env.example .env   # optional: override ports and credentials
docker compose up -d --build --wait
```

[backend/docker-compose.yml](backend/docker-compose.yml) starts PostgreSQL (one database and user per service, created by [backend/postgres/init-databases.sh](backend/postgres/init-databases.sh)), RabbitMQ, User Service and Vote Service with its migrations. Poll Service and Result Service will be added when they get a Dockerfile. Stop everything and drop the data with `docker compose down -v`.
