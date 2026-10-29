#!/usr/bin/env bash
# ~/git/github.com/chriswoodfield/gitkey/gitkey.sh
set -euo pipefail

GITKEY_CONFIG_FILE="${GITKEY_CONFIG_FILE:-${HOME}/.gitkey_config}"
GITKEY_SSH_DIR="${GITKEY_SSH_DIR:-${HOME}/.ssh}"
GITKEY_BASE_DIR="${GITKEY_BASE_DIR:-${HOME}/git/github.com}"

# 1. Ensure config file exists
[[ -f "${GITKEY_CONFIG_FILE}" ]] || touch "${GITKEY_CONFIG_FILE}"

current_pwd="$(pwd)"

# 2. Extract username dynamically if current path is under ~/git/github.com/
if [[ "${current_pwd}" == "${GITKEY_BASE_DIR}/"* ]]; then
  # Strip the base directory prefix
  rel_path="${current_pwd#"${GITKEY_BASE_DIR}/"}"
  # Extract the top-level folder name (handles spaces in folder names)
  matched_user="${rel_path%%/*}"

  key_file="${GITKEY_SSH_DIR}/id_ed25519_github.com_${matched_user}"

  # 3. Check for matching SSH key file
  if [[ ! -f "${key_file}" && ! -f "${key_file}.pub" ]]; then
    printf "gitkey error: No SSH key found for '%s'\n" "${matched_user}" >&2
    printf "Expected: %s or %s.pub\n" "${key_file}" "${key_file}" >&2
    exit 1
  fi

  # 4. Check cache for expected SHA256; generate and append if absent
  expected_sha=""
  if grep -Fq "${matched_user}|" "${GITKEY_CONFIG_FILE}" 2>/dev/null; then
    expected_sha="$(grep -F "${matched_user}|" "${GITKEY_CONFIG_FILE}" | cut -d'|' -f3 | head -n 1)"
  fi

  if [[ -z "${expected_sha}" ]]; then
    target_key="${key_file}"
    [[ -f "${key_file}.pub" ]] && target_key="${key_file}.pub"
    expected_sha="$(ssh-keygen -lf "${target_key}" | awk '{print $2}')"
    printf "%s|%s|%s\n" "${matched_user}" "${key_file}" "${expected_sha}" >> "${GITKEY_CONFIG_FILE}"
  fi

  # 5. Inspect currently loaded keys in ssh-agent
  loaded_shas="$(ssh-add -l 2>/dev/null | awk '{print $2}' || true)"
  loaded_count="$(echo -n "${loaded_shas}" | grep -c '^SHA256:' || true)"

  # 6. Verify if the required key is the ONLY key loaded
  if [[ "${loaded_count}" -eq 1 && "${loaded_shas}" == "${expected_sha}" ]]; then
    : # Required key is exclusively loaded; no changes needed
  else
    ssh-add -D >/dev/null 2>&1 || true
    ssh-add --apple-use-keychain "${key_file}" >/dev/null 2>&1
  fi
fi

# 7. Execute the git command
exec git "$@"
