# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Add a CHANGELOG entry for app changes
has_app_changes = !git.modified_files.grep(/AnotherFeedlyApp\/AnotherFeedlyApp/).empty?
if !declared_trivial && !git.modified_files.include?("CHANGELOG.md") && has_app_changes
  fail("Please include a CHANGELOG entry. \nYou can find it at [CHANGELOG.md](https://github.com/realm/jazzy/blob/master/CHANGELOG.md).")
  message "Note, we hard-wrap at 80 chars and use 2 spaces after the last line."
end

fail "Please provide a summary in the Pull Request description" if github.pr_body.length < 5

swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files

