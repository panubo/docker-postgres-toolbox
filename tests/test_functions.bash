TOOLBOX_IMAGE="panubo/postgres-toolbox:latest"
POSTGRES_TARGET_VERSION="17"

diag() {
	echo "$@" | sed -e 's/^/# /' >&3 ;
}
