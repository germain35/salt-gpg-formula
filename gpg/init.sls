{%- from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install
  - gpg.config
  - gpg.delete
  - gpg.import