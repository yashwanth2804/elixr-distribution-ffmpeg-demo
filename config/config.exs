import Config

config :distributed_example,
  node: [
    :"node1@WHITE-BEAST",
    :"node2@WHITE-BEAST"
  ],
  cookie: :my_secret_cookie
