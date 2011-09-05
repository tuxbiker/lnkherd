# LNK Herd!

## About

This is a playground and first project for the nice RNB folks.  It mostly works, but it has some funny bugs and a really ugly front-end.  We're going to be working through the bugs (some of which @natebenes introduced on purpose) as a learning experience.

### Getting started

Check out the code by running:

(read-only)

    git clone git://github.com/ruby-noob-brigade/lnkherd.git
    
(read and write)

    git@github.com:ruby-noob-brigade/lnkherd.git
    
Next, `cd` into the directory and install the gems.

    cd lnkherd
    bundle install
    
### Branching

When you want to work on some crazy new feature, the easiest thing to do is to create a branch.  (Where `crazy-idea` is some name that makes sense)

    git checkout -b crazy-idea

After making your changes, commit them to your local repository by running this:

    git commit -am "added magical new features"

Then you can push it to github for everyone to see by using `git push`

    git push origin crazy-idea
    
### Testing

If you want to test out your work (you definitely should), you can run lnkherd on your local machine by typing:

    ruby app.rb

Make sure you change the keys for twitter, otherwise it probably won't work.

### Issues

There are plenty  If you find one, file a bug on the [issues page](https://github.com/ruby-noob-brigade/lnkherd/issues)

## Copyright

Copyright (c) 2011 RNB.