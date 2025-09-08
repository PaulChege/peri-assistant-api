# README

API to support Peri Assistant, an application for managing lessons for music teachers. 


## Docker (Development)

1. Create a `.env` file (optional) to override defaults:
```
# Rails
RAILS_ENV=development
RACK_ENV=development
PORT=3000

# Database (compose defaults)
DB_HOST=db
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=peri_dev
DATABASE_URL=postgres://postgres:postgres@db:5432/peri_dev

# Redis
REDIS_URL=redis://redis:6379/0
```

2. Build and start services:
```
docker compose up --build
```

3. Run one-off commands (e.g., migrations, console):
```
docker compose run --rm app bash -lc "bundle exec rails db:migrate"
docker compose run --rm app bash -lc "bundle exec rails c"
```

4. App will be available at:
```
http://localhost:3000
```

Notes:
- The `app` service mounts the project directory for live code reloading.
- Postgres data persists in the `db-data` volume; gems are cached under `bundle-cache`.
- Adjust `DATABASE_URL`/`DB_*` env vars as needed. 

