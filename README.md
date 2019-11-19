# Matthew Hilty's Backend Demo of a Phoenix Web Application
#### To start your Phoenix server:

  * Install [Elixir](https://elixir-lang.org/install.html) and [PostgreSQL](https://www.postgresql.org/download/).
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install && cd ..`
  * Start Phoenix endpoint with `mix phx.server`, or run tests with `mix test`.

Now you can visit [`localhost:4000/`](http://localhost:4000) from your browser.

You also have the option of making direct API requests with an HTTP/REST tool like curl or PostMan. The API service's basepath is [`/api`](http://localhost:4000/api).

#### API Service:
Examples of possible API calls include:

```
prompt> username="admin" # The pre-seeded admin's username is "admin".
prompt> password="admin" # The pre-seeded admin's password is also "admin".
prompt> # The following will supply a fresh token that can be used in subsequent API calls.
prompt> curl -s \
..> "localhost:4000/api/login" \
..> -H "Content-Type: application/json" \
..> -d "{\"username\":\"$username\",\"password\":\"$password\"}"

{"session":{"user":{"username":"admin"},"token":"<TOKEN HERE>"}}
```

```
prompt> # Request a listing of pharmacies.
prompt> # Put your token in an "Authorization" header to be granted access.
prompt> token="<PUT YOUR TOKEN HERE>"
prompt> curl -s "localhost:4000/api/pharmacies" -H "Authorization: Token $token"
```

```
prompt> # Request today's listing of active orders.
prompt> token="<PUT YOUR TOKEN HERE>"
prompt> curl -s "localhost:4000/api/orders" \
..> -H "Authorization: Token $token"
```

```
prompt> # Request a listing of all orders.
prompt> token="<PUT YOUR TOKEN HERE>"
prompt> curl -s "localhost:4000/api/orders?order_state=all&pickup_date=all" \
..> -H "Authorization: Token $token"
```

```
prompt> # Request a listing of orders delivered by courier with id 2.
prompt> token="<PUT YOUR TOKEN HERE>"
prompt> curl -s "localhost:4000/api/orders?order_state=delivered&courier_id=2&pickup_date=all" \
..> -H "Authorization: Token $token"
```

Other examples of available API calls, as well as UNIX-compatible shortcut
functions to facilitate making API requests, can be found in the file 'commands.sh'.

For example, if the JSON-processing utility ['jq'](https://stedolan.github.io/jq/) is available, the above calls
could be also accomplished as follows:

```
prompt> username="admin"
prompt> password="admin"
prompt> # Go to this project's root directory, where the file 'commands.sh' can be found.
prompt> source commands.sh # Make the utility functions command-line accessible.
prompt> login_token $username $password | jq '.session.token' | tr -d '"' > tokens/admin
prompt> request pharmacies admin | jq
prompt> request orders admin | jq
prompt> request "orders?order_state=all&pickup_date=all" admin | jq
prompt> request "orders?order_state=delivered&courier_id=2&pickup_date=all" admin | jq
```

Also found in 'commands.sh', the function `test_api_calls` demonstrates a fairly comprehensive set of API calls. To use it, source 'commands.sh', and then run the function.

```
prompt> # Go to this project's root directory, where the file 'commands.sh' can be found.
prompt> source commands.sh # Make the utility functions command-line accessible.
prompt> output_file="<DETERMINE OUTPUT FILE>"
prompt> test_api_calls > "$output_file"
```

#### What have been the most challenging parts of this implementation?
This demo application has been my first use of the Phoenix web framework, so in a way, this entire app has been the most challenging part. In particular, finding Elixir and PostgreSQL tooling compatible with my NixOS operating system took longer than I expected. And achieving a base level of Elixir fluency -- e.g., an awareness of protocols and Kernel functions and an appreciation for the finicky interplay between strings and atoms -- also took some time.

However, the most challenging parts of the implementation specifically involved validation and error-handling. From what I can tell, Phoenix applications customarily rely on pipelining for error-handling and aspect management (like authentication). However, although pipelining and error-fallback are easy mechanisms for reducing code duplication, I decided, after some trial and error, to handle these code concerns differently. In earlier implementation attempts, for example, I'd tried using a fallback controller to resolve errors, but this approach became unwieldy as the number of errors to be handled grew. Proper resolution of each error often required context in addition to just the error type, and that necessitated ad-hoc function parameters or map fields. In the end, having each controller action explicitly handle any of its own unique assortment of error types (except possibly authentication/authorization errors) seemed clearest. And that approach also seemed most consistent with the single-responsibility principle of software design.

#### What aspects of this demo application require further attention?
My goal has been to learn Elixir's Phoenix framework by creating a backend-focused demo, so I've stopped short of trying to cultivate other important project concerns. In particular, the web interface's frontend design has been neglected. Other aspects like logging, alternative credentialing, and API-service specification should also be incorporated.
