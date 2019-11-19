alias Demo.{Accounts,Orders,OrderStates,Patients}

[{:ok, _active}, {:ok, _canceled}, {:ok, _delivered}, {:ok, _undeliverable}] =
  Enum.map(
    ~w(active canceled delivered undeliverable)s,
    fn (description) ->
      OrderStates.create_order_state(%{description: description})
    end)

{:ok, _admin} =
  Accounts.create_administrator(%{
    username: "admin",
    administrator: %{
      email: "admin@example.com"
    },
    credential: %{
      password: "admin"
    }
  })

{:ok, better_rx} =
  Accounts.create_pharmacy(%{
    username: "better_rx",
    pharmacy: %{
      name: "BetterRx",
      address: "1275 Kinnear Road, Columbus, OH 43212",
      email: "admin@betterrx.com",
    },
    credential: %{
      password: "better_rx"
    }
  })

{:ok, best_rx} =
  Accounts.create_pharmacy(%{
    username: "best_rx",
    pharmacy: %{
      name: "BestRx",
      address: "123 Austin St., Austin, TX 78702",
      email: "admin@bestrx.com",
    },
    credential: %{
      password: "best_rx"
    }
  })

{:ok, _drugsrus} =
  Accounts.create_pharmacy(%{
    username: "drugsrus",
    pharmacy: %{
      name: "Drugs R Us",
      address: "4925 LA Ave., Los Angeles, CA 90056",
      email: "admin@drugsrus.com",
    },
    credential: %{
      password: "drugsrus"
    }
  })

{:ok, same_day_delivery} =
  Accounts.create_courier(%{
    username: "same_day_delivery",
    courier: %{
      name: "Same Day Delivery",
      address: "900 Trenton Lane, Trenton, NJ 08536",
      email: "admin@samedaydelivery.com",
    },
    credential: %{
      password: "same_day_delivery"
    }
  })

{:ok, previous_day_delivery} =
  Accounts.create_courier(%{
    username: "previous_day_delivery",
    courier: %{
      name: "Previous Day Delivery",
      address: "7433 LA Ct., Los Angeles, CA 90056",
      email: "admin@previousdaydelivery.com",
    },
    credential: %{
      password: "previous_day_delivery"
    }
  })

{:ok, john_doe} =
  Patients.create_patient(%{
    name: "John Doe",
    address: "123 Mockingbird Ln., Anywhere, DE 00000"
  })

now = Time.utc_now()
today = Date.utc_today()
future = Date.add(today, 5)

{:ok, _order0} =
  Orders.create_order(%{
    patient_id: john_doe.id,
    pharmacy_id: better_rx.pharmacy.id,
    courier_id: same_day_delivery.courier.id,
    pickup_date: today,
    pickup_time: now
  })
{:ok, _order1} =
  Orders.create_order(%{
    patient_id: john_doe.id,
    pharmacy_id: better_rx.pharmacy.id,
    courier_id: same_day_delivery.courier.id,
    pickup_date: future,
    pickup_time: now
  })
{:ok, _order2} =
  Orders.create_order(%{
    patient_id: john_doe.id,
    pharmacy_id: best_rx.pharmacy.id,
    courier_id: same_day_delivery.courier.id,
    pickup_date: today,
    pickup_time: now
  })
{:ok, _order3} =
  Orders.create_order(%{
    patient_id: john_doe.id,
    pharmacy_id: best_rx.pharmacy.id,
    courier_id: same_day_delivery.courier.id,
    pickup_date: future,
    pickup_time: now
  })
{:ok, _order4} =
  Orders.create_order(%{
    patient_id: john_doe.id,
    pharmacy_id: better_rx.pharmacy.id,
    courier_id: previous_day_delivery.courier.id,
    pickup_date: today,
    pickup_time: now
  })
{:ok, _order5} =
  Orders.create_order(%{
    patient_id: john_doe.id,
    pharmacy_id: better_rx.pharmacy.id,
    courier_id: previous_day_delivery.courier.id,
    pickup_date: future,
    pickup_time: now
  })
{:ok, _order6} =
  Orders.create_order(%{
    patient_id: john_doe.id,
    pharmacy_id: best_rx.pharmacy.id,
    courier_id: previous_day_delivery.courier.id,
    pickup_date: today,
    pickup_time: now
  })
{:ok, _order7} =
  Orders.create_order(%{
    patient_id: john_doe.id,
    pharmacy_id: best_rx.pharmacy.id,
    courier_id: previous_day_delivery.courier.id,
    pickup_date: future,
    pickup_time: now
  })
