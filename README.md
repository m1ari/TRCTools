# About
Various tools related to the [Terracoin](https://terracoin.io) ([Github](https://github.com/terracoin/terracoin)) project

These tools are developed using Ruby 3.1 installed via [RVM](https://rvm.io/) on Debian 12 (Bookworm) other versions of ruby may also work.


# Installing
## Ruby (Packaged)
Debian 12 provides Ruby 3.1
Ubuntu 22.04 (Jammy) provides Ruby 3.0
Both of these are expected to work. Ruby and related packages can be installed with
    sudo apt install ruby bundler

## Ruby (RVM)
This can allow newer versions of ruby on an older system. The tools were developed with Ruby 3.1.4 installed via RVM.

## Gems
You need to be in the root of the repositry to run these commands

Set the path to install ruby gems to (this keeps them local to the project)
    bundle config set path vendor/bundle

Install gems
    bundle install

After updating the reposity updates may be needed to the installed gems in which case use `bundle install` again

# The Tools
`height.rb` will query various services for their blockheight to make comparing services easier in the case of a blockchain fork


