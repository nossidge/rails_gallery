# frozen_string_literal: true

# Instead of wrapping error fields in a new 'div' (which may break Bootstrap
# CSS), append the error class to the invalid 'input' tag.
# https://stackoverflow.com/a/8380400
ActionView::Base.field_error_proc = proc do |html_tag|
  css_class = 'is-invalid'
  class_attr_index = html_tag.index 'class="'

  if class_attr_index
    html_tag.insert class_attr_index + 7, %(#{css_class} )
  else
    html_tag.insert html_tag.index('>'), %( class="#{css_class}")
  end
end
