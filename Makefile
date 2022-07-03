# https://registry.hub.docker.com/_/vault/
root_token := root_token
vault_port := 8200
start:
	docker run --rm --name vault -p ${vault_port}:${vault_port} --cap-add=IPC_LOCK -e 'VAULT_DEV_ROOT_TOKEN_ID=${root_token}' -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:${vault_port}' vault

connect:
	docker exec -e VAULT_TOKEN=${root_token} -e VAULT_ADDR='http://localhost:${vault_port}' -it vault sh

# source .env
terraform:
	terraform init
	terraform apply
