# Creates the Gerrit projects declared in ccg.self-hosting.gerrit.projects and
# applies their settings. It takes that option as a JSON file, and the GitHub
# account the mirrored projects are on.
#
# It runs in Gerrit's site directory while Gerrit is stopped, so nothing else
# writes to the repositories. It only touches what is declared, and running it
# again with the same input changes nothing.

projects_file=$1
github=$2

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

project_config=$work_dir/project.config
groups_file=$work_dir/groups

# Gerrit searches projects through an index that does not see changes made here
needs_reindex=false

# Answers Git's request for a password. It is only configured for GitHub, and
# it reads the token itself so that the token never appears in a command line.
# shellcheck disable=SC2016 # Expanded by the shell Git runs this in
github_credentials='!f() { echo username=x-access-token; echo "password=$(cat "$CREDENTIALS_DIRECTORY/github-token")"; }; f'

# Runs a jq filter on the current project
project_query() {
  jq -r --arg project "$project" ".[\$project] | $1" "$projects_file"
}

create_repository() {
  if [[ ! -d $repo ]]; then
    git init --quiet --bare --initial-branch=main "$repo"
    needs_reindex=true
  fi
}

# Copies a mirrored project's history from GitHub, only while the project has
# no branches: from then on Gerrit owns it. A failure leaves it to the next
# start, so Gerrit still comes up.
import_history() {
  local url=$github/$project.git

  if [[ $(project_query '.mirror') != true || -n $(git -C "$repo" for-each-ref --count=1 refs/heads) ]]; then
    return 0
  fi
  if ! git -C "$repo" -c "credential.https://github.com.helper=$github_credentials" \
    fetch --quiet "$url" 'refs/heads/*:refs/heads/*' 'refs/tags/*:refs/tags/*'; then
    echo "Could not import $url into $repo" >&2
  fi
}

# Copies the project's configuration out of refs/meta/config to edit it
load_config() {
  git -C "$repo" show refs/meta/config:project.config >"$project_config" 2>/dev/null || :
  git -C "$repo" show refs/meta/config:groups >"$groups_file" 2>/dev/null || :
}

apply_description() {
  local description
  description=$(project_query '.description // empty')

  if [[ -n $description ]]; then
    git config -f "$project_config" project.description "$description"
  fi
}

# Replaces each declared key, which can hold several values
apply_settings() {
  local key value previous_key=''

  # shellcheck disable=SC2016 # These are jq variables
  while IFS=$'\t' read -r key value; do
    if [[ $key != "$previous_key" ]]; then
      git config -f "$project_config" --unset-all "$key" || :
      previous_key=$key
    fi
    git config -f "$project_config" --add "$key" "$value"
  done < <(project_query '
    .settings | to_entries[] | .key as $section
    | .value | to_entries[] | .key as $key
    | ([.value] | flatten)[]
    | ["\($section).\($key)", .] | @tsv')
}

# Gerrit looks up the groups named in project.config in this file
apply_groups() {
  local uuid name

  while IFS=$'\t' read -r uuid name; do
    grep -v "^$uuid"$'\t' "$groups_file" >"$groups_file.new" || :
    printf '%s\t%s\n' "$uuid" "$name" >>"$groups_file.new"
    mv "$groups_file.new" "$groups_file"
  done < <(project_query '.groups | to_entries[] | [.value, .key] | @tsv')
}

# Commits the edited files to refs/meta/config, if they changed anything
save_config() {
  local parent file blob tree previous_tree commit
  local parent_args=()

  parent=$(git -C "$repo" rev-parse -q --verify refs/meta/config || :)
  previous_tree=$(git hash-object -t tree /dev/null)
  if [[ -n $parent ]]; then
    previous_tree=$(git -C "$repo" rev-parse "$parent^{tree}")
    parent_args=(-p "$parent")
  fi

  # Builds the new tree in a separate index: bare repositories have no worktree
  export GIT_INDEX_FILE=$work_dir/index
  rm -f "$GIT_INDEX_FILE"
  git -C "$repo" read-tree "$previous_tree"
  for file in "$project_config" "$groups_file"; do
    if [[ -s $file ]]; then
      blob=$(git -C "$repo" hash-object -w "$file")
      git -C "$repo" update-index --add --cacheinfo "100644,$blob,$(basename "$file")"
    fi
  done
  tree=$(git -C "$repo" write-tree)
  unset GIT_INDEX_FILE

  if [[ $tree == "$previous_tree" ]]; then
    return 0
  fi
  commit=$(git -C "$repo" -c user.name=NixOS -c user.email=nixos@localhost \
    commit-tree "$tree" "${parent_args[@]}" -m "Apply the NixOS configuration")
  git -C "$repo" update-ref refs/meta/config "$commit"
  needs_reindex=true
}

mapfile -t projects < <(jq -r 'keys[]' "$projects_file")

for project in "${projects[@]}"; do
  repo=git/$project.git

  create_repository
  import_history
  load_config
  apply_description
  apply_settings
  apply_groups
  save_config
done

if [[ $needs_reindex == true ]]; then
  gerrit reindex --index projects
fi
