# https://www.kindleman.com.au/blog/drag-and-drop-with-rails-and-html5/

class AddPositionToImages < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :position, :integer
  end
end
