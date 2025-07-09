# Manual Setup (Preferred)

This guide provides step-by-step instructions for setting up SurfSense without Docker. This approach gives you more control over the installation process and allows for customization of the environment.

## Requirements

Before beginning installation, ensure you have the following installed:

- [Node ^22](https://nodejs.org/en)
- [Postgres](https://www.postgresql.org/)

## Prerequisites

Before beginning the manual installation, ensure you have completed all the prerequisite setup steps, including:

- Choose a File Processing ETL Service:
  - [Unstructured.io](https://unstructured.io/) API key (Supports 34+ formats)
  - [LlamaIndex](https://www.llamaindex.ai/) API key (enhanced parsing, supports 50+ formats)
- Other API Keys @TODO: Which keys?

## Installation

- Run `make` to setup the project
  - This command will:
    - Add `pgvector`
    - Setup the database user
    - Setup the database
    - Run database migrations
    - Install all dependencies
    - Copy `.env.example` files to `.env` files

## Running SurfSense

1. Edit the `surfsense_backend/.env` file and set the following variables:

#### General

| Variable Name       | Description                                                     | Example                                                         |
| ------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- |
| `DATABASE_URL`      | PostgreSQL connection string                                    | postgresql+asyncpg://postgres:postgres@localhost:5432/surfsense |
| `SECRET_KEY`        | JWT secret key for authentication (should be secure and random) | _(generate securely)_                                           |
| `NEXT_FRONTEND_URL` | URL where your frontend application is hosted                   | http://localhost:3000                                           |

#### Authorization

| Variable Name                | Description                                                                       | Example                  |
| ---------------------------- | --------------------------------------------------------------------------------- | ------------------------ |
| `AUTH_TYPE`                  | Authentication method                                                             | GOOGLE or LOCAL          |
| `GOOGLE_OAUTH_CLIENT_ID`     | (Optional) Client ID from Google Cloud Console (required if AUTH_TYPE=GOOGLE)     | _(Google client ID)_     |
| `GOOGLE_OAUTH_CLIENT_SECRET` | (Optional) Client secret from Google Cloud Console (required if AUTH_TYPE=GOOGLE) | _(Google client secret)_ |

#### Embeddings

| Variable Name          | Description                 | Example                            |
| ---------------------- | --------------------------- | ---------------------------------- |
| `EMBEDDING_MODEL`      | Name of the embedding model | mixedbread-ai/mxbai-embed-large-v1 |
| `RERANKERS_MODEL_NAME` | Name of the reranker model  | ms-marco-MiniLM-L-12-v2            |
| `RERANKERS_MODEL_TYPE` | Type of reranker model      | flashrank                          |

#### Text-to-Speech (TTS)/Speech-to-Text (STT)

| Variable Name          | Description                                                   | Example            |
| ---------------------- | ------------------------------------------------------------- | ------------------ |
| `TTS_SERVICE`          | Text-to-Speech API provider for Podcasts                      | `openai/tts-1`     |
| `TTS_SERVICE_API_KEY`  | API key for the Text-to-Speech service                        | _(your API key)_   |
| `TTS_SERVICE_API_BASE` | (Optional) Custom API base URL for the Text-to-Speech service | _(optional URL)_   |
| `STT_SERVICE`          | Speech-to-Text API provider for Podcasts                      | `openai/whisper-1` |
| `STT_SERVICE_API_KEY`  | API key for the Speech-to-Text service                        | _(your API key)_   |
| `STT_SERVICE_API_BASE` | (Optional) Custom API base URL for the Speech-to-Text service | _(optional URL)_   |

#### Web Crawling

| Variable Name       | Description                                    | Example          |
| ------------------- | ---------------------------------------------- | ---------------- |
| `FIRECRAWL_API_KEY` | API key for Firecrawl service for web crawling | _(your API key)_ |

#### File Processing ETL

| Variable Name          | Description                                                                | Example                    |
| ---------------------- | -------------------------------------------------------------------------- | -------------------------- |
| `ETL_SERVICE`          | Document parsing service                                                   | UNSTRUCTURED or LLAMACLOUD |
| `UNSTRUCTURED_API_KEY` | API key for Unstructured.io service (required if ETL_SERVICE=UNSTRUCTURED) | _(your API key)_           |
| `LLAMA_CLOUD_API_KEY`  | API key for LlamaCloud service (required if ETL_SERVICE=LLAMACLOUD)        | _(your API key)_           |

#### (Optional) Backend LangSmith Observability

| Variable Name        | Description              | Example                           |
| -------------------- | ------------------------ | --------------------------------- |
| `LANGSMITH_TRACING`  | Enable LangSmith tracing | `true` or `false`                 |
| `LANGSMITH_ENDPOINT` | LangSmith API endpoint   | `https://api.smith.langchain.com` |
| `LANGSMITH_API_KEY`  | Your LangSmith API key   | _(your API key)_                  |
| `LANGSMITH_PROJECT`  | LangSmith project name   | `surfsense`                       |

#### (Optional) Uvicorn Server Configuration

| Variable Name                  | Description                                      | Default Value |
| ------------------------------ | ------------------------------------------------ | ------------- |
| `UVICORN_HOST`                 | Host address to bind the server                  | `0.0.0.0`     |
| `UVICORN_PORT`                 | Port to run the backend API                      | `8000`        |
| `UVICORN_LOG_LEVEL`            | Logging level (`info`, `debug`, `warning`, etc.) | `info`        |
| `UVICORN_PROXY_HEADERS`        | Enable/disable proxy headers                     | `false`       |
| `UVICORN_FORWARDED_ALLOW_IPS`  | Comma-separated list of allowed IPs              | `127.0.0.1`   |
| `UVICORN_WORKERS`              | Number of worker processes                       | `1`           |
| `UVICORN_ACCESS_LOG`           | Enable/disable access log (`true`/`false`)       | `true`        |
| `UVICORN_LOOP`                 | Event loop implementation                        | `auto`        |
| `UVICORN_HTTP`                 | HTTP protocol implementation                     | `auto`        |
| `UVICORN_WS`                   | WebSocket protocol implementation                | `auto`        |
| `UVICORN_LIFESPAN`             | Lifespan implementation                          | `auto`        |
| `UVICORN_LOG_CONFIG`           | Path to logging config file or empty string      | _(empty)_     |
| `UVICORN_SERVER_HEADER`        | Enable/disable Server header                     | `true`        |
| `UVICORN_DATE_HEADER`          | Enable/disable Date header                       | `true`        |
| `UVICORN_LIMIT_CONCURRENCY`    | Max concurrent connections                       | _(unset)_     |
| `UVICORN_LIMIT_MAX_REQUESTS`   | Max requests before worker restart               | _(unset)_     |
| `UVICORN_TIMEOUT_KEEP_ALIVE`   | Keep-alive timeout (seconds)                     | `5`           |
| `UVICORN_TIMEOUT_NOTIFY`       | Worker shutdown notification timeout (seconds)   | `30`          |
| `UVICORN_SSL_KEYFILE`          | Path to SSL key file                             | _(unset)_     |
| `UVICORN_SSL_CERTFILE`         | Path to SSL certificate file                     | _(unset)_     |
| `UVICORN_SSL_KEYFILE_PASSWORD` | Password for SSL key file                        | _(unset)_     |
| `UVICORN_SSL_VERSION`          | SSL version                                      | _(unset)_     |
| `UVICORN_SSL_CERT_REQS`        | SSL certificate requirements                     | _(unset)_     |
| `UVICORN_SSL_CA_CERTS`         | Path to CA certificates file                     | _(unset)_     |
| `UVICORN_SSL_CIPHERS`          | SSL ciphers                                      | _(unset)_     |
| `UVICORN_HEADERS`              | Comma-separated list of headers                  | _(unset)_     |
| `UVICORN_USE_COLORS`           | Enable/disable colored logs                      | `true`        |
| `UVICORN_UDS`                  | Unix domain socket path                          | _(unset)_     |
| `UVICORN_FD`                   | File descriptor to bind to                       | _(unset)_     |
| `UVICORN_ROOT_PATH`            | Root path for the application                    | _(unset)_     |

Refer to the .env.example file for all available Uvicorn options and their usage. Uncomment and set in your .env file as needed.

For more details, see the Uvicorn documentation.

2. Edit the `surfsense_web/.env` file and set the following variables:

| Variable Name                           | Description                                                                                                                                  | Example                        |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| `NEXT_PUBLIC_FASTAPI_BACKEND_URL`       | Backend URL                                                                                                                                  | `http://localhost:8000`        |
| `NEXT_PUBLIC_FASTAPI_BACKEND_AUTH_TYPE` | Same value as set in backend AUTH_TYPE i.e GOOGLE for OAuth with Google, LOCAL for email/password authentication                             | `LOCAL` or `GOOGLE`            |
| `NEXT_PUBLIC_ETL_SERVICE`               | Document parsing service (should match backend ETL_SERVICE): UNSTRUCTURED or LLAMACLOUD - affects supported file formats in upload interface | `UNSTRUCTURED` or `LLAMACLOUD` |

3. Run `make dev` to start the app in dev mode

## (Optional) Browser Extension Setup

The SurfSense browser extension allows you to save any webpage, including those protected behind authentication.

### Installation

- Run `make setup-browser-extension` to setup the browser extension
- Edit the `surfsense_browser_extension/.env` file and set the following variables:

| Variable Name             | Description           | Default Value         |
| ------------------------- | --------------------- | --------------------- |
| PLASMO_PUBLIC_BACKEND_URL | SurfSense Backend URL | http://127.0.0.1:8000 |

### Build (for Chrome)

- Run `make build-browser-extension` to build it

#### Build for Other Browsers

- **Firefox**: Run `make build-browser-extension target=firefox`
- **edge**: Run `make build-browser-extension target=edge`

### Loading the Extension

Load the extension in your browser's developer mode and configure it with your SurfSense API key.

## Verification

To verify your installation:

- Open your browser and navigate to http://localhost:3000
- Sign in with your Google account
- Create a search space and try uploading a document
- Test the chat functionality with your uploaded content

## Troubleshooting

- Database Connection Issues: Verify your PostgreSQL server is running and pgvector is properly installed
- Authentication Problems: Check your Google OAuth configuration and ensure redirect URIs are set correctly
- LLM Errors: Confirm your LLM API keys are valid and the selected models are accessible
- File Upload Failures: Validate your Unstructured.io API key
- Windows-specific: If you encounter path issues, ensure you're using the correct path separator (\ instead of /)
- macOS-specific: If you encounter permission issues, you may need to use sudo for some installation commands

## Next Steps

Now that you have SurfSense running locally, you can explore its features:

- Create search spaces for organizing your content
- Upload documents or use the browser extension to save webpages
- Ask questions about your saved content
- Explore the advanced RAG capabilities
- For production deployments, consider setting up:
  - A reverse proxy like Nginx
  - SSL certificates for secure connections
  - Proper database backups
  - User access controls
