(lang dune 3.17)

(name discord)

(license MIT)

(maintainers "Yuki Tajiri <lmdexpr@gmail.com>")
(authors "Yuki Tajiri")
(source (github lmdexpr/discord.ml))

(generate_opam_files true)

(package
  (name discord)
  (synopsis "Discord library")
  (depends
    (ocaml (>= 5.3))
    yojson
    ppx_yojson_conv
    logs
    hex
    sodium
    ))
