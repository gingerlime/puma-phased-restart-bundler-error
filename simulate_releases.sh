#!/bin/bash

SOURCE_DIR=/usr/src/app
RELEASE_ROOT=/usr/src/releases
PUMA_MASTER_PIDFILE=/usr/src/app/puma.pid

create_release_directory ()
{
  mkdir -p "${RELEASE_ROOT}"
}

cd_to_current_release ()
{
  cd "${RELEASE_ROOT}/current" || exit
}

create_release_and_update_current_symlink ()
{
  local release_name=$(date '+%s%N')
  local release_path="${RELEASE_ROOT}/${release_name}"
  echo "Creating release at ${release_path}"
  cp -R "${SOURCE_DIR}" "${release_path}"
  cd "${release_path}" || exit
  bundle config set deployment 'true'
  bundle install
  ln -fsn "${release_path}" "${RELEASE_ROOT}/current"
}

start_puma_master ()
{
  echo "Starting puma master"
  cd_to_current_release
  bundle exec puma -C $RELEASE_ROOT/current/config/puma.rb &
}

start_phased_restart ()
{
  echo "Starting phased restart"
  cd_to_current_release
  bundle config set deployment 'true'
  bundle install
  bundle exec pumactl -F $RELEASE_ROOT/current/config/puma.rb phased-restart || exit
}

delete_old_releases ()
{
  echo "Deleting old releases"
  local current_release=$(readlink -f "${RELEASE_ROOT}"/current)
  while IFS= read -r -d '' release_dir; do
    if [[ ${release_dir} != "${current_release}" ]] && ! [[ -h ${release_dir} ]]; then
      echo "Removing ${release_dir}"
      rm -r "${release_dir}"
    fi
  done < <(find "${RELEASE_ROOT}" -mindepth 1 -maxdepth 1 -print0)
}

test_connection ()
{
  sleep 10
  echo "Testing connection to puma master"
  curl -4 --retry 5 --retry-connrefused --silent --show-error http://localhost:9292 > /dev/null || exit
}

main ()
{
  create_release_directory

  create_release_and_update_current_symlink
  start_puma_master
  test_connection

  create_release_and_update_current_symlink
  start_phased_restart
  test_connection
  delete_old_releases

  create_release_and_update_current_symlink
  start_phased_restart
  test_connection
}

main
