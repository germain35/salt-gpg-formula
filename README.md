# salt-gpg-formula
## Key Creation
```shell
salt-call state.apply gpg.ceate_key pillar='{"gpg_email":"", "gpg_passphrase":""}'
```
