# Vault Helper

This is a companion for https://github.com/banzaicloud/bank-vaults

## Usage

./vaul-helper create $ENGINE_NAME $APP

## Development

`docker build -t vault-helper .; ./vault-helper dump $ENGINE_NAME $APP`

# Troubleshooting

## Permission denied on retrieving key

```sh
level=fatal msg="failed to inject secrets from vault: failed to read secret from path: $ENGINE_NAME/data/$PATH: Error making API request.\n\nURL: GET https://$VAULT_ADDR/v1/$ENGINE_NAME/data/$PATH?version=-1\nCode: 403. Errors:\n\n* 1 error occurred:\n\t*
permission denied\n\n"
```

Check if the policies have enough permission

## Permission denied on login

```sh
level=info msg="failed to request new Vault token Error making API request.\n\nURL: PUT https://$VAULT_ADDR/v1/auth/$ENGINE_NAME/login\nCode: 403. Errors:\n\n* permission denied"
```

This might be because the app service account is not in a ClusterRoleBinding with `system:auth-delegator` or check the `vault.security.banzaicloud.io/vault-path`


## Invalid role name

```sh
level=info msg="failed to request new Vault token Error making API request.\n\nURL: PUT https://$VAULT_ADDR/v1/auth/$ENGINE_NAME/login\nCode: 400. Errors:\n\n* invalid role name \"$APP\""
```

Check that the role exists on the authentication method, if everything fails try to create a very open policy to test like:
```
path "$ENGINE/data/*" {
  capabilities = ["read"]
}
path "$ENGINE/metadata/*" {
  capabilities = ["list"]
}
```

## Namespace not authorized

```
time="2020-09-01T02:31:54Z" level=info msg="failed to request new Vault token Error making API request.\n\nURL: PUT $VAULT_ADDR/v1/auth/$ENGINE/login\nCode: 500. Errors:\n\n* namespace not authorized"
```
Check if witch `vault-role` you are passing, if you are trying to mutate a resource, check if you are passing the controller service account on it
Check if the webhook controller has permission to mutate the resource you are working

## Secret data key or template not defined

```
level=error msg="admission webhook error: mutate generic secret failed: secret data key or template not defined" app=vault-secrets-webhook
```
Check the vault key path, don't forget that the #


## Service Account name not authorized

```
level=info msg="failed to request new Vault token Error making API request.\n\nURL: PUT $VAULT_ADDR/v1/auth/$ENGINE/login\nCode: 500. Errors:\n\n* service account name not authorized"
```

Check the role Bound service account names, check if the SA you are using is in there


## Not found path

```
time="2020-09-30T12:18:07-03:00" level=warning msg="$ENGINE/$APP/envs: Invalid path for a versioned K/V secrets engine. See the API docs fo
r the appropriate API endpoints to use. If using the Vault CLI, use 'vault kv get' for this operation." app=vault-env
time="2020-09-30T12:18:07-03:00" level=fatal msg="failed to inject secrets from vault: key '$KEY' not found
under path: $ENGINE/$APP/envs" app=vault-env
```
You are missing the `data` keyword on your path, e.g: `$ENGINE/data/$APP/envs`


# Reference

- https://blog.doit-intl.com/injecting-secrets-from-aws-gcp-or-vault-into-a-kubernetes-pod-d5a0e84ba892
- https://learn.hashicorp.com/tutorials/vault/agent-kubernetes
- https://github.com/hashicorp/vault-guides/blob/master/identity/vault-agent-k8s-demo/setup-k8s-auth.sh
- https://github.com/hashicorp/vault-guides/tree/master/identity/vault-agent-k8s-demo
- https://www.hashicorp.com/blog/dynamic-database-credentials-with-vault-and-kubernetes/
- https://banzaicloud.com/blog/inject-secrets-into-pods-vault-revisited/
- This is cool, do like this https://github.com/controlplaneio/vault-trust-operator/blob/master/roles/vaultkubeauth/templates/scripts_cm.yml.j2
- https://medium.com/@jackalus/vault-kubernetes-auth-and-database-secrets-engine-6551d686a12
- https://github.com/jacklei/vault-helpers