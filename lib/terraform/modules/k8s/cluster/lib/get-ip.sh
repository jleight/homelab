#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

parse_input() {
	eval "$(jq -r '@sh "export PASSWORD=\(.password) INTERFACE=\(.interface) MAC_ADDRESS=\(.mac_address)"')"
}

elevate() {
	if [[ "${EUID}" == "0" ]]; then
		"$@"
	else
		echo "${PASSWORD}" | sudo -S "$@"
	fi
}

main() {
	parse_input "$@"

	elevate arp-scan -l -I "${INTERFACE}" \
		| grep "${MAC_ADDRESS}" \
		| awk '{ print $1 }' \
		| jq --raw-input --slurp '{"ips": split("\n") | map(select(length > 0)) | unique | join(",")}'
}

main "$@"
