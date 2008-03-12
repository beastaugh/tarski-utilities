# Tarski Utilities

The files included in this repository constitute a toolset for working with Tarski, a WordPress theme (http://tarskitheme.com). Hopefully they will prove useful to someone. List of files and required Ruby gems follows.

## Files

  * __Rakefile__: some Rake tasks to tag and branch releases, create zip archives, generate an HTML version of the changelog file and update a version feed.
  * __lib/tarski_version.rb__: generates a version feed. Plugins mostly live in the WP plugin repository now, and get update notification for free, but since 1) themes don't get this and 2) update notification wasn't in WP core when I did it, I rolled my own.
  * __conf/version.yml__: dummy configuration for the version feed generator.

## Required Gems

These tools are written in Ruby, so they require the RubyGems packaging system and the following gems:

  * __Rake__: to run the tasks.
  * __YAML__ (comes with the Ruby standard library): reader and writer for the YAML file format, needed to read the config file.
  * __Builder__: programmatic XML generation, required to create the Tarski version feed.
  * __BlueCloth__: Markdown format reader and writer, used to read Tarski's changelog file.
  * __Hpricot__: DOM scripting in Ruby for HTML and XML, used to parse the Tarski changelog and generate a list of links to each version's entry in the changelog.