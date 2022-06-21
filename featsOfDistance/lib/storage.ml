module Graph = struct
  module Queries = struct
    open Printf

    let create_author =
      sprintf "CREATE (:Person:Author {name: '%s', id: '%s', img: '%s'})"
  end
end
