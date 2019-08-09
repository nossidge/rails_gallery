# https://www.kindleman.com.au/blog/drag-and-drop-with-rails-and-html5/

# For records existing before the migration, set the 'position'
# field to be based on the 'created_at' time.
class SetImageLists < ActiveRecord::Migration[5.2]
  def change
    Gallery.all.each do |gallery|
      gallery.images.order(:created_at).each.with_index(1) do |image, index|
        image.update_column :position, index
      end
    end
  end
end
