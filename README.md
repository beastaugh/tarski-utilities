Tarski Utilities
================

The files included in this repository constitute a toolset for working with
[Tarski][tarski], a [WordPress][wp] theme. Hopefully they will prove useful to
someone.


Tasks
-----

    rake changelog       # Generate a new changelog HTML file.
    rake feed            # Update the version feed to notify Tarski users of
                         # the new release.
    rake hooks           # Generate the hooks documentation page.
    rake plugin_version  # Add version data to the Tarski website plugin.
    rake update          # Creates a zip archive, and updates the version feed
                         # and changelog.
    rake zip             # Create a zip file of the lastest release in the
                         # downloads directory.


Required libraries
------------------

These tools are written in Ruby, so they require the RubyGems packaging system
and the following gems. [Git][git] is also a requirement.

* [__Rake__][rake] to run the tasks.
* [__Builder__][builder]: programmatic XML generation, required to create the
  Tarski version feed.
* [__RDiscount__][rdiscount]: Markdown format reader and writer, used to read
  Tarski's changelog file.
* [__RubyPants__][rubypants]: Nicer typography with [SmartyPants][smartypants].
* [__Hpricot__][hpricot]: DOM scripting in Ruby for HTML and XML, used to parse
  the Tarski changelog and generate a list of links to each version's entry in
  the changelog.


[tarski]:      http://tarskitheme.com/
[wp]:          http://wordpress.org/
[git]:         http://git-scm.com/
[rake]:        http://http://rake.rubyforge.org/
[yaml]:        http://www.yaml.org/
[builder]:     http://builder.rubyforge.org/
[rdiscount]:   http://github.com/rtomayko/rdiscount/
[rubypants]:   http://chneukirchen.org/blog/static/projects/rubypants.html
[smartypants]: http://daringfireball.net/projects/smartypants/
[hpricot]:     http://code.whytheluckystiff.net/hpricot/
[open_uri]:    http://www.ruby-doc.org/stdlib/libdoc/open-uri/rdoc/
