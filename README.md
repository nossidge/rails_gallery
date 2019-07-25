# Rails Gallery

[Rails Gallery](https://github.com/nossidge/rails_gallery)
by [Paul Thompson](https://github.com/nossidge/)

A simple image gallery web app.

## Install

### Clone the repository

    git clone https://github.com/nossidge/rails_gallery.git
    cd rails_gallery

### Check your Ruby version

    ruby -v

The ouput should start with something like `ruby 2.5.5`

If not, install the right ruby version.

Using [rbenv](https://github.com/rbenv/rbenv):

    rbenv install 2.5.5

Using [rvm](https://rvm.io):

    rvm install ruby-2.5.5

(Or install Ruby yourself manually.)

### Install dependencies

Using [Bundler](https://github.com/bundler/bundler):

    bundle

### Initialize the database

Example images are fetched from
[ThisPersonDoesNotExist.com](https://thispersondoesnotexist.com/)

    rails db:create db:migrate
    rails db:seed

## Serve

    rails server

# Sample data

You can log into any of the seeded accounts using the password `password`

The email format is `firstname@lastname.com`

Example:

    username:  Adam Almond
    email:     adam@almond.com
    password:  password


# Devlog

I thought I'd share some notes about how well (and not) it went. I wrote most
of this on Thursday morning so it's not a live log, but I'll note down what
I remember of the processes I went through.

## Environment setup

After the meeting on Wednesday I spent the afternoon reading Rails stuff.
It took a good part of Thursday to make sure my box was setup with the latest
Ruby and Rails, and that all the needed gems could be successfully installed.
I knew I needed Rails 5.2 for ActiveStorage, and I wanted to make sure MongoDB
was up and running. I didn't have much problem with this, it just took some
time. I also spend time reading all I could about Rails.

## Re-learn Rails

I had gone through an online Rails tutorial on Friday and Saturday, to
re-familiarise myself with Rails. The one difference I made to the tutorial
project was that where the tutorial used SQLite, I used MongoDB. You said to
try it, so I thought I'd try it :-). I followed the example exactly, to make
sure that my setup caused no errors.

## MongoDB

When I'd finished the tutorial I thought I'd better do a trial run of
ActiveStorage on a working project, just to iron out any kinks I might have.

A pretty big kink it turns out. ActiveStorage only works with ActiveRecord.
The clue's in the name, I guess.

So the options were ActiveRecord and ActiveStorage, or Mongo and some external
gem. Maybe Shrine? I don't know. I figured I'd go with ActiveStorage, simply
because it's built in, and I could find more tutorials to help me. If I'd had
more time, I'd have gone with Mongo, but I had to compromise. So I copped out
and went with the default SQLite.

## Initial Commit and Users

I started the actual project on Sunday. The first few commits are the usual
Gemfile stuff. I also created the basic user CRUD and views, and added
Bootstrap to make it look passable.

I'm not the best at UI, but I think what I have looks okay. It's mostly cribbed
from the [Album example](https://getbootstrap.com/docs/4.3/examples/album/).

## Rspec and Capybara

I wanted to use Capybara to text HTML visits for the controllers, but couldn't
get it working. Error was:

    Capybara::ElementNotFound:
      Unable to find xpath "/html"

Some puts debugging gave this:

    puts "~#{users_path}~"  =>  ~/users~
    puts "~#{page.html}~"   =>  ~~
    puts "~#{page}~"        =>  ~#<Capybara::Session:0x0000000008fb9b88>~

So it was returning a Capybara::Session, but it wasn't returning the html.
I'm sure there's some config option I've missed, but I'm feeling the deadline.

Honestly, this is what has stressed me out the most about this project.
I think that if there's anything that's going to make you think I don't have
what it takes to be a good good Ruby boy it's a lack of testing.

Honestly, I can test code. Look at this. This is okay. This is test-driven.
https://github.com/nossidge/tildeverse/tree/master/spec

I feel like testing for Rails is exponentially more difficult than just
testing regular Ruby objects. There's so many things I just don't know yet.
But I will get there.

## Sessions and Galleries

So yeah, I was feeling pretty terrible about my lack of skills, but there was
still work to be done. Sessions was next. I found a pretty good tutorial on
how to implement it, so this wasn't too hard.

Then I added the Gallery CRUD and views, and worked to implement 'current_user'
and 'owner?' validation to the views and requests that required them.

## Images and ActiveStorage

On Tuesday I started working on this. This was the big one. The thing I'd been
dreading. There were stumbling blocks, but it wasn't as bad as I'd feared.
One thing I had to figure out was how to validate the uploads, to make sure
they were images. Luckily there's a gem for that, but I couldn't figure out
how to get it working with multi-image uploads. So you can only upload one
image at a time. Kind of a cop-out, but not deal-breaking.

Once I'd got images in place, I worked on making them viewable in the views
where they'd be needed, including the User and Galleries views. It was easy
to integrate them here, because of the card-based layout I'd set up from
the start.

## Thumbnails and Refactoring

On Wednesday I added the code to generate thumbnails. This was also far easier
than I'd expected. They're cached automatically by Rails. Nice.

I spent most of Wednesday moving logic from views into helpers and partials.
There's still more to do on this front. There's lots of misplaced conditionals
that should be cleaned up. I put this down to inexperience, it's something
that will improve with practise.

## Seed data

I spent a fair few hours on Wednesday night trying to figure out how to get
this to work. Users and galleries were no problem, but images with their
ActiveStorage files were tricky.

I had a minor issue with figuring out how to add directly from a URL, but I
solved that soon enough. The big problem was that it would successfully
create the first user, and the first gallery, and would correctly attach
images to that, but it would fail when trying to attach images to the next
created gallery.

The solution is very silly. Instead of running:

    $ rails db:create db:migrate db:seed

You have to run:

    $ rails db:create db:migrate
    $ rails db:seed

Ridiculous.

## Final bug fixing and HTTP errors

On the last day, I fixed an issue with 'galleries/edit' not correctly showing
the gallery name and description. This occurred because I tried to get all
fancy with the show/hide collapsible form. I'm still not sure how you're
supposed to do it, but my solution works.

I also took a last pass at all the forms in the app, just ensuring that the
layout made sense and adding cancel buttons to take the user back.

I also added custom HTTP error handling, integrating it into the layout of
the site.

Then I finished this readme, and uploaded to GitHub.


# Immediate issues

I'm still not happy with the users/edit form - I think there should be
separate forms for changing username, email address, and password. It works
okay, but it's far from perfect.

I'm also not sure about the deletion of ActiveStorage objects. I'm not
convinced it actually kills them from the 'root/storage' directory.
That's just something I'll need to look up.


# Features not included

There's still lots of things I'd like to add. Here are some thoughts:

* Slideshow (see PDF)
* Cropping (see PDF)
* Static pages for About & Contact
* User can re-order images within gallery
* User can choose a featured image for the gallery, instead of using
  first image thumbnail
* User can choose an avatar for themselves from their own images
* On user creation, send mail with verification link
* Users can favourite each others' galleries/images
* Users can add comments on each others' galleries/images
* Images and galleries can be tagged by the owner
* Pagination of results for all index routes
* Filtering of results in index routes


# Project Takeaways

The single most important thing that I need to learn is how to test Rails apps.
The project as it is might be fine, it might fulfil the brief and it might be
functional, but I can't be sure. I've been writing specs almost daily for the
past two years; I thought it would be easier, but Rails adds complexity that
I was unprepared for. I need to understand this if I want to feel any kind of
comfort coding for Rails.

I need to learn how better to separate my logic from my views. Once I'd got
the basic MVP implemented, I did do some DRYing up of some view logic, but
I need to get into the swing of thinking about that stuff on first write.

There's some grotty UI logic going on in the Gallery#edit view. UI is still
an issue for me. I feel like half my time on this project was spent on
learning Rails idiosyncrasies and the other half on the views. Back-end stuff
will always be my preference, but I need to work on this stuff so that I'm
not spending so much time on it.

The main thing I learned is that I need to do more Rails stuff. I can put most
of these issues down to inexperience, and this stuff just gets easier with
practise. I haven't touched Rails in 18 months, so I can only get better.

Despite all the problems I had, I'm proud of this project.
