# passphrase.me

`curl`-able passphrases generated using entropy from [random.org][].

[Details][].

[random.org]: https://www.random.org
[details]: https://passphrase-me.herokuapp.com/about

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

```console
make release
```
