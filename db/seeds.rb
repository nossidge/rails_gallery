# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

################################################################################
#
# NOTE!
#
# There's a weird bug here, since we're attaching ActiveStorage objects.
#
# In order to setup the database, you must run:
#   $ rails db:create db:migrate
#   $ rails db:seed
#
# You CANNOT run them as one command:
#   $ rails db:create db:migrate db:seed
#
# This is very silly, and caused me to re-write this file for hours.
# Here's the URL where I found the fix:
# https://www.reddit.com/r/rails/comments/9ewt4a/seeding_images_with_active_storage/e5s88l5/
#
################################################################################

##
# Add a sample image to a gallery.
# Fetch images from the internet, to avoid embiggening the repo.
#
# @param [Gallery] gallery
#   The gallery that will own the attached image
#
def attach_sample_jpg(gallery)
  url = 'https://thispersondoesnotexist.com/image'
  file = open(url)

  image = gallery.images.create
  image.file.attach(io: file, filename: 'image.jpg', content_type: 'image/jpg')
  image.save
end

################################################################################

user = User.create(username: 'Adam Almond', email: 'adam@almond.com', password: 'password')

gallery = Gallery.create(
  user: user,
  name: '2018 trip to Paris',
  description: "Louvre, Musée d'Orsay and Arc de Triomphe"
)
6.times { attach_sample_jpg(gallery) }

gallery = Gallery.create(
  user: user,
  name: "Sally's birthday",
  description: 'Best night ever! 22/06/2019 @ The Red Lion. Photos taken by Johnny'
)
3.times { attach_sample_jpg(gallery) }

################################################################################

User.create(username: 'Betty Bootson', email: 'betty@bootson.com', password: 'password')

################################################################################

user = User.create(username: 'Chris Carver', email: 'chris@carver.com', password: 'password')
Gallery.create(
  user: user,
  name: 'Business headshots',
  description: 'Taken by Philip Lowther Photography, York'
)

################################################################################

User.create(username: 'David Dixon', email: 'david@dixon.com', password: 'password')

################################################################################

User.create(username: 'Eleanor Ellis', email: 'eleanor@ellis.com', password: 'password')

################################################################################

user = User.create(username: 'Fred Frith', email: 'fred@frith.com', password: 'password')
gallery = Gallery.create(
  user: user,
  name: 'Cellular Automata',
  description: 'Changes to simple one-dimensional states (horizontal axis) over time (vertical)'
)
2.times { attach_sample_jpg(gallery) }

Gallery.create(
  user: user,
  name: 'Nothing',
  description: 'This gallery will always be empty (unless I add to it later...)'
)
