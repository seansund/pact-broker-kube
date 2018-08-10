FROM postgres

COPY scripts/init.sql /docker-entrypoint-initdb.d/

ENV POSTGRES_PASSWORD=ThePostgresPassword
ENV POSTGRES_USER=admin
ENV PGDATA=/var/lib/postgresql/data/pgdata
