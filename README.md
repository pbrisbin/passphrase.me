> [!NOTE]
> All of my GitHub repositories have been **archived** and will be migrated to
> Codeberg as I next work on them. This repository either now lives, or will
> live, at:
>
> https://codeberg.org/pbrisbin/passphrase.me
>
> If you need to report an Issue or raise a PR, and this migration hasn't
> happened yet, send an email to me@pbrisbin.com.

# passphrase.me

`curl`-able passphrases generated using entropy from [random.org][].

[Details][].

[random.org]: https://www.random.org
[details]: https://passphrase-me.onrender.com/about

## Development

```console
stack setup
stack build --dependencies-only
stack build --fast --pedantic --test --file-watch
```

## Local instance (native)

```console
RANDOM_API_KEY=xxx stack run passphrase-me:passphrase-me
```

## Local instance (docker)

```console
docker build --tag passphrase-me .
docker run --rm \
  -e RANDOM_API_KEY=xxx \
  -p 3000:3000
  passphrase-me
```

## Release

Push to `master`, Render will build and deploy.
