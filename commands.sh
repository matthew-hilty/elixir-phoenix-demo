start_postgres() {
  PGDATA="$PWD/db"
  initdb --no-locale --encoding=UTF-8
  pg_ctl -l "$PGDATA/server.log" start
  createuser postgres --createdb
}
stop_postgres() {
  mix ecto.drop
  MIX_ENV=test mix ecto.drop
  dropuser postgres
  pg_ctl stop
}
request() {
  if [ "$#" = 1 ]; then
    curl -s "localhost:4000/api/$1"
  else
    if [ ! -d "tokens" ]; then
      mkdir -p "tokens"
    fi
    if [ ! -f "tokens/$2" ]; then
      touch "tokens/$2"
    fi
  fi
  if [ "$#" = 2 ]; then
    curl -s                                      \
      "localhost:4000/api/$1"                    \
      -H "Authorization: Token $(\cat tokens/$2)"
  elif [ "$#" = 3 ]; then
    curl -s                                      \
      "localhost:4000/api/$1"                    \
      -X "$3"                                    \
      -H "Authorization: Token $(\cat tokens/$2)"
  elif [ "$#" = 4 ]; then
    curl -s                                      \
      "localhost:4000/api/$1"                    \
      -X $3                                      \
      -H "Authorization: Token $(\cat tokens/$2)" \
      -H "Content-Type: application/json"        \
      -d "$4"
  elif [ "$#" = 5 ]; then
    curl -s                                      \
      "localhost:4000/api/$1"                    \
      -X "$3"                                    \
      -H "Authorization: Token $(\cat tokens/$2)" \
      -H "Content-Type: application/json"        \
      -H "Accept: $5"                            \
      -d "$4"
  fi
}
get_date() {
  echo "20$(shuf -i 19-25 -n 1)-$(shuf -i 1-12 -n 1)-$(shuf -i 1-31 -n1)"
}
get_today_plus_five_days() {
  echo "$(date +%Y-%m)-$(( $(date +%d) + 5 ))"
}
get_username() {
  echo "john_evelyn_$RANDOM$RANDOM"
}
parse_json() {
  # If the 'jq' executable is available, use it.
  # Otherwise, pass data through the pipeline without modification.
  if command -v jq >/dev/null 2>&1; then
    jq
  else
    \cat
  fi
}
login_token() {
  request login _ POST "{\"username\":\"$1\",\"password\":\"$2\"}"
}
note() {
  echo
  echo "$1"
}
address() {
  echo "11059-$RANDOM$RANDOM Nulliusinverba NEA, Asteroid Belt, Solar System"
}
test_api_calls() {
  note "TRY TO SHOW LIST PHARMACIES WITHOUT FIRST LOGGING IN"
  request pharmacies _ | parse_json

  login_token best_rx best_rx | jq '.session.token' | tr -d '"' > tokens/best_rx
  if [ "$?" -gt 0 ]; then
    >&2 echo "Error: Failure to log in the seeded pharmacy."
    return 1
  fi

  note "TRY TO SHOW LIST PHARMACIES WITHOUT ADMINISTRATOR ACCESS"
  request pharmacies best_rx | parse_json

  login_token admin admin | jq '.session.token' | tr -d '"' > tokens/admin
  if [ "$?" -gt 0 ]; then
    >&2 echo "Error: Failure to log in the seeded administrator."
    return 2
  fi
  local name="John Evelyn "
  local email="@sapere_aude.co.uk"
  local password="correcthorsebatterystaple"

  note "CREATE ADMINISTRATOR"
  username="$(get_username)"
  read -d '' administrator <<ADMINISTRATOR
  { "administrator":
    { "username": "$username",
      "email": "$username$email",
      "password": "$password"
    }
  }
ADMINISTRATOR
  request administrators admin POST "$administrator" | parse_json
  note "SHOW ADMINISTRATOR #2"
  request administrators/2 admin | parse_json
  note "LIST ADMINISTRATORS"
  request administrators admin | parse_json

  # Testing API's courier-related calls.
  note "CREATE COURIER"
  username="$(get_username)"
  read -d '' courier <<COURIER
  { "courier":
    { "name": "$username",
      "username":"$username",
      "email": "$username$email",
      "address": "$(address)",
      "password": "$password"
    }
  }
COURIER
  request couriers admin POST "$courier" | parse_json
  note "SHOW COURIER #2"
  request couriers/2 admin | parse_json
  note "LIST COURIERS"
  request couriers admin | parse_json

  note "CREATE PHARMACY"
  username="$(get_username)"
  read -d '' pharmacy <<PHARMACY
  { "pharmacy":
    { "name": "$username",
      "username":"$username",
      "email": "$username$email",
      "address": "$(address)",
      "password": "$password"
    }
  }
PHARMACY
  request pharmacies admin POST "$pharmacy" | parse_json
  note "SHOW PHARMACY #2"
  request pharmacies/2 admin | parse_json
  note "LIST PHARMACIES"
  request pharmacies admin | parse_json

  note "CREATE PATIENT"
  name="$(get_username)"
  read -d '' patient <<PATIENT
  { "patient":
    { "name": "$name",
      "address": "$(address)"
    }
  }
PATIENT
  request patients admin POST "$patient" | parse_json
  note "SHOW PATIENT #2"
  request patients/2 admin | parse_json
  note "LIST PATIENTS"
  request patients admin | parse_json

  note "CREATE ORDER [Causes error if previously created.]"
  username="$(get_username)"
  read -d '' order <<ORDER
  { "order":
    { "patient_id": 2,
      "pharmacy_id": 2,
      "courier_id": 2,
      "pickup_date": "$(get_today_plus_five_days)",
      "pickup_time": "14:00"
    }
  }
ORDER
  request orders admin POST "$order" | parse_json
  note "SHOW ORDER #2"
  request orders/2 admin | parse_json
  note "MARK ORDER #2 UNDELIVERABLE [Causes error if previously canceled/delivered.]"
  request orders/2/mark_undeliverable admin POST | parse_json
  note "CANCEL ORDER #2 [Cancels order #2 the first time; causes error subsequently.]"
  request orders/2/cancel admin POST | parse_json
  note "DELIVER ORDER #1 [Delivers order #1 the first time; causes error subsequently.]"
  request orders/1/deliver admin POST | parse_json

  note "LIST ORDERS -- order_state: active, pickup_date: today"
  request orders admin | parse_json
  note "LIST ORDERS -- order_state: all, pickup_date: today"
  request "orders?order_state=all" admin | parse_json
  note "LIST ORDERS -- order_state: active, pickup_date: all"
  request "orders?pickup_date=all" admin | parse_json
  note "LIST ORDERS -- order_state: all, pickup_date: all"
  request "orders?order_state=all&pickup_date=all" admin | parse_json
  future="$(get_today_plus_five_days)"
  note "LIST ORDERS -- order_state: active, pickup_date: $future"
  request "orders?order_state=active&pickup_date=$future" admin | parse_json
  read -d '' request <<REQUEST
  LIST ORDERS --
    order_state: active,
    pickup_date: today,
    patient_id: 1,
    pharmacy_id: 2,
    courier_id: 2
REQUEST
  note "$request"
  request "orders?patient_id=1&pharmacy_id=2&courier_id=2" admin | parse_json
  note "LIST ORDERS -- order_state: delivered, pickup_date: all"
  request "orders?order_state=delivered&pickup_date=all" admin | parse_json
  read -d '' request <<REQUEST
  LIST ORDERS --
    order_state: invalid,
    pickup_date: invalid,
    pickup_time: invalid,
    patient_id: invalid,
    pharmacy_id: invalid,
    courier_id: invalid
REQUEST
  note "$request"
  local orders="orders\
?order_state=invalid\
&pickup_date=invalid\
&pickup_time=invalid\
&patient_id=invalid\
&pharmacy_id=invalid\
&courier_id=invalid"
  request "$orders" admin | parse_json

  note "LIST ORDERS IN CSV FORMAT -- order_state: delivered, pickup_date: all"
  request                                          \
    "orders?order_state=delivered&pickup_date=all" \
    admin                                          \
    GET                                            \
    ""                                             \
    "text/csv"
}
