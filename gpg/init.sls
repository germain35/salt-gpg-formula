{% from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install
  - gpg.delete
  - gpg.import