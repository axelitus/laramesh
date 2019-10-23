# Laramesh

Laramesh is a _mesh_ of Docker containers to rapidly scaffold a development environment for Laravel.

## Usage

Installing Laramesh is simple, just navigate to your Laravel project folder and run the following commands:

```bash
git clone --depth=1 --branch=master git://github.com/axelitus/laramesh.git .laramesh/tmp \
&& cd .laramesh/tmp \
&& git archive --format=tar --worktree-attributes --output=laramesh.tar HEAD \
&& tar xvf laramesh.tar -C .. \
&& cd ../.. \
&& rm -rf .laramesh/tmp
```

_**Notes:**_

- You can replace`--branch=master` for any available tag, e.g. `--branch=1.0.9`.

After installing Laramesh you are almost ready to start your container mesh. The next step is to configure your application code path. To do so we need to make a copy of the `.env.example` file. From your Laravel project folder run the following commands:

```bash
cp .laramesh/.env.example .laramesh/.env
```

In this file you need to set the `APP_SRC` variable to `../` (all paths in Laramesh are set to be relative to the `.laramesh` folder, so `../` becomes your Laravel project folder).

Before you run your containers for the first time, it is also recommended that you review all available variables and change at least the following to suit your needs:

- `APP_ID`: Set it so your containers are identified by a project ID.
- `MYSQL_CREATE_SCHEMA`: Set it to the database you will be using in your project.
- `APP_OWNER_GID`: Set it to match your host account UID.
- `APP_OWNER_UID`: Set it to match your host account GID.

_**Notes:**_

- After running your containers for the first time, mysql will be initialized and further runs won't create new schemas nor modify existing users.
- Don't forget to match your Laravel project `.env` configuration.

You are now ready to run Laramesh. From your Laravel project folder run the following commands:

```bash
docker-compose -f .laramesh/docker-compose.yml --project-directory .laramesh up
```

_**Notes:**_

- If you need to re-build the images for some reason you can add `--build` at the end of the command.
- If you need to review the config because some paths are not working correctly do so by running: `docker-compose -f .laramesh/docker-compose.yml --project-directory .laramesh config`. This command will output the processed docker-compose.yml` file.

Done! If you navigate to `http://localhost:8000` you should see your application running (use the port you configured in your `.env` file). Don't forget to run your migrations! Happy _larameshing_!
