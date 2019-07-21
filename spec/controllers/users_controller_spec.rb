require 'rails_helper'




__END__




None of this works...






RSpec.describe UsersController, type: :controller do

  shared_examples_for 'with invalid fields' do
    fields = %w[username email password password_confirmation]
    fields.each do |field|
      it "fails if the #{field} is missing" do
        fill_in field.capitalize, with: ''
        expect { submit }.to_not change(User, :first)
        expect { submit }.to_not change(User, :count)
        is_expected.to have_content('error')
      end
    end

    it 'fails if the email does not contain @' do
      fill_in 'Email', with: 'personatexample.com'
      expect { submit }.to_not change(User, :first)
      expect { submit }.to_not change(User, :count)
      is_expected.to have_content('error')
    end

    it 'fails if the password is too short' do
      fill_in 'Password', with: 'a' * 7
      fill_in 'Password confirmation', with: 'a' * 7
      expect { submit }.to_not change(User, :first)
      expect { submit }.to_not change(User, :count)
      is_expected.to have_content('error')
    end
  end

  describe 'User pages' do
    before(:all) { User.delete_all }
    after (:all) { User.delete_all }

    scenario 'index page' do
      puts '########################################'
      puts "# #{users_path} #"
      puts "# #{page.html} #"
      puts "# #{page} #"
      puts '########################################'
      #expect(page).to have_content('Users view')
    end
  end

end
