#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

main() {
	kubectl get pods \
			--all-namespaces \
			-o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTNETWORK:.spec.hostNetwork \
			--no-headers=true \
		| grep '<none>' \
		| awk '{print "-n "$1" "$2}' \
		| xargs -L 1 -r kubectl delete pod
}

main "$@"
