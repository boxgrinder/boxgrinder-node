# Installation

Make sure you have BoxGrinder REST [installed correctly][bg_rest_readme].

## JRuby

Get latest JRuby (1.6+) and unpack it.

## BoxGrinder Node

Get BoxGrinder Node surces from Git repository:

    mkdir ~/git
    cd ~/git
    git clone git://github.com/boxgrinder/boxgrinder-node.git

### Install required gems

    cd boxgrinder-node
    jruby -S gem install hashery kwalify boxgrinder-build

## Libguestfs

Install ruby binding for libguestfs in usual way:

    yum install ruby-libguestfs

## Install libguestfs in JRuby

We need to copy libguestfs Ruby bindings to JRuby lib dirs. For x86_64 Fedora 14 you'll have to:

    cp /usr/lib/ruby/site_ruby/1.8/guestfs.rb $JRUBY_HOME/lib/ruby/site_ruby/1.8/
    cp /usr/lib64/ruby/site_ruby/1.8/x86_64-linux/_guestfs.so $JRUBY_HOME/lib/native/x86_64-Linux/

# Launching

    jruby -Ilib/:$JRUBY_HOME/lib/native/x86_64-Linux/ bin/boxgrinder-node

[bg_rest_readme]: https://github.com/boxgrinder/boxgrinder-rest/blob/master/README.md
