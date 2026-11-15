# Votivo

Votivo is a microservices-based web application for creating polls, collecting votes, and viewing results.

## Components

| Component | Description | Repository (main) |
| --- | --- | --- |
| [User Service](services/user-service) | Manages user profiles and integrates with Keycloak for authentication and authorization. | [Votivo-user-service](https://github.com/Volodymyr-Buryak/Votivo-user-service/tree/main) |
| [Poll Service](services/poll-service) | Manages polls, questions, answer options, access settings, and poll lifecycle. | [Votivo-poll-service](https://github.com/Konnzy/Votivo-poll-service/tree/main) |
| [Vote Service](services/vote-service) | Accepts and stores votes while enforcing participation rules and preventing duplicate voting. | [Votivo-vote-service](https://github.com/ReilEgor/Votivo-vote-service/tree/main) |
| [Result Service](services/result-service) | Aggregates votes and provides poll results and statistics. | [Votivo-result-service](https://github.com/koliruslik/Votivo-result-service/tree/main) |
| [Frontend](frontend) | Provides the React interface for managing polls, casting votes, and viewing results. | [Votivo-frontend](https://github.com/koliruslik/Votivo-frontend/tree/main) |

## Repository layout

This integration repository connects independently developed components through Git submodules, each pinned to a specific commit.

```text
Votivo/
├── services/
│   ├── user-service/
│   ├── poll-service/
│   ├── vote-service/
│   └── result-service/
└── frontend/
```

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
