Require
=======

Manage your project's dependencies with a pretty DSL.

* Gem activation
* Require calls
* Load paths
* Gemspec configuration

Install
-------

<pre>
sudo gem install require
</pre>

Example
-------

Create <code>require.rb</code> in your project's root directory:

<pre>
require 'rubygems'
gem 'require'
require 'require'

Require do

  gem(:sinatra, '=0.9.4') { require 'sinatra/base' }
  gem(:haml, '=2.2.16') { require %w(haml sass) }

  lib do
    gem :sinatra
    gem :haml
    load_path 'vendor/authlogic/lib'
    require 'authlogic'
  end
end
</pre>

Then in your library file (<code>lib/whatever.rb</code>):

<pre>
require File.expand_path("#{File.dirname(__FILE_)}/../require")
Require.lib!
</pre>

What does <code>Require.lib!</code> do?

* Activates sinatra and haml gems
* Requires sinatra, haml, and sass
* Adds vendor/authlogic/lib to the load paths
* Requires authlogic