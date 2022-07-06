let () =
  FeatsOfDistance.Server.start
    (FeatsOfDistance.Utils.get_env_var "PORT" ~default:"8081" |> int_of_string)
