# Datalevi

Open Source personal storage daemon

Created for linux.  No guaranteed support for windows or mac.

## Deployment

Not yet

## Development

### Prerequisites

  * Elixir (https://elixir-lang.org/install.html)
    * Linux: (recommended, via [asdf](https://asdf-vm.com/#/))

      First follow the steps [here](https://asdf-vm.com/#/core-manage-asdf).

      ```
      > asdf install erlang 23.1
      > asdf install elixir 1.10.4-otp-23
      > asdf local erlang 23.1
      > asdf local elixir 1.10.4-otp-23
      ```

  * Postgresql (user: postgres / pw: postgres)
    * Linux:
      ```
      > sudo -u postgres psql
      psql> ALTER USER postgres PASSWORD 'postgres';
      psql> \q
      ```


### Steps

  * Clone from this repo.
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

