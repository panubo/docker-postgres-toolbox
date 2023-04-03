TOOLBOX_IMAGE="panubo/postgres-toolbox:latest"
POSTGRES_TARGET_VERSION="14.7"

diag() {
	echo "$@" | sed -e 's/^/# /' >&3 ;
}
