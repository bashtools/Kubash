#!/usr/bin/env bash

# This is a simple application that outputs "Hello World!"
# It has one COMMAND:
# - "version", which outputs version information.
#
# It has two valid options:
# - "-h" or "--help", which prints help text.
# - "-v" or "--version", which prints version information.
#
# Tips:
# - This script can be used as a template for creating other scripts.
# - This script can now safely grow large.
# - Either `source` the parser.sh script or include the code in full in this
#   script.
# - $OK, $ERROR, $STDERR, and $STOP are defined in parser.sh.

# Imports ------------------------------------------------------------

# Import the parser.sh library
# shellcheck source=parser.sh
source ../parser.sh

# Globals ------------------------------------------------------------
VERSION="0.0.1"

# main() - Execution starts here.
main() {
  declare -i retval="${OK}"

  # Program the parser's state machine
  # It adds a COMMAND state named "version" and if that state matches then the
  # next state is the END state, which will call the `version` function. Note
  # that the "version" COMMAND should have it's own set of options and help
  # text but that is beyond the scope of this example, and would probably be
  # left like this in a real script anyway.
  PA_add_state "COMMAND" "version" "END" "version"

  # Set up the parser's option callbacks
  # "" - Is for global options, so `process_options` will be called
  #      for each global option
  PA_add_option_callback "" "process_options"

  # Set up the parser's usage callbacks
  # "" - Is for global options, so, for various error conditions,
  #      `usage` will be called
  PA_add_usage_callback "" "usage"

  # Set up the parser's run callbacks
  # When the parser has finished parsing the command line arguments
  # it will call the run callback defined for the COMMAND and SUBCOMMAND.
  # "" - means that `run` will be called when no COMMAND is specified
  PA_add_run_callback "" "run"

  # Run the parser
  PA_run "$@" || retval=$?

  return ${retval}
}

# Functions ----------------------------------------------------------
#
# All the functions below are called by the parser.

# run() - Run the application.
# PA_run will call this function if it should be called.
# Args: None
run() {
  echo "Hello World!"

  return "${OK}" # or any other exit code
}

# process_options() - Process command line options.
# PA_run will call this function for each supplied option.
# Args: arg1 - The option to check
process_options() {
  case "$1" in
  -h | --help)
    PA_usage
    return "${STOP}" # So that PA_run will exit immediately
    ;;
  -v | --version)
    version
    return "${STOP}" # So that PA_run will exit immediately
    ;;
  *)
    printf 'ERROR: Invalid global option, "%s".\n' "$1"
    return "${ERROR}"
    ;;
  esac
}

# usage() - Output help text.
# The parser will call this function for various error conditions.
# Args: None
usage() {
  cat <<'EnD'
Usage: helloworld.sh [-hv] [command]

Global options:
  --help
  -h     - This help text
  --version
  -v     - Output the version of this utility

Where command can be one of:
  version - Display version information.

For help on a specific command, run:
  helloworld.sh <command> --help
EnD
}

# version() - Outputs the version information then exits.
version() {
  printf 'Version: %s\n' "${VERSION}"
}

# This should always be at the end of the script
main "$@"

# vim:ft=sh:sw=2:et:ts=2:
