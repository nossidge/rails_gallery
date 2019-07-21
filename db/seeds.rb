# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create([
  { username: 'Paul Thompson', email: 'paul@thompson.com', password: 'p4ssw0rd' },
  { username: 'Adam Almond', email: 'adam@almond.com', password: 'p4ssw0rd' },
  { username: 'Betty Bootson', email: 'betty@bootson.com', password: 'p4ssw0rd' },
  { username: 'Joe Johnson', email: 'joe@johnson.com', password: 'p4ssw0rd' },
])
