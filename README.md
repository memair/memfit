# README

## DB setup

### Dev

```
CREATE DATABASE memfit_development;
CREATE USER memfit_development WITH PASSWORD 'password';
ALTER USER memfit_development WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE "memfit_development" to memfit_development;
```

### Test

```
CREATE DATABASE memfit_test;
CREATE USER memfit_test WITH PASSWORD 'password';
ALTER USER memfit_test WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE "memfit_test" to memfit_test;
```

### db restarting

bundle exec rake db:drop RAILS_ENV=development
bundle exec rake db:create RAILS_ENV=development
bundle exec rake db:migrate RAILS_ENV=development
