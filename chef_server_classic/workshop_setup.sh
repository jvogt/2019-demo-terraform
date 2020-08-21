#!/bin/bash

echo "-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAx1U8abg74QUrukZnh39Z
WW4UCVVn9BNccHcOVVKQlij00EUMqYV9aK03zKkDv1/EkKmw55ERLOIKOcf8xqm9
XwSClbt3EE8cja0SCk10f3TGQsWv3j2FnhNA9XVpSmoddliGdJ7UfgAtYN6biIPv
RAbpeqQJWGHI7D+lShn5pXpWghIBLEaJ1vHo9YvCsH7h1QkBr8ssTjAg6y/YkXt6
z93RFN/dKM2dzzJugY03PEmOR0gjTUzMszOQ63AlmrWUmM+cuhWIk34NmRq2XiEW
mlRwsoqSlcR5ucbqOoKASvnn1ljV6UU8fzW84Bp8wVBbJEcvieBK5+QzBtxWIIFY
Lg0pqx5x42PX1VIVS8woQq8mVvmXWQiBjjyrkuZ4R255BbppeZqCaWeyb6oTWWr9
Ae0uerjplHC9B8Y1wCFisAAfNOxrEGvpJbsYsNfkyvlYxlRDkpk5kiS2hsIw0qgK
9vllyyWxWzITh5ZMKcvvM80nIansAq1iTPBMb4jPMvANaRXz1M1GvsO7DHCY8QqW
p8w+D/qScVBH0h/xELcfiuc6qkRrp5159u7WZD/20dULbKqzmiSc5COOrOpnIyTE
38iZ6kVTvD4O7gChORJc4OpOhnz2X9cKwTFXefmJEYfqQCQxwO5tSS+HElvma4iQ
PrQokyyGPLyv8/oKTjcHAxUCAwEAAQ==
-----END PUBLIC KEY-----" > /tmp/pubkey.pem

chef-server-ctl org-create workshop "Workshop"

for i in `seq 0 50`; do
  chef-server-ctl user-create workstation${i} Workstation User_${i} nobody${i}@nowhere.invalid 'p@s5w0rD!'
  chef-server-ctl org-user-add -a workshop workstation${i}
  chef-server-ctl add-user-key workstation${i} --public-key-path /tmp/pubkey.pem
done
